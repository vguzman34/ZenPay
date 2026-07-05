-- V5: Complete seed data for all modules

DO $$
DECLARE
    v_admin_id UUID;
    v_user_id UUID;
    v_admin_savings_id UUID;
    v_admin_checking_id UUID;
    v_user_savings_id UUID;
    v_beneficiary1 UUID;
    v_beneficiary2 UUID;
    v_loan1 UUID;
    v_loan2 UUID;
    v_goal1 UUID;
    v_goal2 UUID;
BEGIN
    SELECT id INTO v_admin_id FROM users WHERE email = 'vanessa@zenpay.com';
    SELECT id INTO v_user_id FROM users WHERE email = 'user@zenpay.com';
    
    SELECT id INTO v_admin_savings_id FROM accounts WHERE user_id = v_admin_id AND account_type = 'SAVINGS';
    SELECT id INTO v_admin_checking_id FROM accounts WHERE user_id = v_admin_id AND account_type = 'CHECKING';
    SELECT id INTO v_user_savings_id FROM accounts WHERE user_id = v_user_id AND account_type = 'SAVINGS';

    -- TRANSFERS: Create beneficiaries for admin
    INSERT INTO beneficiaries (id, user_id, name, account_number, bank, document_number, email, phone, alias, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'Carlos Pérez', '2000000001', 'Bancolombia', '1234567890', 'carlos@email.com', '+573001112222', 'Carlos', NOW() - INTERVAL '30 days'),
        (uuid_generate_v4(), v_admin_id, 'María García', '2000000002', 'Davivienda', '0987654321', 'maria@email.com', '+573003334444', 'María', NOW() - INTERVAL '15 days');
    
    SELECT id INTO v_beneficiary1 FROM beneficiaries WHERE user_id = v_admin_id AND name = 'Carlos Pérez';
    SELECT id INTO v_beneficiary2 FROM beneficiaries WHERE user_id = v_admin_id AND name = 'María García';

    -- TRANSFERS: Create transfer history for admin (uses origin_account_id, not user_id)
    INSERT INTO transfers (id, origin_account_id, destination_account_number, destination_bank, destination_name, amount, description, type, status, scheduled_date, completed_at, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_savings_id, '2000000001', 'Bancolombia', 'Carlos Pérez', 150000.00, 'Pago alquiler abril', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
        (uuid_generate_v4(), v_admin_checking_id, '2000000002', 'Davivienda', 'María García', 75000.00, 'Regalo cumpleaños', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
        (uuid_generate_v4(), v_admin_savings_id, '1000000002', NULL, 'Cuenta propia', 500000.00, 'Transferencia interna', 'OWN', 'COMPLETED', NULL, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
        (uuid_generate_v4(), v_admin_checking_id, '2000000001', 'Bancolombia', 'Carlos Pérez', 200000.00, 'Pago servicios', 'THIRD_PARTY', 'PENDING', NOW() + INTERVAL '5 days', NULL, NOW() - INTERVAL '2 days'),
        (uuid_generate_v4(), v_admin_savings_id, '2000000002', 'Davivienda', 'María García', 100000.00, 'Préstamo', 'THIRD_PARTY', 'SCHEDULED', NOW() + INTERVAL '15 days', NULL, NOW() - INTERVAL '1 day');

    -- PAYMENTS: Create payment history for admin
    INSERT INTO payments (id, user_id, category, provider, reference_code, amount, status, paid_at, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'ELECTRICITY', 'ENEL', 'REF-ENEL-001', 85000.00, 'COMPLETED', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
        (uuid_generate_v4(), v_admin_id, 'WATER', 'Acueducto Bogotá', 'REF-ACUE-001', 45000.00, 'COMPLETED', NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
        (uuid_generate_v4(), v_admin_id, 'INTERNET', 'Claro', 'REF-CLARO-INT-001', 120000.00, 'COMPLETED', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
        (uuid_generate_v4(), v_admin_id, 'PHONE', 'Movistar', 'REF-MOV-001', 65000.00, 'COMPLETED', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days'),
        (uuid_generate_v4(), v_admin_id, 'GAS', 'Vanti', 'REF-VANTI-001', 38000.00, 'COMPLETED', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
        (uuid_generate_v4(), v_admin_id, 'TV', 'DirecTV', 'REF-DTV-001', 95000.00, 'COMPLETED', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
        -- Pending bills
        (uuid_generate_v4(), v_admin_id, 'ELECTRICITY', 'ENEL', 'REF-ENEL-002', 92000.00, 'PENDING', NULL, NOW() - INTERVAL '2 days'),
        (uuid_generate_v4(), v_admin_id, 'WATER', 'Acueducto Bogotá', 'REF-ACUE-002', 48000.00, 'PENDING', NULL, NOW() - INTERVAL '1 day'),
        (uuid_generate_v4(), v_admin_id, 'INTERNET', 'Claro', 'REF-CLARO-INT-002', 120000.00, 'PENDING', NULL, NOW()),
        (uuid_generate_v4(), v_admin_id, 'GAS', 'Vanti', 'REF-VANTI-002', 41000.00, 'PENDING', NULL, NOW());

    -- SAVINGS GOALS: Create goals for admin
    INSERT INTO savings_goals (id, user_id, name, target_amount, current_amount, currency, deadline, icon, color_hex, category, status, created_at, updated_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'Viaje a Europa', 8000000.00, 3200000.00, 'COP', NOW() + INTERVAL '8 months', 'flight_takeoff', '#6366f1', 'TRAVEL', 'ACTIVE', NOW() - INTERVAL '6 months', NOW()),
        (uuid_generate_v4(), v_admin_id, 'Fondo de emergencia', 10000000.00, 6500000.00, 'COP', NOW() + INTERVAL '4 months', 'shield', '#10b981', 'EMERGENCY', 'ACTIVE', NOW() - INTERVAL '1 year', NOW()),
        (uuid_generate_v4(), v_admin_id, 'MacBook Pro', 12000000.00, 4800000.00, 'COP', NOW() + INTERVAL '6 months', 'laptop_mac', '#f59e0b', 'TECHNOLOGY', 'ACTIVE', NOW() - INTERVAL '3 months', NOW());
    
    SELECT id INTO v_goal1 FROM savings_goals WHERE user_id = v_admin_id AND name = 'Viaje a Europa';
    SELECT id INTO v_goal2 FROM savings_goals WHERE user_id = v_admin_id AND name = 'Fondo de emergencia';

    -- GOAL MOVEMENTS: Add deposits to goals
    INSERT INTO goal_movements (id, goal_id, amount, type, description, created_at)
    SELECT uuid_generate_v4(), id, 500000.00, 'DEPOSIT', 'Ahorro mensual', NOW() - INTERVAL '5 months'
    FROM savings_goals WHERE name = 'Viaje a Europa';
    
    INSERT INTO goal_movements (id, goal_id, amount, type, description, created_at)
    SELECT uuid_generate_v4(), id, 800000.00, 'DEPOSIT', 'Bono trabajo', NOW() - INTERVAL '3 months'
    FROM savings_goals WHERE name = 'Viaje a Europa';
    
    INSERT INTO goal_movements (id, goal_id, amount, type, description, created_at)
    SELECT uuid_generate_v4(), id, 1000000.00, 'DEPOSIT', 'Ahorro mensual', NOW() - INTERVAL '1 month'
    FROM savings_goals WHERE name = 'Viaje a Europa';

    INSERT INTO goal_movements (id, goal_id, amount, type, description, created_at)
    SELECT uuid_generate_v4(), id, 1500000.00, 'DEPOSIT', 'Ahorro inicial', NOW() - INTERVAL '11 months'
    FROM savings_goals WHERE name = 'Fondo de emergencia';
    
    INSERT INTO goal_movements (id, goal_id, amount, type, description, created_at)
    SELECT uuid_generate_v4(), id, 2000000.00, 'DEPOSIT', 'Ahorro trimestral', NOW() - INTERVAL '6 months'
    FROM savings_goals WHERE name = 'Fondo de emergencia';

    -- LOANS: Create loans for admin
    INSERT INTO loans (id, user_id, type, status, total_amount, paid_amount, remaining_amount, total_installments, paid_installments, interest_rate, next_payment_date, next_payment_amount, purpose, created_at, updated_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'PERSONAL', 'ACTIVE', 15000000.00, 4500000.00, 10500000.00, 24, 6, 16.50, NOW() + INTERVAL '10 days', 625000.00, 'Compra vehículo', NOW() - INTERVAL '6 months', NOW()),
        (uuid_generate_v4(), v_admin_id, 'CREDIT_CARD', 'ACTIVE', 8000000.00, 2400000.00, 5600000.00, 12, 3, 22.00, NOW() + INTERVAL '5 days', 750000.00, 'Consolidación deudas', NOW() - INTERVAL '3 months', NOW());
    
    SELECT id INTO v_loan1 FROM loans WHERE user_id = v_admin_id AND purpose = 'Compra vehículo';
    SELECT id INTO v_loan2 FROM loans WHERE user_id = v_admin_id AND purpose = 'Consolidación deudas';

    -- INSTALLMENTS: Create installment history for loans
    INSERT INTO installments (id, loan_id, number, amount, due_date, paid_date, status, payment_method)
    SELECT uuid_generate_v4(), id, generate_series, 625000.00, 
           NOW() - INTERVAL '6 months' + (generate_series - 1 || ' months')::interval,
           CASE WHEN generate_series <= 6 THEN NOW() - INTERVAL '6 months' + (generate_series - 1 || ' months')::interval ELSE NULL END,
           CASE WHEN generate_series <= 6 THEN 'PAID' ELSE 'PENDING' END,
           CASE WHEN generate_series <= 6 THEN 'DEBIT_AUTOMATIC' ELSE NULL END
    FROM loans, generate_series(1, 24)
    WHERE purpose = 'Compra vehículo';

    INSERT INTO installments (id, loan_id, number, amount, due_date, paid_date, status, payment_method)
    SELECT uuid_generate_v4(), id, generate_series, 750000.00,
           NOW() - INTERVAL '3 months' + (generate_series - 1 || ' months')::interval,
           CASE WHEN generate_series <= 3 THEN NOW() - INTERVAL '3 months' + (generate_series - 1 || ' months')::interval ELSE NULL END,
           CASE WHEN generate_series <= 3 THEN 'PAID' ELSE 'PENDING' END,
           CASE WHEN generate_series <= 3 THEN 'DEBIT_AUTOMATIC' ELSE NULL END
    FROM loans, generate_series(1, 12)
    WHERE purpose = 'Consolidación deudas';

    -- SECURITY ALERTS: Create security history for admin
    INSERT INTO notifications (id, user_id, title, message, type, read, reference_id, reference_type, created_at)
    VALUES
        (uuid_generate_v4(), v_admin_id, 'Nuevo inicio de sesión', 'Se detectó un inicio de sesión desde Chrome en Windows', 'SECURITY', true, NULL, NULL, NOW() - INTERVAL '20 days'),
        (uuid_generate_v4(), v_admin_id, 'Cambio de contraseña exitoso', 'Tu contraseña fue actualizada correctamente', 'SECURITY', true, NULL, NULL, NOW() - INTERVAL '15 days'),
        (uuid_generate_v4(), v_admin_id, 'Nuevo dispositivo registrado', 'iPhone 15 fue agregado a tus dispositivos de confianza', 'SECURITY', true, NULL, NULL, NOW() - INTERVAL '10 days'),
        (uuid_generate_v4(), v_admin_id, 'Inicio de sesión sospechoso', 'Se bloqueó un intento de acceso desde ubicación desconocida', 'SECURITY', false, NULL, NULL, NOW() - INTERVAL '3 days'),
        (uuid_generate_v4(), v_admin_id, 'MFA activado', 'Autenticación de dos factores habilitada exitosamente', 'SECURITY', true, NULL, NULL, NOW() - INTERVAL '1 day');

END $$;
