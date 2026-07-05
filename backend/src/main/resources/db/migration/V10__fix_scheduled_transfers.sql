-- V10: Fix scheduled transfers type - use SCHEDULED instead of OWN/THIRD_PARTY
-- Transfers with a future scheduled_date and PENDING status are scheduled

UPDATE transfers
SET type = 'SCHEDULED'
WHERE status = 'PENDING'
  AND scheduled_date IS NOT NULL
  AND scheduled_date > NOW()
  AND type IN ('OWN', 'THIRD_PARTY');
