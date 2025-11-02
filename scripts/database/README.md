# Database Scripts

This directory contains SQL scripts for setting up the Supabase database schema and seed data.

## Execution Order

Execute these scripts in Supabase SQL Editor in the following order:

### 1. Schema Creation (`01_schema.sql`)
Creates all database tables with Row Level Security policies.

**Tables Created:**
- `categories` - Expense categories (Vietnamese + English names)
- `expense_types` - Expense type classifications
- `expenses` - Main transaction records
- `budgets` - Monthly budget limits (Milestone 6)
- `recurring_expenses` - Auto-creation templates (Milestone 6)

**Result:** 5 tables created with indexes and RLS policies

### 2. Seed Data (`02_seed_data.sql`)
Populates system categories and expense types.

**Data Inserted:**
- 14 Vietnamese categories from Notion
- 3 Vietnamese expense types (Phát sinh, Phải chi, Lãng phí)

**Result:**
- ✅ 14 system categories
- ✅ 3 expense types

## Verification

After executing both scripts:

1. **Table Editor** → Should see 5 tables
2. **categories** table → 14 rows with Vietnamese names
3. **expense_types** table → 3 rows with Vietnamese types
4. **expenses** table → 0 rows (empty until migration)
5. **budgets** table → 0 rows (empty)
6. **recurring_expenses** table → 0 rows (empty)

## Troubleshooting

### "expense_date does not exist" error
- This is a Table Editor UI sorting issue
- Go to **Table Editor** → **expenses** table
- Click **"Sorted by X rules"** and remove all sorting rules
- Refresh the page

### Categories not showing Vietnamese names
- Verify UTF-8 encoding in SQL Editor
- Check `name_vi` column has Vietnamese text
- Run: `SELECT name_vi FROM categories LIMIT 5;`

## Next Steps

After successful schema setup:
- **Phase 4.4:** Export Notion database to CSV
- **Phase 4.5:** Run Python migration script
- **Phase 4.6:** Validate migrated data

---

**Executed:** 2025-10-26
**Status:** ✅ Complete
