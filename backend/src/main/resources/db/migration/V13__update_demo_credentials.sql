-- V13: Update demo user credentials to generic values
UPDATE users SET email = 'demo@zenpay.com', full_name = 'Usuario Demo' WHERE email = 'vanessa@zenpay.com';
UPDATE users SET email = 'demo2@zenpay.com', full_name = 'Demo User' WHERE email = 'user@zenpay.com';
