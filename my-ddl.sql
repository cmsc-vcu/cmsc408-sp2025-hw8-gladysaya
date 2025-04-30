import mysql.connector
from mysql.connector import Error


    'user': 'ayanoug',
    'password': 'Awesomeme#2517',  # Avoid hardcoding in real-world apps if possible
    'host': 'localhost',
    'database': 'cmsc408-sp2025-hw8'


DDL_FILE = "my-ddl.sql"
REPORT_FILE = "report.html"

# --- Database Connection ---
def connect_to_db():
    try:
        cnx = mysql.connector.connect(**DB_CONFIG)
        if cnx.is_connected():
            print("Connected to MySQL Database")
            return cnx
    except Error as e:
        print(f"[Connection Error] {e}")
    return None

# --- Execute DDL Commands ---
def execute_ddl_from_file(filename, cnx):
    try:
        with open(filename, 'r') as file:
            ddl_commands = file.read().split(';')
        cursor = cnx.cursor()
        print("[DEBUG] Contents of DDL file:")
        print(ddl_commands)
        for command in map(str.strip, ddl_commands):
            if command:
                print(f"Executing: {command}")  # Debugging line
                cursor.execute(command)
        cnx.commit()
        print("DDL executed successfully")
    except mysql.connector.Error as err:
        print(f"[DDL Execution Error] {err}")
    except Exception as e:
        print(f"[General Error] {e}")
    finally:
        cursor.close()

# --- Execute SQL Query ---
def execute_query(query, cnx):
    cursor = cnx.cursor()
    try:
        cursor.execute(query)
        if cursor.description:
            return cursor.fetchall()
        cnx.commit()
        return "Query executed successfully"
    except mysql.connector.Error as err:
        print(f"[Query Error] {err}")
        return None
    except Exception as e:
        print(f"[General Error] {e}")
        return None
    finally:
        cursor.close()

# --- Generate HTML Report ---
def generate_html_report(results, filename=REPORT_FILE):
    try:
        with open(filename, 'w') as file:
            file.write('<html><body><h1>Database Report</h1><table border="1">')
            file.write('<tr><th>Task</th><th>Result</th></tr>')
            for task, result in results.items():
                file.write(f'<tr><td>{task}</td><td>{format_result(result)}</td></tr>')
            file.write('</table></body></html>')
        print(f"HTML report generated successfully: {filename}")
    except Exception as e:
        print(f"[Report Generation Error] {e}")

# --- Format SQL Results for HTML ---
def format_result(result):
    if isinstance(result, list):
        return '<br>'.join([str(row) for row in result])
    return str(result)

# --- Main ---
def main():
    cnx = connect_to_db()
    if not cnx:
        return

    execute_ddl_from_file(DDL_FILE, cnx)

    tasks = {
        'Task 1 - How big is wdi_country?': "SELECT COUNT(*) FROM wdi_country",
        'Task 2 - Quick peek at data': "SELECT country FROM wdi_country LIMIT 22",
        'Task 3 - List non-countries': "SELECT country FROM wdi_country WHERE country IN ('World', 'Upper middle income')",
        'Task 4 - Make copy of wdi_country': "SELECT COUNT(*) FROM wdi_country_copy",
        'Task 5 - How many countries?': "SELECT COUNT(DISTINCT country) FROM wdi_country",
        'Task 6 - Unique regions names?': "SELECT DISTINCT region FROM wdi_country",
        'Task 7 - Unique regions and country counts': "SELECT region, COUNT(*) FROM wdi_country GROUP BY region",
        'Task 8 - Region name and country name in North America': "SELECT country, region FROM wdi_country WHERE region = 'North America'",
        'Task 9 - Where is Qatar?': "SELECT region FROM wdi_country WHERE country = 'Qatar'",
        'Task 10 - Country abbreviations': "SELECT abbreviation FROM wdi_country WHERE country IN ('Serbia', 'Timor-Leste', 'Yemen')",
        'Task 11 - Income categories': "SELECT DISTINCT income_group FROM wdi_country",
        'Task 12 - Mystery task - Who is NULL?': "SELECT country FROM wdi_country WHERE income_group IS NULL",
        'Task 13 - Fixing bad data using UPDATE': "UPDATE wdi_country SET income_group = 'High income' WHERE country = 'Venezuela'",
        'Task 14 - Region/Income group pairs': "SELECT region, income_group FROM wdi_country GROUP BY region, income_group",
        'Task 15 - Region/Income group cross tabulation': "SELECT region, income_group, COUNT(*) FROM wdi_country GROUP BY region, income_group",
        'Task 16 - Region with most low-income countries': "SELECT region FROM wdi_country WHERE income_group = 'Low income' GROUP BY region ORDER BY COUNT(*) DESC LIMIT 1",
        'Task 17 - Countries similar to Marshall Islands': "SELECT country FROM wdi_country WHERE region = (SELECT region FROM wdi_country WHERE country = 'Marshall Islands')",
        'Task 18 - Missing region/income group pairs': "SELECT DISTINCT region FROM wdi_country WHERE income_group IS NULL",
        'Task 19 - Percentage tables': "SELECT region, income_group, COUNT(*) / (SELECT COUNT(*) FROM wdi_country) * 100 FROM wdi_country GROUP BY region, income_group",
        'Task 20 - Cross tabulations by region and income': "SELECT region, income_group, COUNT(*) FROM wdi_country GROUP BY region, income_group",
        'Task 21 - Cross tabulations by income only': "SELECT income_group, COUNT(*) FROM wdi_country GROUP BY income_group"
    }

    results = {}
    for task, query in tasks.items():
        result = execute_query(query, cnx)
        results[task] = result if result else "No results found"

    generate_html_report(results)
    cnx.close()
if __name__ == "__main__":
    main()
