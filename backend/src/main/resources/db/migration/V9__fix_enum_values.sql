-- V9: Fix enum values that don't match Java enums
-- V8 introduced values that don't exist in Java enums

UPDATE transfers SET status = 'PENDING' WHERE status = 'SCHEDULED';

UPDATE qr_payments SET status = 'USED' WHERE status = 'COMPLETED';
UPDATE qr_payments SET status = 'ACTIVE' WHERE status = 'PENDING';

UPDATE notifications SET type = 'PROMO' WHERE type = 'PROMOTION';

UPDATE cash_withdrawals SET status = 'COMPLETED' WHERE status = 'USED';
