-- V14: Update credentials to real user data
UPDATE users SET 
  email = 'cliente@zenpay.com', 
  password = '$2b$10$FUrg/sN.027JK8rIlaj5Ru0.M764cyowm5mJybMRg7MWLCAYOcIzK',
  full_name = 'Vanesa Gómez',
  updated_at = NOW() 
WHERE email = 'demo@zenpay.com';

UPDATE users SET 
  email = 'usuario@zenpay.com',
  password = '$2b$10$FUrg/sN.027JK8rIlaj5Ru0.M764cyowm5mJybMRg7MWLCAYOcIzK',
  full_name = 'Carlos López',
  updated_at = NOW()
WHERE email = 'demo2@zenpay.com';
