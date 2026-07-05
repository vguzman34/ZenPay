-- V6: Fix invalid transfer status values
UPDATE transfers SET status = 'PENDING' WHERE status = 'SCHEDULED';
