"""
Notion to Supabase Migration Script
====================================

This script migrates expense data from Notion CSV export to Supabase.

Prerequisites:
- Python 3.8+
- pip install pandas supabase-py python-dotenv

Usage:
1. Export Notion database to CSV (place in this directory)
2. Update USER_ID with your Supabase user ID
3. Run: python notion_to_supabase.py

Expected CSV columns:
- Name (description)
- Amount (numeric)
- Category (Vietnamese name from 14 categories)
- Type (Vietnamese name: Phát sinh, Phải chi, or Lãng phí)
- Date (YYYY-MM-DD format)
- Notes (optional)
"""

import pandas as pd
from supabase import create_client, Client
from dotenv import load_dotenv
import os
import sys
from datetime import datetime

# Load environment variables
load_dotenv('../../.env')

# Configuration
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_ANON_KEY')
CSV_FILE = 'notion_expenses.csv'  # Update with your CSV filename
USER_ID = 'YOUR_USER_ID_HERE'     # Update after creating first user

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def fetch_category_mapping():
    """
    Fetch all categories from Supabase and create Vietnamese name → UUID mapping
    """
    print("📥 Fetching categories from Supabase...")
    response = supabase.table('categories').select('id, name_vi').execute()

    category_map = {cat['name_vi']: cat['id'] for cat in response.data}
    print(f"✅ Found {len(category_map)} categories")

    # Display categories for verification
    print("\nAvailable categories:")
    for name_vi in sorted(category_map.keys()):
        print(f"  - {name_vi}")

    return category_map

def fetch_type_mapping():
    """
    Fetch all expense types from Supabase and create Vietnamese name → UUID mapping
    """
    print("\n📥 Fetching expense types from Supabase...")
    response = supabase.table('expense_types').select('id, name_vi').execute()

    type_map = {t['name_vi']: t['id'] for t in response.data}
    print(f"✅ Found {len(type_map)} expense types")

    # Display types for verification
    print("\nAvailable expense types:")
    for name_vi in sorted(type_map.keys()):
        print(f"  - {name_vi}")

    return type_map

def load_csv(filename):
    """
    Load and validate Notion CSV export
    """
    print(f"\n📂 Loading CSV file: {filename}")

    if not os.path.exists(filename):
        print(f"❌ Error: File '{filename}' not found")
        print(f"   Please export your Notion database to CSV and place it in:")
        print(f"   {os.path.abspath(filename)}")
        sys.exit(1)

    df = pd.read_csv(filename)
    print(f"✅ Loaded {len(df)} rows from CSV")

    # Display CSV columns
    print("\nCSV Columns found:")
    for col in df.columns:
        print(f"  - {col}")

    return df

def validate_data(df, category_map, type_map):
    """
    Validate that all categories and types in CSV exist in Supabase
    """
    print("\n🔍 Validating data...")

    errors = []

    # Check required columns
    required_columns = ['Name', 'Amount', 'Category', 'Type', 'Date']
    missing_columns = [col for col in required_columns if col not in df.columns]

    if missing_columns:
        errors.append(f"Missing required columns: {', '.join(missing_columns)}")

    # Validate categories
    invalid_categories = set(df['Category'].unique()) - set(category_map.keys())
    if invalid_categories:
        errors.append(f"Invalid categories found: {', '.join(invalid_categories)}")

    # Validate types
    invalid_types = set(df['Type'].unique()) - set(type_map.keys())
    if invalid_types:
        errors.append(f"Invalid expense types found: {', '.join(invalid_types)}")

    if errors:
        print("\n❌ Validation failed:")
        for error in errors:
            print(f"   - {error}")
        sys.exit(1)

    print("✅ All data validated successfully")

def transform_data(df, category_map, type_map):
    """
    Transform CSV data to Supabase schema format
    """
    print("\n🔄 Transforming data...")

    expenses = []
    for _, row in df.iterrows():
        expense = {
            'user_id': USER_ID,
            'category_id': category_map[row['Category']],
            'type_id': type_map[row['Type']],
            'description': row['Name'],
            'amount': float(row['Amount']),
            'date': row['Date'],
            'note': row.get('Notes', '') if pd.notna(row.get('Notes')) else None,
        }
        expenses.append(expense)

    print(f"✅ Transformed {len(expenses)} expenses")
    return expenses

def migrate_expenses(expenses):
    """
    Batch insert expenses into Supabase
    """
    print(f"\n📤 Migrating {len(expenses)} expenses to Supabase...")

    # Insert in batches of 100 to avoid API limits
    batch_size = 100
    total_inserted = 0

    for i in range(0, len(expenses), batch_size):
        batch = expenses[i:i + batch_size]
        response = supabase.table('expenses').insert(batch).execute()
        total_inserted += len(response.data)
        print(f"   Inserted batch {i//batch_size + 1}: {len(response.data)} rows")

    print(f"✅ Successfully migrated {total_inserted} expenses")
    return total_inserted

def verify_migration(expected_count):
    """
    Verify that all expenses were migrated correctly
    """
    print("\n🔍 Verifying migration...")

    # Count total expenses for user
    response = supabase.table('expenses').select('id', count='exact').eq('user_id', USER_ID).execute()
    actual_count = response.count

    print(f"   Expected: {expected_count} expenses")
    print(f"   Found:    {actual_count} expenses")

    if actual_count == expected_count:
        print("✅ Migration verified successfully")
        return True
    else:
        print(f"⚠️  Warning: Count mismatch ({actual_count} vs {expected_count})")
        return False

def main():
    """
    Main migration workflow
    """
    print("=" * 60)
    print("Notion → Supabase Migration")
    print("=" * 60)

    # Check configuration
    if USER_ID == 'YOUR_USER_ID_HERE':
        print("\n❌ Error: Please update USER_ID in the script")
        print("   1. Create a user account in your app")
        print("   2. Get the user ID from Supabase Auth dashboard")
        print("   3. Update USER_ID variable in this script")
        sys.exit(1)

    # Step 1: Fetch mappings from Supabase
    category_map = fetch_category_mapping()
    type_map = fetch_type_mapping()

    # Step 2: Load CSV
    df = load_csv(CSV_FILE)

    # Step 3: Validate data
    validate_data(df, category_map, type_map)

    # Step 4: Transform data
    expenses = transform_data(df, category_map, type_map)

    # Step 5: Confirm before migration
    print(f"\n⚠️  Ready to migrate {len(expenses)} expenses to Supabase")
    confirm = input("   Continue? (yes/no): ")

    if confirm.lower() != 'yes':
        print("Migration cancelled")
        sys.exit(0)

    # Step 6: Migrate
    total_inserted = migrate_expenses(expenses)

    # Step 7: Verify
    verify_migration(total_inserted)

    print("\n" + "=" * 60)
    print("✅ Migration Complete!")
    print("=" * 60)
    print(f"\nNext steps:")
    print(f"  1. Check Supabase Table Editor → expenses table")
    print(f"  2. Verify expense counts by category")
    print(f"  3. Test queries in SQL Editor")

if __name__ == '__main__':
    main()
