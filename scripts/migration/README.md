# Notion to Supabase Migration

This directory contains scripts for migrating expense data from Notion to Supabase.

## Prerequisites

### 1. Python Environment
```bash
# Install Python dependencies
pip install pandas supabase-py python-dotenv
```

### 2. Notion CSV Export
1. Open your Notion expense database
2. Click the **"..."** menu (top right)
3. Select **Export**
4. Choose format: **CSV**
5. Download and save as `notion_expenses.csv` in this directory

Expected CSV columns:
- **Name** - Expense description
- **Amount** - Expense amount (numeric)
- **Category** - Vietnamese category name (one of 14 categories)
- **Type** - Vietnamese type (Phát sinh, Phải chi, or Lãng phí)
- **Date** - Date in YYYY-MM-DD format
- **Notes** - Optional notes

### 3. User ID
You need your Supabase user ID before running the migration:

**Option A: Create via Authentication (Milestone 5)**
- Wait until we implement authentication in M5
- Sign up in the app
- Get user ID from Supabase Auth dashboard

**Option B: Create Manually (Advanced)**
- Go to Supabase **Authentication** → **Users**
- Click **Add user** → Create with email/password
- Copy the user UUID

## Migration Steps

### Step 1: Prepare CSV
```bash
# Place your Notion CSV export in this directory
cp ~/Downloads/your-notion-export.csv notion_expenses.csv
```

### Step 2: Update Script Configuration
Edit `notion_to_supabase.py`:
```python
CSV_FILE = 'notion_expenses.csv'  # Your CSV filename
USER_ID = 'your-uuid-here'        # Your Supabase user UUID
```

### Step 3: Run Migration
```bash
cd scripts/migration
python notion_to_supabase.py
```

### Step 4: Verify Results
The script will:
1. ✅ Fetch category and type mappings from Supabase
2. ✅ Load and validate your CSV data
3. ✅ Transform data to match Supabase schema
4. ✅ Batch insert expenses (100 at a time)
5. ✅ Verify migration count

## Troubleshooting

### "Invalid categories found"
- Check that CSV uses exact Vietnamese names from seed data
- Categories are case-sensitive
- Run verification query:
  ```sql
  SELECT name_vi FROM categories WHERE is_system = true;
  ```

### "Invalid expense types found"
- Type names must be exactly: `Phát sinh`, `Phải chi`, or `Lãng phí`
- Check for extra spaces or typos

### "USER_ID not updated"
- You must set a valid user UUID before migration
- Get UUID from Supabase **Authentication** → **Users**

### "File not found"
- Ensure CSV is in `scripts/migration/` directory
- Check filename matches `CSV_FILE` variable

## Validation Queries

After migration, run these in Supabase SQL Editor:

### Count total expenses
```sql
SELECT COUNT(*) FROM expenses WHERE user_id = 'your-user-id';
```

### Sum by category
```sql
SELECT
  c.name_vi,
  COUNT(*) as expense_count,
  SUM(e.amount) as total_amount
FROM expenses e
JOIN categories c ON e.category_id = c.id
WHERE e.user_id = 'your-user-id'
GROUP BY c.name_vi
ORDER BY total_amount DESC;
```

### Check date range
```sql
SELECT
  MIN(date) as earliest,
  MAX(date) as latest,
  COUNT(*) as total
FROM expenses
WHERE user_id = 'your-user-id';
```

## Migration Status

- [ ] Notion CSV exported
- [ ] Python dependencies installed
- [ ] User created in Supabase Auth
- [ ] USER_ID updated in script
- [ ] Migration script executed
- [ ] Data validated in Table Editor

---

**Note:** You can run this migration multiple times safely. The script does NOT check for duplicates, so make sure to clear the expenses table before re-running:

```sql
-- Clear all expenses for your user
DELETE FROM expenses WHERE user_id = 'your-user-id';
```
