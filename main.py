import os
import psycopg2
from dotenv import load_dotenv
from tabulate import tabulate

load_dotenv()

def run_query(tenant_id):
    """Execute query for a specific tenant"""
    conn = psycopg2.connect(
        host=os.getenv("PGHOST"),
        port=os.getenv("PGPORT"),
        user=os.getenv("PGUSER"),
        password=os.getenv("PGPASSWORD"),
        dbname=os.getenv("PGDATABASE"),
    )
    try:
        with conn.cursor() as cur:
            # Set tenant_id in session
            cur.execute(f"SET app.tenant_id = '{tenant_id}'")

            # Query WITHOUT WHERE clause
            cur.execute("SELECT id, tenant_id, message, created_at FROM events ORDER BY created_at")
            rows = cur.fetchall()

            print(f"\n📦 Events for tenant {tenant_id}:\n")
            print(tabulate(rows, headers=["id", "tenant_id", "message", "created_at"]))
    finally:
        conn.close()


def insert_event(tenant_id, message):
    """Insert event for a specific tenant"""
    conn = psycopg2.connect(
        host=os.getenv("PGHOST"),
        port=os.getenv("PGPORT"),
        user=os.getenv("PGUSER"),
        password=os.getenv("PGPASSWORD"),
        dbname=os.getenv("PGDATABASE"),
    )
    try:
        with conn.cursor() as cur:
            # Set tenant_id in session
            cur.execute(f"SET app.tenant_id = '{tenant_id}'")

            # Insert event WITHOUT manually passing tenant_id (will be filled by trigger)
            cur.execute(
                "INSERT INTO events (message) VALUES (%s)",
                (message,)
            )
            conn.commit()
            print(f"✅ Event successfully inserted for tenant {tenant_id}")
    except Exception as e:
        print(f"❌ Error inserting event: {e}")
    finally:
        conn.close()


if __name__ == "__main__":
    # Query events for each tenant
    run_query("11111111-1111-1111-1111-111111111111")  # Client A
    run_query("22222222-2222-2222-2222-222222222222")  # Client B
    
    # Insert events
    insert_event("11111111-1111-1111-1111-111111111111", "Alarm inserted correctly")  # should work
    insert_event("22222222-2222-2222-2222-222222222222", "Trying to invade another tenant")  # will fail if trying to invade another tenant
