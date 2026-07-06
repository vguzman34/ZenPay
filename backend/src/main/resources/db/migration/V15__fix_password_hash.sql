-- V15: Fix password hash for Admin123 (previous hash was incorrect)
UPDATE users SET
  password = '$2b$10$FUrg/sN.027JK8rIlaj5Ru0.M764cyowm5mJybMRg7MWLCAYOcIzK',
  updated_at = NOW()
WHERE email IN ('cliente@zenpay.com', 'usuario@zenpay.com');
