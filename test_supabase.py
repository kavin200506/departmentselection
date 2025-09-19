#!/usr/bin/env python3
"""
Test Supabase connection with different credentials
"""
import psycopg2
from psycopg2 import OperationalError

def test_connection(host, port, database, user, password):
    try:
        print(f"Testing connection to {host}...")
        conn = psycopg2.connect(
            host=host,
            port=port,
            database=database,
            user=user,
            password=password,
            sslmode='require'
        )
        print("✅ Connection successful!")
        conn.close()
        return True
    except OperationalError as e:
        print(f"❌ Connection failed: {e}")
        return False

# Test with your current credentials
print("Testing current credentials...")
test_connection(
    host='db.nnguxuuoxsrxadniklus.supabase.co',
    port='5432',
    database='postgres',
    user='postgres',
    password='2q6tguwVFSyOxTJR'
)

print("\n" + "="*50)
print("If the connection failed, please:")
print("1. Go to supabase.com")
print("2. Open your project: nnguxuuoxsrxadniklus")
print("3. Go to Settings → Database")
print("4. Reset your database password")
print("5. Copy the new password and run this script again")
print("="*50)
