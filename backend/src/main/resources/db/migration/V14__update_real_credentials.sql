-- V14: Update credentials to real user data
UPDATE users SET 
  email = 'cliente@zenpay.com', 
  password = '$2b$10$TyADFHRlFFU6NT9q3313v.2K5uqHqKjJxgYs4s4dKyItLXFjnydJm',
  full_name = 'Vanesa Gómez',
  updated_at = NOW() 
WHERE email = 'demo@zenpay.com';

UPDATE users SET 
  email = 'usuario@zenpay.com',
  password = '$2b$10$TyADFHRlFFU6NT9q3313v.2K5uqHqKjJxgYs4s4dKyItLXFjnydJm',
  full_name = 'Carlos López',
  updated_at = NOW()
WHERE email = 'demo2@zenpay.com';
