-- ============================================
-- Expense Tracker Seed Data
-- Vietnamese Categories + Types
-- ============================================
-- Execute AFTER 01_schema.sql
-- This populates system categories and expense types
-- ============================================

-- ============================================
-- SEED: categories (14 Vietnamese Categories)
-- ============================================
-- System categories from Notion database
-- is_system = true prevents user deletion

INSERT INTO categories (name_vi, name_en, icon_name, color_hex, is_system, display_order) VALUES
  ('Thực phẩm', 'Food', 'restaurant', '#FF6B6B', true, 1),
  ('Sức khỏe', 'Health', 'medical_services', '#4ECDC4', true, 2),
  ('Thời trang', 'Fashion', 'checkroom', '#95E1D3', true, 3),
  ('Giải trí', 'Entertainment', 'movie', '#F38181', true, 4),
  ('Tiền nhà', 'Housing', 'home', '#AA96DA', true, 5),
  ('Hoá đơn', 'Bills', 'receipt_long', '#FCBAD3', true, 6),
  ('Biểu gia đình', 'Family', 'family_restroom', '#A8D8EA', true, 7),
  ('Giáo dục', 'Education', 'school', '#FFCB85', true, 8),
  ('TẾT', 'Tet Holiday', 'celebration', '#FF6B6B', true, 9),
  ('Quà vật', 'Gifts', 'card_giftcard', '#FFE66D', true, 10),
  ('Tạp hoá', 'Groceries', 'local_grocery_store', '#C7CEEA', true, 11),
  ('Đi lại', 'Transportation', 'directions_car', '#B4F8C8', true, 12),
  ('Du lịch', 'Travel', 'flight', '#FBE7C6', true, 13),
  ('Cà phê', 'Coffee', 'local_cafe', '#A0E7E5', true, 14)
ON CONFLICT DO NOTHING;

-- Verify categories were inserted
DO $$
DECLARE
  category_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO category_count FROM categories WHERE is_system = true;
  RAISE NOTICE '✅ Inserted % system categories', category_count;
END $$;

-- ============================================
-- SEED: expense_types (3 Vietnamese Types)
-- ============================================
-- Expense type classifications from Notion

INSERT INTO expense_types (key, name_vi, name_en, color_hex) VALUES
  ('phat_sinh', 'Phát sinh', 'Incurred', '#4CAF50'),
  ('phai_chi', 'Phải chi', 'Must Pay', '#FFC107'),
  ('lang_phi', 'Lãng phí', 'Wasted', '#F44336')
ON CONFLICT (key) DO NOTHING;

-- Verify expense types were inserted
DO $$
DECLARE
  type_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO type_count FROM expense_types;
  RAISE NOTICE '✅ Inserted % expense types', type_count;
END $$;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify seed data

-- Show all categories (Vietnamese names)
-- SELECT display_order, name_vi, name_en, icon_name, color_hex
-- FROM categories
-- WHERE is_system = true
-- ORDER BY display_order;

-- Show all expense types (Vietnamese names)
-- SELECT key, name_vi, name_en, color_hex
-- FROM expense_types
-- ORDER BY key;

-- ============================================
-- END OF SEED DATA
-- ============================================
