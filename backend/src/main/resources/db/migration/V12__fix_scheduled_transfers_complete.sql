-- V12: Complete fix for scheduled transfers
-- Handles all cases: fresh DBs, DBs with V10/V11, DBs without

-- Add frequency column if not present (safe if V11 already ran)
ALTER TABLE transfers ADD COLUMN IF NOT EXISTS frequency VARCHAR(20) NOT NULL DEFAULT 'ONE_TIME';

-- Fix scheduled transfer types (safe if V10 already ran)
UPDATE transfers
SET type = 'SCHEDULED'
WHERE status = 'PENDING'
  AND scheduled_date IS NOT NULL
  AND scheduled_date > NOW()
  AND type IN ('OWN', 'THIRD_PARTY');

-- Set frequency values for scheduled transfers
UPDATE transfers SET frequency = 'MONTHLY' WHERE type = 'SCHEDULED' AND (description ILIKE '%mayo%' OR description ILIKE '%mensual%');
UPDATE transfers SET frequency = 'WEEKLY' WHERE type = 'SCHEDULED' AND description ILIKE '%semanal%';

-- Add extra scheduled transfer for the admin user (5th one) to ensure enough data
DO $$
DECLARE
    v_admin_id UUID;
    v_admin_savings UUID;
    v_extra_id UUID;
BEGIN
    SELECT id INTO v_admin_id FROM users WHERE email = 'vanessa@zenpay.com';
    IF v_admin_id IS NOT NULL THEN
        SELECT id INTO v_admin_savings FROM accounts WHERE user_id = v_admin_id AND account_type = 'SAVINGS' LIMIT 1;
        IF v_admin_savings IS NOT NULL THEN
            -- Check if this transfer already exists (idempotent)
            SELECT id INTO v_extra_id FROM transfers WHERE description = 'Seguro mensual hogar' AND origin_account_id = v_admin_savings LIMIT 1;
            IF v_extra_id IS NULL THEN
                INSERT INTO transfers (id, origin_account_id, destination_account_number, destination_bank, destination_name, amount, description, type, status, frequency, scheduled_date, created_at)
                VALUES (gen_random_uuid(), v_admin_savings, '3000000001', 'Banco de Bogotá', 'Seguro del hogar', 85000.00, 'Seguro mensual hogar', 'SCHEDULED', 'PENDING', 'MONTHLY', NOW() + INTERVAL '15 days', NOW());
            END IF;
        END IF;
    END IF;
END $$;
