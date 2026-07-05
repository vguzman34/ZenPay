-- V7: Fix invalid enum values in seed data
UPDATE savings_goals SET category = 'OTHER' WHERE category = 'EMERGENCY';
UPDATE savings_goals SET category = 'OTHER' WHERE category = 'TECHNOLOGY';
UPDATE loans SET type = 'PERSONAL' WHERE type = 'CREDIT_CARD';
