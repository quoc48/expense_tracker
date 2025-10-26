# Milestone 4-7 Planning Session

## Session Context
**Date**: October 26, 2025
**Current Status**: MVP Complete (Milestones 1-3)
**Next Phase**: Advanced Features with Supabase Integration

---

## User Requirements

### Primary Goals
1. **Supabase Integration**: Cloud backend for sync and authentication
2. **Notion Data Migration**: Export existing Notion expense data to Supabase
3. **Advanced Features**: Recurring expenses + Budget tracking
4. **Vietnamese Categories**: Preserve 14 categories from Notion

### Data Source
- Currently tracking expenses in Notion
- Need to export Notion database to CSV
- Migrate CSV data to Supabase
- Continue tracking in new Flutter app with cloud sync

---

## Vietnamese Categories (14 Total)

From user's Notion database - **KEEP EXACTLY AS-IS**:

| Vietnamese Name | English Translation | Icon | Category Type |
|----------------|-------------------|------|---------------|
| Thực phẩm | Food | restaurant | Essential |
| Sức khỏe | Health | medical_services | Essential |
| Thời trang | Fashion | checkroom | Personal |
| Giải trí | Entertainment | movie | Lifestyle |
| Tiền nhà | Rent/Housing | home | Essential |
| Hoá đơn | Bills/Utilities | receipt_long | Essential |
| Biểu gia đình | Family Gifts | family_restroom | Personal |
| Giáo dục | Education | school | Development |
| TẾT | Lunar New Year | celebration | Seasonal |
| Quà vật | Gifts | card_giftcard | Personal |
| Tạp hoá | Groceries | local_grocery_store | Essential |
| Đi lại | Transportation | commute | Essential |
| Du lịch | Travel | flight | Lifestyle |
| Cà phê | Coffee/Cafe | local_cafe | Lifestyle |

**Important Notes**:
- Categories are in Vietnamese (primary language)
- Display Vietnamese names in UI by default
- English translations for reference only
- Icon names map to Material Icons
- Color scheme to be defined in spec.md

---

## Database Architecture Decisions

### Normalized Tables Approach (APPROVED)

**Decision**: Use separate tables for Categories and ExpenseTypes instead of enums

**Rationale**:
1. **Future Flexibility**: User can add custom categories later
2. **Bilingual Support**: Store both Vietnamese (primary) and English names
3. **Better Data Integrity**: Foreign key constraints
4. **Icon/Color Management**: Centralized category metadata
5. **Migration-Friendly**: Easier to map Notion data to UUIDs

**Schema Structure**:
```
categories (14 rows - system categories)
├─ id (uuid, PK)
├─ name_vi (text) - Vietnamese name (PRIMARY)
├─ name_en (text) - English translation
├─ icon_name (text) - Material icon identifier
├─ color_hex (text) - Display color
├─ is_system (boolean) - Prevent deletion
└─ display_order (int) - UI sorting

expense_types (3 rows - fixed types)
├─ id (uuid, PK)
├─ name_vi (text) - Vietnamese name
├─ name_en (text) - English translation
├─ slug (text) - Code reference
└─ display_order (int)

expenses (main transaction table)
├─ id (uuid, PK)
├─ user_id (uuid, FK → auth.users)
├─ category_id (uuid, FK → categories)
├─ type_id (uuid, FK → expense_types)
├─ description (text)
├─ amount (decimal)
├─ date (date)
├─ note (text, optional)
├─ created_at (timestamptz)
└─ updated_at (timestamptz)
```

---

## Supabase Infrastructure Plan

### Phase 1: Supabase Setup (Milestone 4)
1. Create Supabase account and project
2. Configure database tables with RLS policies
3. Set up environment variables in Flutter
4. Implement database seed data (14 categories + 3 types)
5. Create Notion → Supabase migration script (Python)

### Phase 2: Authentication (Milestone 5)
- **Approach**: Simple email/password authentication
- **Rationale**: Keep it simple for MVP, can add OAuth later
- **Features**: Login, signup, password reset
- **Security**: Supabase Auth + RLS policies

### Phase 3: Cloud Sync (Milestone 5)
- **Pattern**: Repository pattern for clean architecture
- **Strategy**: Local-first with cloud backup
- **Offline Support**: Queue operations when offline
- **Conflict Resolution**: Last-write-wins initially

### Phase 4: Advanced Features (Milestone 6)
1. **Recurring Expenses**
   - Frequency options: daily, weekly, monthly, yearly
   - Auto-creation service (check on app open)
   - Enable/disable toggle
   
2. **Budget Tracking**
   - Set budgets per category
   - Progress indicators
   - Alerts at 80% and 100% thresholds

---

## Notion Migration Strategy

### Export Process
1. Export Notion database to CSV
2. Review CSV structure and data quality
3. Clean data if needed (dates, amounts, categories)

### Migration Script (Python)
```python
# Tools: pandas, supabase-py
# Process:
# 1. Read CSV with pandas
# 2. Map Vietnamese category names to Supabase UUIDs
# 3. Transform data to match schema
# 4. Validate all records
# 5. Bulk insert to Supabase
# 6. Verify migration success
```

### Validation Checklist
- [ ] Total expense count matches
- [ ] Sum by category matches
- [ ] Date range verification
- [ ] No missing categories
- [ ] All amounts positive
- [ ] No NULL required fields

---

## Git Workflow Strategy

### Branch Structure
```
main (stable MVP)
└── develop (integration branch for M4-7)
     ├── feature/supabase-setup
     ├── feature/authentication
     ├── feature/cloud-sync
     ├── feature/recurring-expenses
     └── feature/budget-tracking
```

### Workflow
1. Create `develop` branch from `main`
2. Create feature branches from `develop`
3. Merge features back to `develop`
4. Merge `develop` to `main` after milestone completion
5. Tag releases: v2.0.0-beta, v2.0.0, etc.

---

## Timeline Estimates

**Milestone 4: Supabase Infrastructure** (2-3 sessions)
- Supabase project setup
- Database schema + seed data
- Notion data migration
- Validation and testing

**Milestone 5: Auth + Cloud Sync** (3-4 sessions)
- Authentication screens
- Auth state management
- Repository pattern implementation
- Sync service with offline support

**Milestone 6: Advanced Features** (3-4 sessions)
- Recurring expenses (auto-creation)
- Budget tracking (per category)
- Analytics enhancements

**Milestone 7: Production Polish** (2-3 sessions)
- UI/UX improvements
- Onboarding flow
- App Store preparation
- TestFlight testing

**Total Estimated**: 10-14 sessions

---

## Key Technical Decisions

1. **Database Design**: Normalized tables (categories, expense_types separate)
2. **Authentication**: Simple email/password via Supabase Auth
3. **Sync Strategy**: Local-first with repository pattern
4. **Language**: Vietnamese primary, English secondary
5. **Categories**: Keep all 14 Notion categories exactly as-is
6. **Git Strategy**: develop + feature branches
7. **Migration Tool**: Python script with pandas + supabase-py

---

## Next Session Preparation

Before starting Milestone 4:
1. Review spec.md - full technical specification
2. Create Supabase account at supabase.com
3. Export Notion database to CSV
4. Create `develop` branch from `main`
5. Create `feature/supabase-setup` branch from `develop`

---

**Planning Session Complete**
**Ready for**: Milestone 4 - Supabase Infrastructure Setup
