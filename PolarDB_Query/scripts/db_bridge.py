import pymysql
import json
import os

# Configuration file path
CONFIG_FILE = os.path.join(os.path.dirname(__file__), 'db_config.json')

def load_config():
    if not os.path.exists(CONFIG_FILE):
        print(f"Error: Configuration file not found at {CONFIG_FILE}")
        return None
    try:
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading configuration: {e}")
        return None

def execute_query(sql):
    config = load_config()
    if not config:
        return

    # Check if password is still the placeholder
    if config.get('password') == "YOUR_PASSWORD_HERE":
        print("Please update db_config.json with your actual database password.")
        return

    try:
        connection = pymysql.connect(
            host=config['host'],
            port=config['port'],
            user=config['user'],
            password=config['password'],
            database=config['database'], # Default database, can be changed in query via 'USE dbname' or fully qualified names
            charset=config['charset'],
            cursorclass=pymysql.cursors.DictCursor
        )

        with connection.cursor() as cursor:
            print(f"Executing SQL: {sql}")
            cursor.execute(sql)
            if sql.strip().upper().startswith("SELECT") or sql.strip().upper().startswith("SHOW"):
                result = cursor.fetchall()
                print(json.dumps(result, ensure_ascii=False, indent=2, default=str)) # Use default=str for dates etc.
            else:
                connection.commit()
                print(f"Query executed successfully. Affected rows: {cursor.rowcount}")

    except Exception as e:
        print(f"Database Error: {e}")
    finally:
        if 'connection' in locals() and connection.open:
            connection.close()

if __name__ == "__main__":
    # Example usage: passing SQL as a command line argument could be added here
    # For now, this is a library for the agent to use via python scripts
    print("Database Bridge Module Loaded.")
