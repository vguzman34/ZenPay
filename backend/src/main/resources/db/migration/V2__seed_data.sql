-- Seed admin user password: Admin123 (BCrypt hash)
INSERT INTO users (id, email, password, full_name, phone, photo_url, role, enabled, account_non_locked, last_login_at, created_at, updated_at)
VALUES
    (uuid_generate_v4(), 'cliente@zenpay.com', '$2a$10$lTdAPwuyFU4nUkRSk0W6ge2WLHk0KQxc0T9mj1vzfiUXofZKyMnDe', 'Vanesa Gómez', '+573001234567', 'https://ui-avatars.com/api/?name=Vanesa+Gomez&background=6C63FF&color=fff', 'ROLE_ADMIN', true, true, NOW(), NOW(), NOW()),
    (uuid_generate_v4(), 'usuario@zenpay.com', '$2a$10$lTdAPwuyFU4nUkRSk0W6ge2WLHk0KQxc0T9mj1vzfiUXofZKyMnDe', 'Carlos López', '+573009876543', 'https://ui-avatars.com/api/?name=Carlos+Lopez&background=FF6B6B&color=fff', 'ROLE_USER', true, true, NOW(), NOW(), NOW());

DO $$
DECLARE
    v_admin_id UUID;
    v_user_id UUID;
    v_savings_id UUID;
    v_checking_id UUID;
    v_digital_id UUID;
    v_admin_savings_id UUID;
BEGIN
    SELECT id INTO v_admin_id FROM users WHERE email = 'cliente@zenpay.com';
    SELECT id INTO v_user_id FROM users WHERE email = 'usuario@zenpay.com';

    -- Admin accounts
    INSERT INTO accounts (id, user_id, account_number, account_type, currency, balance, available_balance, status, opened_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_admin_id, '1000000001', 'SAVINGS', 'COP', 15000000.00, 14800000.00, 'ACTIVE', NOW() - INTERVAL '1 year', NOW(), NOW())
    RETURNING id INTO v_admin_savings_id;

    INSERT INTO accounts (id, user_id, account_number, account_type, currency, balance, available_balance, status, opened_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_admin_id, '1000000002', 'CHECKING', 'COP', 3500000.00, 3200000.00, 'ACTIVE', NOW() - INTERVAL '1 year', NOW(), NOW());

    INSERT INTO accounts (id, user_id, account_number, account_type, currency, balance, available_balance, status, opened_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_admin_id, '1000000003', 'DIGITAL', 'COP', 500000.00, 500000.00, 'ACTIVE', NOW() - INTERVAL '6 months', NOW(), NOW());

    -- User accounts
    INSERT INTO accounts (id, user_id, account_number, account_type, currency, balance, available_balance, status, opened_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_user_id, '1000000010', 'SAVINGS', 'COP', 5000000.00, 4900000.00, 'ACTIVE', NOW() - INTERVAL '6 months', NOW(), NOW())
    RETURNING id INTO v_savings_id;

    INSERT INTO accounts (id, user_id, account_number, account_type, currency, balance, available_balance, status, opened_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_user_id, '1000000011', 'CHECKING', 'COP', 1200000.00, 1100000.00, 'ACTIVE', NOW() - INTERVAL '3 months', NOW(), NOW())
    RETURNING id INTO v_checking_id;

    INSERT INTO accounts (id, user_id, account_number, account_type, currency, balance, available_balance, status, opened_at, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_user_id, '1000000012', 'DIGITAL', 'COP', 200000.00, 200000.00, 'ACTIVE', NOW() - INTERVAL '1 month', NOW(), NOW())
    RETURNING id INTO v_digital_id;

    -- Cards for admin
    INSERT INTO cards (id, user_id, account_id, card_type, status, card_number, card_holder_name, expiration_date, cvv, credit_limit, used_limit, available_limit, current_balance, payment_date, cutoff_date, is_virtual, issued_at, created_at, updated_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, v_admin_savings_id, 'VISA_INFINITE', 'ACTIVE', '**** **** **** 1234', 'Vanesa Gómez', '12/28', 'encrypted_123', 10000000.00, 2500000.00, 7500000.00, 2500000.00, 15, 10, false, NOW() - INTERVAL '1 year', NOW(), NOW()),
        (uuid_generate_v4(), v_admin_id, v_admin_savings_id, 'MASTERCARD_BLACK', 'ACTIVE', '**** **** **** 5678', 'Vanesa Gómez', '08/27', 'encrypted_456', 8000000.00, 1000000.00, 7000000.00, 1000000.00, 20, 15, false, NOW() - INTERVAL '6 months', NOW(), NOW());

    -- Cards for user
    INSERT INTO cards (id, user_id, account_id, card_type, status, card_number, card_holder_name, expiration_date, cvv, credit_limit, used_limit, available_limit, current_balance, payment_date, cutoff_date, is_virtual, issued_at, created_at, updated_at)
    VALUES
        (uuid_generate_v4(), v_user_id, v_savings_id, 'DEBIT_PREMIUM', 'ACTIVE', '**** **** **** 9012', 'Carlos López', '10/28', 'encrypted_789', 3000000.00, 500000.00, 2500000.00, 500000.00, 10, 5, false, NOW() - INTERVAL '3 months', NOW(), NOW()),
        (uuid_generate_v4(), v_user_id, v_digital_id, 'VIRTUAL', 'ACTIVE', '**** **** **** 3456', 'Carlos López', '06/27', 'encrypted_000', 1000000.00, 0.00, 1000000.00, 0.00, NULL, NULL, true, NOW() - INTERVAL '1 month', NOW(), NOW());

    -- Movements for admin savings account
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_savings_id, 'INCOME', 'COMPLETED', 5000000.00, 10000000.00, 15000000.00, 'Nómina mensual', 'Salario', 'NOM-2024-001', 'Employer SAS', NOW() - INTERVAL '5 days'),
        (uuid_generate_v4(), v_admin_savings_id, 'EXPENSE', 'COMPLETED', 120000.00, 15000000.00, 14880000.00, 'Supermercado Éxito', 'Alimentación', 'TXN-2024-001', 'Éxito', NOW() - INTERVAL '3 days'),
        (uuid_generate_v4(), v_admin_savings_id, 'TRANSFER_OUT', 'COMPLETED', 50000.00, 14880000.00, 14830000.00, 'Transferencia a Carlos', 'Transferencia', 'TRF-2024-001', 'Carlos Pérez', NOW() - INTERVAL '2 days'),
        (uuid_generate_v4(), v_admin_savings_id, 'PAYMENT', 'COMPLETED', 85000.00, 14830000.00, 14745000.00, 'Pago factura energía', 'Servicios', 'PAG-2024-001', 'Enelar', NOW() - INTERVAL '1 day'),
        (uuid_generate_v4(), v_admin_savings_id, 'RECHARGE', 'COMPLETED', 20000.00, 14745000.00, 14725000.00, 'Recarga Claro', 'Telefonía', 'REC-2024-001', 'CLARO', NOW());

    -- Movements for user accounts
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (uuid_generate_v4(), v_savings_id, 'INCOME', 'COMPLETED', 2000000.00, 3000000.00, 5000000.00, 'Nómina mensual', 'Salario', 'NOM-2024-002', 'Empresa XYZ', NOW() - INTERVAL '7 days'),
        (uuid_generate_v4(), v_savings_id, 'EXPENSE', 'COMPLETED', 50000.00, 5000000.00, 4950000.00, 'Restaurante', 'Alimentación', 'TXN-2024-002', 'Restaurante La Carta', NOW() - INTERVAL '4 days'),
        (uuid_generate_v4(), v_checking_id, 'INCOME', 'COMPLETED', 500000.00, 700000.00, 1200000.00, 'Pago freelance', 'Trabajo', 'FR-2024-001', 'Cliente', NOW() - INTERVAL '2 days'),
        (uuid_generate_v4(), v_checking_id, 'EXPENSE', 'COMPLETED', 75000.00, 1200000.00, 1125000.00, 'Uber viaje', 'Transporte', 'TXN-2024-003', 'Uber', NOW() - INTERVAL '1 day');

    -- Banks
    INSERT INTO banks (id, name, code, logo_url, color_hex) VALUES
        (uuid_generate_v4(), 'Bancolombia', 'BCOL', 'https://logo.clearbit.com/bancolombia.com', '#FDDA24'),
        (uuid_generate_v4(), 'Davivienda', 'DAVI', 'https://logo.clearbit.com/davivienda.com', '#004481'),
        (uuid_generate_v4(), 'Nequi', 'NEQ', 'https://logo.clearbit.com/nequi.com', '#00C853'),
        (uuid_generate_v4(), 'BBVA', 'BBVA', 'https://logo.clearbit.com/bbva.com', '#003DA5'),
        (uuid_generate_v4(), 'Scotiabank', 'SCOT', 'https://logo.clearbit.com/scotiabank.com', '#003366');

    -- ATMs in Bogota
    INSERT INTO atms (id, bank_id, name, address, latitude, longitude, open_time, close_time, is_open_24_hours, has_withdrawal, has_deposit, level) VALUES
        (uuid_generate_v4(), (SELECT id FROM banks WHERE code = 'BCOL'), 'Bancolombia Centro', 'Cra 7 # 12-15, Bogotá', 4.5981, -74.0758, '06:00', '22:00', false, true, true, 'medium'),
        (uuid_generate_v4(), (SELECT id FROM banks WHERE code = 'BCOL'), 'Bancolombia Usaquén', 'Cra 7 # 119-40, Bogotá', 4.6940, -74.0290, '07:00', '21:00', false, true, true, 'low'),
        (uuid_generate_v4(), (SELECT id FROM banks WHERE code = 'DAVI'), 'Davivienda Chapinero', 'Cra 13 # 58-20, Bogotá', 4.6230, -74.0640, '06:00', '23:00', false, true, true, 'high'),
        (uuid_generate_v4(), (SELECT id FROM banks WHERE code = 'DAVI'), 'Davivienda 7ma', 'Cra 7 # 72-50, Bogotá', 4.6580, -74.0570, '07:00', '20:00', false, true, false, 'medium'),
        (uuid_generate_v4(), (SELECT id FROM banks WHERE code = 'NEQ'), 'Nequi Zona T', 'Cra 13 # 26-45, Bogotá', 4.6140, -74.0680, '00:00', '23:59', true, true, true, 'high'),
        (uuid_generate_v4(), (SELECT id FROM banks WHERE code = 'BBVA'), 'BBVA 100', 'Cra 15 # 100-30, Bogotá', 4.6860, -74.0420, '06:00', '22:00', false, true, true, 'medium'),
        (uuid_generate_v4(), (SELECT id FROM banks WHERE code = 'SCOT'), 'Scotiabank Aeropuerto', 'Aeropuerto El Dorado, Bogotá', 4.7030, -74.1470, '00:00', '23:59', true, true, true, 'high');

    -- ATM services
    INSERT INTO atm_services (id, atm_id, service)
    SELECT uuid_generate_v4(), id, 'VISA_COMPATIBLE' FROM atms
    UNION ALL
    SELECT uuid_generate_v4(), id, 'MASTERCARD_COMPATIBLE' FROM atms
    UNION ALL
    SELECT uuid_generate_v4(), id, 'CARDLESS_WITHDRAWAL' FROM atms WHERE name LIKE '%Zona T%' OR name LIKE '%Aeropuerto%'
    UNION ALL
    SELECT uuid_generate_v4(), id, 'NIGHT_SAFE_ROUTE' FROM atms WHERE is_open_24_hours = true;

    -- Notifications for admin
    INSERT INTO notifications (id, user_id, title, message, type, read, reference_id, reference_type, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'Transferencia recibida', 'Has recibido $50,000 de Carlos Pérez', 'MOVEMENT', false, 'TRF-2024-001', 'TRANSFER', NOW() - INTERVAL '2 days'),
        (uuid_generate_v4(), v_admin_id, 'Pago exitoso', 'Pago de factura de energía por $85,000 realizado', 'PAYMENT', false, 'PAG-2024-001', 'PAYMENT', NOW() - INTERVAL '1 day'),
        (uuid_generate_v4(), v_admin_id, 'Inicio de sesión', 'Nuevo inicio de sesión desde Chrome en Windows', 'SECURITY', true, NULL, NULL, NOW() - INTERVAL '10 days'),
        (uuid_generate_v4(), v_admin_id, 'Recarga exitosa', 'Recarga Claro por $20,000 realizada con éxito', 'PAYMENT', true, 'REC-2024-001', 'RECHARGE', NOW());

    -- Notifications for user
    INSERT INTO notifications (id, user_id, title, message, type, read, reference_id, reference_type, created_at)
    VALUES
        (uuid_generate_v4(), v_user_id, 'Nómina recibida', 'Tu nómina de $2,000,000 ha sido depositada', 'MOVEMENT', false, 'NOM-2024-002', 'INCOME', NOW() - INTERVAL '7 days'),
        (uuid_generate_v4(), v_user_id, 'Objetivo de ahorro', 'Estás cerca de tu meta de viaje', 'GOAL', false, NULL, NULL, NOW() - INTERVAL '3 days');

    -- Savings goal for user (travel)
    INSERT INTO savings_goals (id, user_id, name, target_amount, current_amount, currency, deadline, icon, color_hex, category, status, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_user_id, 'Viaje a Cartagena', 3000000.00, 1800000.00, 'COP', NOW() + INTERVAL '3 months', 'flight_takeoff', '#FF6B6B', 'TRAVEL', 'ACTIVE', NOW(), NOW());

    -- Goal movement
    INSERT INTO goal_movements (id, goal_id, amount, type, description, created_at)
    SELECT uuid_generate_v4(), id, 100000.00, 'DEPOSIT', 'Ahorro semanal', NOW() - INTERVAL '1 week'
    FROM savings_goals WHERE name = 'Viaje a Cartagena';

    INSERT INTO goal_movements (id, goal_id, amount, type, description, created_at)
    SELECT uuid_generate_v4(), id, 200000.00, 'DEPOSIT', 'Bono extra', NOW() - INTERVAL '2 days'
    FROM savings_goals WHERE name = 'Viaje a Cartagena';

    -- Loans for user
    INSERT INTO loans (id, user_id, type, status, total_amount, paid_amount, remaining_amount, total_installments, paid_installments, interest_rate, next_payment_date, next_payment_amount, purpose, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_user_id, 'PERSONAL', 'ACTIVE', 5000000.00, 1500000.00, 3500000.00, 12, 3, 18.50, NOW() + INTERVAL '1 month', 500000.00, 'Remodelación de casa', NOW() - INTERVAL '3 months', NOW());

    -- Installments
    INSERT INTO installments (id, loan_id, number, amount, due_date, paid_date, status, payment_method)
    SELECT uuid_generate_v4(), id, 1, 500000.00, NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months', 'PAID', 'DEBIT_AUTOMATIC'
    FROM loans WHERE purpose = 'Remodelación de casa';

    INSERT INTO installments (id, loan_id, number, amount, due_date, paid_date, status, payment_method)
    SELECT uuid_generate_v4(), id, 2, 500000.00, NOW() - INTERVAL '1 month', NOW() - INTERVAL '25 days', 'PAID', 'DEBIT_AUTOMATIC'
    FROM loans WHERE purpose = 'Remodelación de casa';

    INSERT INTO installments (id, loan_id, number, amount, due_date, paid_date, status, payment_method)
    SELECT uuid_generate_v4(), id, 3, 500000.00, NOW(), NOW(), 'PAID', 'DEBIT_AUTOMATIC'
    FROM loans WHERE purpose = 'Remodelación de casa';

    INSERT INTO installments (id, loan_id, number, amount, due_date, paid_date, status, payment_method)
    SELECT uuid_generate_v4(), id, 4, 500000.00, NOW() + INTERVAL '1 month', NULL, 'PENDING', NULL
    FROM loans WHERE purpose = 'Remodelación de casa';

    -- Investments for admin
    INSERT INTO investments (id, user_id, type, name, amount, current_value, interest_rate, start_date, maturity_date, status, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'CDT', 'CDT Bancolombia 6M', 5000000.00, 5220000.00, 8.50, NOW() - INTERVAL '3 months', NOW() + INTERVAL '3 months', 'ACTIVE', NOW() - INTERVAL '3 months'),
        (uuid_generate_v4(), v_admin_id, 'FUND', 'Fondo Acciones Colombia', 3000000.00, 3450000.00, NULL, NOW() - INTERVAL '6 months', NULL, 'ACTIVE', NOW() - INTERVAL '6 months');

    -- Tickets
    INSERT INTO tickets (id, user_id, subject, description, status, priority, category, created_at, updated_at)
    VALUES (uuid_generate_v4(), v_user_id, 'Problema con transferencia', 'No puedo realizar una transferencia a un beneficiario nuevo', 'OPEN', 'HIGH', 'transferencias', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');

    -- Devices
    INSERT INTO devices (id, user_id, device_name, device_type, os, browser, ip_address, location, is_trusted, last_used_at, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'Mi PC', 'DESKTOP', 'Windows 11', 'Chrome', '192.168.1.100', 'Bogotá, Colombia', true, NOW(), NOW()),
        (uuid_generate_v4(), v_admin_id, 'iPhone 15', 'MOBILE', 'iOS 17', 'Safari', '192.168.1.101', 'Bogotá, Colombia', false, NOW() - INTERVAL '5 days', NOW() - INTERVAL '30 days'); aqui esta cambiala esta es v8
