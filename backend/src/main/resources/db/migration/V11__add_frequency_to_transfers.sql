-- V11: Add frequency column to transfers table for scheduled/recurring transfers

ALTER TABLE transfers ADD COLUMN IF NOT EXISTS frequency VARCHAR(20) NOT NULL DEFAULT 'ONE_TIME';

-- Update seed scheduled transfers with appropriate frequencies
UPDATE transfers SET frequency = 'MONTHLY' WHERE type = 'SCHEDULED' AND description LIKE '%mayo%';
UPDATE transfers SET frequency = 'MONTHLY' WHERE type = 'SCHEDULED' AND description LIKE '%mensual%';
UPDATE transfers SET frequency = 'WEEKLY' WHERE type = 'SCHEDULED' AND description LIKE '%semanal%';
