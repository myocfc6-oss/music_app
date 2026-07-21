-- ============================================
-- Sonus Music App - Create Admin User
-- Run this in Supabase SQL Editor
-- ============================================
-- Option 1: Promote an existing user to admin
-- Replace 'your-email@example.com' with the email you registered with
-- ============================================

UPDATE public.User_tbl
SET role = 'admin'
WHERE email = 'your-email@example.com';

-- ============================================
-- Option 2: Insert a test admin user directly
-- (Use this if you haven't registered yet)
-- The user_id below is a placeholder — replace it
-- with the UUID from Supabase Auth after registration
-- ============================================

-- INSERT INTO public.User_tbl (user_id, name, email, password, role)
-- VALUES (
--   'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
--   'Admin',
--   'admin@sonus.com',
--   '',
--   'admin'
-- );

-- ============================================
-- Verify: Check all users and their roles
-- ============================================

SELECT user_id, name, email, role, created_at
FROM public.User_tbl
ORDER BY created_at DESC;
