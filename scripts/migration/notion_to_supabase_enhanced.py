"""
Notion to Supabase Migration Script (Enhanced)
===============================================

This script migrates expense data from Notion CSV export to Supabase.
It handles Notion-specific formatting including URLs, comma separators, and extra columns.

Prerequisites:
- Python 3.8+
- pip install pandas supabase-py python-dotenv

Usage:
python notion_to_supabase_enhanced.py --csv <path_to_csv> --user-id <your_uuid>
"""

import pandas as pd
from supabase import create_client, Client
from dotenv import load_dotenv
import os
import sys
import argparse
import re
from datetime import datetime

# Load environment variables from project root
script_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(script_dir, '../../.env')
load_dotenv(env_path)

# Configuration
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')  # Use service role for admin operations

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def clean_notion_text(text):
    """
    Remove Notion URLs and clean text
    Example: "Đi lại (https://www.notion.so/...)" → "Đi lại"
    """
    if pd.isna(text):
        return None

    text = str(text).strip()

    # Remove Notion URL (everything from first opening parenthesis)
    if '(' in text:
        text = text.split('(')[0].strip()

    return text

def normalize_category_name(category):
    """
    Normalize category names to handle spelling variations
    Maps Notion variations to Supabase canonical names
    """
    if pd.isna(category):
        return None
    
    # Mapping of Notion spellings to Supabase spellings
    category_mapping = {
        'Quà vặt': 'Quà vật',      # Common Vietnamese variant
        'Sức khoẻ': 'Sức khỏe',    # Common Vietnamese variant
        'Biếu gia đình': 'Biểu gia đình',  # Spelling variant
    }
    
    return category_mapping.get(category, category)

def clean_amount(amount):
    """
    Remove commas and convert to float
    Example: "50,000" → 50000.0
    """
    if pd.isna(amount):
        return 0.0

    # Convert to string and remove commas
    amount_str = str(amount).replace(',', '')

    try:
        return float(amount_str)
    except ValueError:
        print(f"⚠️  Warning: Could not parse amount: {amount}")
        return 0.0

def parse_notion_date(date_str):
    """
    Parse Notion date format: "January 1, 2025" → "2025-01-01"
    """
    if pd.isna(date_str):
        return None

    try:
        # Try parsing Notion format: "January 1, 2025"
        date_obj = datetime.strptime(str(date_str), "%B %d, %Y")
        return date_obj.strftime("%Y-%m-%d")
    except ValueError:
        try:
            # Try ISO format: "2025-01-01"
            date_obj = datetime.strptime(str(date_str), "%Y-%m-%d")
            return date_obj.strftime("%Y-%m-%d")
        except ValueError:
            print(f"⚠️  Warning: Could not parse date: {date_str}")
            return None

def fetch_category_mapping():
    """
    Fetch all categories from Supabase and create Vietnamese name → UUID mapping
    """
    print("📥 Fetching categories from Supabase...")
    response = supabase.table('categories').select('id, name_vi').execute()

    category_map = {cat['name_vi']: cat['id'] for cat in response.data}
    print(f"✅ Found {len(category_map)} categories")

    # Display categories for verification
    print("\n📋 Available categories:")
    for name_vi in sorted(category_map.keys()):
        print(f"  • {name_vi}")

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
    print("\n📋 Available expense types:")
    for name_vi in sorted(type_map.keys()):
        print(f"  • {name_vi}")

    return type_map

def load_and_clean_csv(filename):
    """
    Load Notion CSV export and clean the data
    """
    print(f"\n📂 Loading CSV file: {filename}")

    if not os.path.exists(filename):
        print(f"❌ Error: File '{filename}' not found")
        print(f"   Expected path: {os.path.abspath(filename)}")
        sys.exit(1)

    # Read CSV
    df = pd.read_csv(filename)
    print(f"✅ Loaded {len(df)} rows from CSV")

    # Display original columns
    print(f"\n📊 Original CSV columns ({len(df.columns)}):")
    for col in df.columns:
        print(f"  • {col}")

    # Clean and transform data
    print("\n🧹 Cleaning data...")

    # Extract and clean the columns we need
    cleaned_df = pd.DataFrame({
        'description': df['Name'].apply(clean_notion_text),
        'amount': df['Amount'].apply(clean_amount),
        'category': df['Category'].apply(clean_notion_text).apply(normalize_category_name),
        'type': df['Type'].apply(clean_notion_text),
        'date': df['Date'].apply(parse_notion_date),
        'note': df['Notes'].apply(lambda x: clean_notion_text(x) if pd.notna(x) and str(x).strip() else None)
    })

    # Remove rows with invalid dates
    original_count = len(cleaned_df)
    cleaned_df = cleaned_df[cleaned_df['date'].notna()]
    removed_count = original_count - len(cleaned_df)

    if removed_count > 0:
        print(f"⚠️  Removed {removed_count} rows with invalid dates")

    print(f"✅ Cleaned {len(cleaned_df)} valid expenses")

    # Show sample of cleaned data
    print("\n📝 Sample of cleaned data (first 3 rows):")
    print(cleaned_df.head(3).to_string())

    return cleaned_df

def validate_data(df, category_map, type_map):
    """
    Validate that all categories and types in CSV exist in Supabase
    """
    print("\n🔍 Validating data...")

    errors = []
    warnings = []

    # Check for missing categories
    unique_categories = df['category'].unique()
    # Filter out None values before checking
    invalid_categories = set(c for c in unique_categories if c is not None) - set(category_map.keys())

    if invalid_categories:
        errors.append(f"Invalid categories found: {', '.join(str(c) for c in invalid_categories)}")
        print(f"\n❌ Categories not in database:")
        for cat in invalid_categories:
            count = len(df[df['category'] == cat])
            print(f"  • {cat} ({count} expenses)")

    # Check for missing types
    unique_types = df['type'].unique()
    # Filter out None values before checking
    invalid_types = set(t for t in unique_types if t is not None) - set(type_map.keys())

    if invalid_types:
        errors.append(f"Invalid expense types found: {', '.join(str(t) for t in invalid_types)}")
        print(f"\n❌ Types not in database:")
        for t in invalid_types:
            count = len(df[df['type'] == t])
            print(f"  • {t} ({count} expenses)")

    # Check for zero amounts
    zero_amounts = len(df[df['amount'] == 0])
    if zero_amounts > 0:
        warnings.append(f"{zero_amounts} expenses have zero amount")

    if errors:
        print("\n❌ Validation failed:")
        for error in errors:
            print(f"   • {error}")
        print("\n💡 Tip: Make sure category/type names match exactly (case-sensitive)")
        sys.exit(1)

    if warnings:
        print("\n⚠️  Warnings:")
        for warning in warnings:
            print(f"   • {warning}")

    print("✅ All data validated successfully")

    # Show statistics
    print("\n📊 Data statistics:")
    print(f"  • Total expenses: {len(df)}")
    print(f"  • Unique categories: {len(unique_categories)}")
    print(f"  • Unique types: {len(unique_types)}")
    print(f"  • Date range: {df['date'].min()} to {df['date'].max()}")
    print(f"  • Amount range: ₫{df['amount'].min():,.0f} to ₫{df['amount'].max():,.0f}")
    print(f"  • Total amount: ₫{df['amount'].sum():,.0f}")

def transform_data(df, category_map, type_map, user_id):
    """
    Transform cleaned CSV data to Supabase schema format
    """
    print("\n🔄 Transforming data for Supabase...")

    expenses = []
    skipped = 0

    for idx, row in df.iterrows():
        # Skip if category or type is invalid
        if row['category'] not in category_map:
            skipped += 1
            continue
        if row['type'] not in type_map:
            skipped += 1
            continue

        expense = {
            'user_id': user_id,
            'category_id': category_map[row['category']],
            'type_id': type_map[row['type']],
            'description': row['description'],
            'amount': row['amount'],
            'date': row['date'],
            'note': row['note']
        }
        expenses.append(expense)

    if skipped > 0:
        print(f"⚠️  Skipped {skipped} rows due to invalid category/type")

    print(f"✅ Transformed {len(expenses)} expenses ready for migration")
    return expenses

def migrate_expenses(expenses):
    """
    Batch insert expenses into Supabase
    """
    print(f"\n📤 Migrating {len(expenses)} expenses to Supabase...")

    # Insert in batches of 100 to avoid API limits
    batch_size = 100
    total_inserted = 0
    errors = []

    for i in range(0, len(expenses), batch_size):
        batch = expenses[i:i + batch_size]
        try:
            response = supabase.table('expenses').insert(batch).execute()
            total_inserted += len(response.data)

            # Progress indicator
            progress = (i + len(batch)) / len(expenses) * 100
            print(f"  [{'=' * int(progress / 5)}{' ' * (20 - int(progress / 5))}] {progress:.0f}% - Batch {i//batch_size + 1}")

        except Exception as e:
            errors.append(f"Batch {i//batch_size + 1}: {str(e)}")
            print(f"  ❌ Error in batch {i//batch_size + 1}: {str(e)}")

    if errors:
        print(f"\n⚠️  {len(errors)} batch(es) failed:")
        for error in errors:
            print(f"  • {error}")

    print(f"\n✅ Successfully migrated {total_inserted} expenses")
    return total_inserted

def verify_migration(expected_count, user_id):
    """
    Verify that all expenses were migrated correctly
    """
    print("\n🔍 Verifying migration...")

    # Count total expenses for user
    response = supabase.table('expenses').select('id', count='exact').eq('user_id', user_id).execute()
    actual_count = response.count

    print(f"  • Expected: {expected_count} expenses")
    print(f"  • Found:    {actual_count} expenses")

    if actual_count == expected_count:
        print("✅ Migration verified successfully!")
        return True
    else:
        print(f"⚠️  Warning: Count mismatch ({actual_count} vs {expected_count})")
        return False

def main():
    """
    Main migration workflow
    """
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Migrate Notion expenses to Supabase')
    parser.add_argument('--csv', required=True, help='Path to Notion CSV export file')
    parser.add_argument('--user-id', required=True, help='Supabase user UUID')
    args = parser.parse_args()

    print("=" * 70)
    print("           Notion → Supabase Migration (Enhanced)")
    print("=" * 70)
    print(f"\n📁 CSV File: {args.csv}")
    print(f"👤 User ID:  {args.user_id}")

    # Validate UUID format
    uuid_pattern = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
    if not uuid_pattern.match(args.user_id):
        print("\n❌ Error: Invalid UUID format")
        print("   Expected format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
        sys.exit(1)

    # Step 1: Fetch mappings from Supabase
    category_map = fetch_category_mapping()
    type_map = fetch_type_mapping()

    # Step 2: Load and clean CSV
    df = load_and_clean_csv(args.csv)

    # Step 3: Validate data
    validate_data(df, category_map, type_map)

    # Step 4: Transform data
    expenses = transform_data(df, category_map, type_map, args.user_id)

    # Step 5: Confirm before migration
    print("\n" + "=" * 70)
    print(f"⚠️  Ready to migrate {len(expenses)} expenses to Supabase")
    print("=" * 70)
    confirm = input("\n   Continue with migration? (yes/no): ")

    if confirm.lower() != 'yes':
        print("\n❌ Migration cancelled by user")
        sys.exit(0)

    # Step 6: Migrate
    total_inserted = migrate_expenses(expenses)

    # Step 7: Verify
    verify_migration(total_inserted, args.user_id)

    print("\n" + "=" * 70)
    print("✅ Migration Complete!")
    print("=" * 70)
    print(f"\n📊 Summary:")
    print(f"  • Migrated: {total_inserted} expenses")
    print(f"  • User ID:  {args.user_id}")
    print(f"\n🎯 Next steps:")
    print(f"  1. Check Supabase Dashboard → Table Editor → expenses")
    print(f"  2. Launch Flutter app to see your historical expenses")
    print(f"  3. Verify data looks correct")
    print(f"\n🚀 Happy expense tracking!\n")

if __name__ == '__main__':
    main()
