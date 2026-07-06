-- V8: Comprehensive demo seed data for all modules
-- Adds realistic financial data so no screen appears empty

-- New tables for premium features
CREATE TABLE IF NOT EXISTS budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    category VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    allocated DECIMAL(19,2) NOT NULL,
    spent DECIMAL(19,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'COP',
    period VARCHAR(20) NOT NULL DEFAULT 'MONTHLY',
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS financial_profile (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    score INTEGER NOT NULL DEFAULT 0,
    total_assets DECIMAL(19,2) DEFAULT 0,
    total_debts DECIMAL(19,2) DEFAULT 0,
    net_worth DECIMAL(19,2) DEFAULT 0,
    monthly_income DECIMAL(19,2) DEFAULT 0,
    monthly_expenses DECIMAL(19,2) DEFAULT 0,
    savings_rate DECIMAL(5,2) DEFAULT 0,
    credit_utilization DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cashback_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(19,2) NOT NULL,
    description TEXT,
    source VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    category VARCHAR(50),
    progress_current INTEGER DEFAULT 0,
    progress_target INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'LOCKED',
    unlocked_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS monthly_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    year_month VARCHAR(7) NOT NULL,
    total_income DECIMAL(19,2) DEFAULT 0,
    total_expenses DECIMAL(19,2) DEFAULT 0,
    top_category VARCHAR(100),
    top_category_amount DECIMAL(19,2) DEFAULT 0,
    savings_amount DECIMAL(19,2) DEFAULT 0,
    insight_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, year_month)
);

CREATE TABLE IF NOT EXISTS favorite_qrs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    qr_data TEXT NOT NULL,
    category VARCHAR(100),
    times_used INTEGER DEFAULT 0,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS frequent_recharges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    phone_number VARCHAR(20) NOT NULL,
    operator VARCHAR(50) NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    alias VARCHAR(100),
    times_used INTEGER DEFAULT 0,
    last_recharged_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
DO $$
DECLARE
    v_admin_id UUID;
    v_user_id UUID;
    v_admin_savings UUID;
    v_admin_checking UUID;
    v_admin_digital UUID;
    v_user_savings UUID;
    v_user_checking UUID;
    v_user_digital UUID;
    v_admin_card1 UUID;
    v_admin_card2 UUID;
    v_user_card1 UUID;
    v_user_card2 UUID;
    v_benef1 UUID;
    v_benef2 UUID;
    v_benef3 UUID;
    v_benef4 UUID;
    v_goal_europa UUID;
    v_goal_emergencia UUID;
    v_goal_macbook UUID;
    v_loan_vehiculo UUID;
    v_inv_cdt UUID;
    v_inv_fondo UUID;
    v_ticket1 UUID;
    v_ticket2 UUID;
    v_ticket3 UUID;
    v_qr1 UUID;
    v_fav_qr1 UUID;
    v_fav_qr2 UUID;
    v_recharge_freq1 UUID;
    v_recharge_freq2 UUID;
    v_withdrawal1 UUID;
    v_withdrawal2 UUID;
    v_withdrawal3 UUID;

    v_admin_savings_bal DECIMAL(19,2) := 15000000.00;
    v_admin_checking_bal DECIMAL(19,2) := 3500000.00;
    v_admin_digital_bal DECIMAL(19,2) := 500000.00;
    v_user_savings_bal DECIMAL(19,2) := 5000000.00;
    v_user_checking_bal DECIMAL(19,2) := 1200000.00;
    v_user_digital_bal DECIMAL(19,2) := 200000.00;

    v_ref_income INTEGER := 100;
    v_ref_expense INTEGER := 200;
    v_ref_transfer INTEGER := 300;
    v_ref_payment INTEGER := 400;
    v_ref_recharge INTEGER := 500;
    v_ref_qr INTEGER := 600;
BEGIN

    SELECT id INTO v_admin_id FROM users WHERE email = 'cliente@zenpay.com';
    SELECT id INTO v_user_id FROM users WHERE email = 'usuario@zenpay.com';
    SELECT id, balance INTO v_admin_savings, v_admin_savings_bal FROM accounts WHERE user_id = v_admin_id AND account_type = 'SAVINGS';
    SELECT id, balance INTO v_admin_checking, v_admin_checking_bal FROM accounts WHERE user_id = v_admin_id AND account_type = 'CHECKING';
    SELECT id, balance INTO v_admin_digital, v_admin_digital_bal FROM accounts WHERE user_id = v_admin_id AND account_type = 'DIGITAL';
    SELECT id, balance INTO v_user_savings, v_user_savings_bal FROM accounts WHERE user_id = v_user_id AND account_type = 'SAVINGS';
    SELECT id, balance INTO v_user_checking, v_user_checking_bal FROM accounts WHERE user_id = v_user_id AND account_type = 'CHECKING';
    SELECT id, balance INTO v_user_digital, v_user_digital_bal FROM accounts WHERE user_id = v_user_id AND account_type = 'DIGITAL';

    SELECT id INTO v_admin_card1 FROM cards WHERE user_id = v_admin_id AND card_number LIKE '%1234';
    SELECT id INTO v_admin_card2 FROM cards WHERE user_id = v_admin_id AND card_number LIKE '%5678';
    SELECT id INTO v_user_card1 FROM cards WHERE user_id = v_user_id AND card_number LIKE '%9012';
    SELECT id INTO v_user_card2 FROM cards WHERE user_id = v_user_id AND card_number LIKE '%3456';

    -- Month 1 (90 days ago)
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 5200000.00, 4800000.00, 10000000.00, 'Nómina enero', 'salary', 'NOM-2024-010', 'Employer SAS', NOW() - INTERVAL '90 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 180000.00, 10000000.00, 9982000.00, 'Supermercado Carulla', 'food', 'TXN-2024-020', 'Carulla', NOW() - INTERVAL '88 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 95000.00, 9982000.00, 9887000.00, 'Restaurante La Brasserie', 'dining', 'TXN-2024-021', 'La Brasserie', NOW() - INTERVAL '87 days');

    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_savings, 'PAYMENT', 'COMPLETED', 185000.00, 9887000.00, 9702000.00, 'Factura Claro internet', 'utilities', 'PAG-2024-020', 'Claro', NOW() - INTERVAL '85 days'),
        (gen_random_uuid(), v_admin_savings, 'TRANSFER_OUT', 'COMPLETED', 300000.00, 9702000.00, 9402000.00, 'Ahorro inversión CDT', 'savings', 'TRF-2024-020', 'CDT Bancolombia', NOW() - INTERVAL '84 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 45000.00, 9402000.00, 9357000.00, 'Netflix suscripción', 'entertainment', 'TXN-2024-022', 'Netflix', NOW() - INTERVAL '83 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 25000.00, 9357000.00, 9332000.00, 'Spotify Premium', 'entertainment', 'TXN-2024-023', 'Spotify', NOW() - INTERVAL '82 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 220000.00, 9332000.00, 9112000.00, 'Ropa Zara', 'shopping', 'TXN-2024-024', 'Zara', NOW() - INTERVAL '80 days');

    -- Month 2 (60 days ago)
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 5200000.00, 9112000.00, 14312000.00, 'Nómina febrero', 'salary', 'NOM-2024-011', 'Employer SAS', NOW() - INTERVAL '60 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 150000.00, 14312000.00, 14162000.00, 'Supermercado Éxito', 'food', 'TXN-2024-025', 'Éxito', NOW() - INTERVAL '58 days'),
        (gen_random_uuid(), v_admin_savings, 'PAYMENT', 'COMPLETED', 185000.00, 14162000.00, 13977000.00, 'Factura Claro internet', 'utilities', 'PAG-2024-021', 'Claro', NOW() - INTERVAL '55 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 120000.00, 13977000.00, 13857000.00, 'Cine + cena', 'entertainment', 'TXN-2024-026', 'Cinemark', NOW() - INTERVAL '53 days'),
        (gen_random_uuid(), v_admin_savings, 'TRANSFER_OUT', 'COMPLETED', 200000.00, 13857000.00, 13657000.00, 'Transferencia a mamá', 'family', 'TRF-2024-021', 'Lucía Gómez', NOW() - INTERVAL '52 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 350000.00, 13657000.00, 13307000.00, 'Vuelo Medellín', 'travel', 'TXN-2024-027', 'Avianca', NOW() - INTERVAL '50 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 55000.00, 13307000.00, 13252000.00, 'Gimnasio Bodytech', 'health', 'TXN-2024-028', 'Bodytech', NOW() - INTERVAL '48 days');

    -- Month 3 (30 days ago)
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 5200000.00, 13252000.00, 18452000.00, 'Nómina marzo', 'salary', 'NOM-2024-012', 'Employer SAS', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 280000.00, 18452000.00, 18172000.00, 'Mercado semanal', 'food', 'TXN-2024-029', 'Carulla', NOW() - INTERVAL '28 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 65000.00, 18172000.00, 18107000.00, 'Uber viajes', 'transport', 'TXN-2024-030', 'Uber', NOW() - INTERVAL '27 days'),
        (gen_random_uuid(), v_admin_savings, 'PAYMENT', 'COMPLETED', 185000.00, 18107000.00, 17922000.00, 'Factura Claro internet', 'utilities', 'PAG-2024-022', 'Claro', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 420000.00, 17922000.00, 17502000.00, 'Seguro médico', 'health', 'TXN-2024-031', 'Sura EPS', NOW() - INTERVAL '24 days'),
        (gen_random_uuid(), v_admin_savings, 'TRANSFER_OUT', 'COMPLETED', 1500000.00, 17502000.00, 16002000.00, 'Inversión fondo', 'investments', 'TRF-2024-022', 'Fondo Acciones', NOW() - INTERVAL '22 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 195000.00, 16002000.00, 15807000.00, 'Cena restaurante', 'dining', 'TXN-2024-032', 'Harry Sasson', NOW() - INTERVAL '20 days');
    -- Month 4 (recent)
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 5200000.00, 15807000.00, 21007000.00, 'Nómina abril', 'salary', 'NOM-2024-013', 'Employer SAS', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 320000.00, 16007000.00, 15687000.00, 'Mercado Jumbo', 'food', 'TXN-2024-033', 'Jumbo', NOW() - INTERVAL '4 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 78000.00, 15687000.00, 15609000.00, 'Gasolina', 'transport', 'TXN-2024-034', 'Terpel', NOW() - INTERVAL '3 days'),
        (gen_random_uuid(), v_admin_savings, 'PAYMENT', 'COMPLETED', 185000.00, 15609000.00, 15424000.00, 'Factura Claro internet', 'utilities', 'PAG-2024-023', 'Claro', NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 150000.00, 15424000.00, 15274000.00, 'Spa bienestar', 'wellness', 'TXN-2024-035', 'Spa Relax', NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 60000.00, 15274000.00, 15214000.00, 'Farmacia', 'health', 'TXN-2024-036', 'Farmatodo', NOW() - INTERVAL '12 hours'),
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 180000.00, 15214000.00, 15394000.00, 'Reembolso gastos', 'other', 'NOM-2024-014', 'Employer SAS', NOW() - INTERVAL '6 hours');

    UPDATE accounts SET balance = 15394000.00, available_balance = 15194000.00, updated_at = NOW() WHERE id = v_admin_savings;

    -- Admin CHECKING movements
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_checking, 'INCOME', 'COMPLETED', 2000000.00, 1500000.00, 3500000.00, 'Transferencia de savings', 'transfer', 'TRF-2024-040', 'Cuenta Ahorros', NOW() - INTERVAL '45 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 85000.00, 3500000.00, 3415000.00, 'Compras diarias', 'food', 'TXN-2024-040', 'D1', NOW() - INTERVAL '40 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 120000.00, 3415000.00, 3295000.00, 'Ropa deportiva', 'shopping', 'TXN-2024-041', 'Decathlon', NOW() - INTERVAL '35 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 45000.00, 3295000.00, 3250000.00, 'Parqueadero', 'transport', 'TXN-2024-042', 'Parqueadero Centro', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 95000.00, 3250000.00, 3155000.00, 'Lavandería', 'other', 'TXN-2024-043', 'Lavandería Clean', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_admin_checking, 'INCOME', 'COMPLETED', 500000.00, 3155000.00, 3655000.00, 'Pago cliente freelance', 'salary', 'FR-2024-002', 'Cliente Digital', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 75000.00, 3655000.00, 3580000.00, 'PedidosYa', 'dining', 'TXN-2024-044', 'PedidosYa', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 55000.00, 3580000.00, 3525000.00, 'Transporte escolar', 'education', 'TXN-2024-045', 'Colegio', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 35000.00, 3525000.00, 3490000.00, 'Cafetería', 'dining', 'TXN-2024-046', 'Juan Valdez', NOW() - INTERVAL '8 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 18000.00, 3490000.00, 3472000.00, 'TransMilenio recarga', 'transport', 'TXN-2024-047', 'TransMilenio', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 22000.00, 3472000.00, 3450000.00, 'Panadería', 'food', 'TXN-2024-048', 'Panadería San José', NOW() - INTERVAL '3 days'),
        (gen_random_uuid(), v_admin_checking, 'TRANSFER_OUT', 'COMPLETED', 50000.00, 3450000.00, 3400000.00, 'Transferencia a digital', 'transfer', 'TRF-2024-041', 'Cuenta Digital', NOW() - INTERVAL '1 day');

    UPDATE accounts SET balance = 3400000.00, available_balance = 3400000.00, updated_at = NOW() WHERE id = v_admin_checking;

    -- Admin DIGITAL movements
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_digital, 'INCOME', 'COMPLETED', 500000.00, 0.00, 500000.00, 'Apertura cuenta digital', 'transfer', 'TRF-2024-050', 'Apertura', NOW() - INTERVAL '60 days'),
        (gen_random_uuid(), v_admin_digital, 'EXPENSE', 'COMPLETED', 15000.00, 500000.00, 485000.00, 'Spotify', 'entertainment', 'TXN-2024-050', 'Spotify', NOW() - INTERVAL '55 days'),
        (gen_random_uuid(), v_admin_digital, 'EXPENSE', 'COMPLETED', 25000.00, 485000.00, 460000.00, 'Netflix', 'entertainment', 'TXN-2024-051', 'Netflix', NOW() - INTERVAL '50 days'),
        (gen_random_uuid(), v_admin_digital, 'EXPENSE', 'COMPLETED', 12000.00, 460000.00, 448000.00, 'Google One', 'technology', 'TXN-2024-052', 'Google', NOW() - INTERVAL '45 days'),
        (gen_random_uuid(), v_admin_digital, 'INCOME', 'COMPLETED', 50000.00, 448000.00, 498000.00, 'Transferencia de checking', 'transfer', 'TRF-2024-042', 'Cuenta Corriente', NOW() - INTERVAL '40 days'),
        (gen_random_uuid(), v_admin_digital, 'EXPENSE', 'COMPLETED', 15000.00, 498000.00, 483000.00, 'Disney+', 'entertainment', 'TXN-2024-053', 'Disney+', NOW() - INTERVAL '35 days'),
        (gen_random_uuid(), v_admin_digital, 'EXPENSE', 'COMPLETED', 35000.00, 483000.00, 448000.00, 'iCloud storage', 'technology', 'TXN-2024-054', 'Apple', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_admin_digital, 'EXPENSE', 'COMPLETED', 10000.00, 448000.00, 438000.00, 'HBO Max', 'entertainment', 'TXN-2024-055', 'HBO', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_admin_digital, 'INCOME', 'COMPLETED', 50000.00, 438000.00, 488000.00, 'Transferencia de checking', 'transfer', 'TRF-2024-043', 'Cuenta Corriente', NOW() - INTERVAL '1 day');

    UPDATE accounts SET balance = 488000.00, available_balance = 488000.00, updated_at = NOW() WHERE id = v_admin_digital;
    -- User SAVINGS movements
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_user_savings, 'INCOME', 'COMPLETED', 2200000.00, 2800000.00, 5000000.00, 'Nómina marzo', 'salary', 'NOM-2024-100', 'Empresa XYZ', NOW() - INTERVAL '35 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 85000.00, 5000000.00, 4915000.00, 'Mercado', 'food', 'TXN-2024-100', 'Mercado Libre', NOW() - INTERVAL '33 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 42000.00, 4915000.00, 4873000.00, 'Restaurante', 'dining', 'TXN-2024-101', 'Crepes & Waffles', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_user_savings, 'PAYMENT', 'COMPLETED', 95000.00, 4873000.00, 4778000.00, 'Factura energía', 'utilities', 'PAG-2024-100', 'Enelar', NOW() - INTERVAL '28 days'),
        (gen_random_uuid(), v_user_savings, 'TRANSFER_OUT', 'COMPLETED', 500000.00, 4778000.00, 4278000.00, 'Ahorro viaje', 'savings', 'TRF-2024-100', 'Meta Viaje', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 120000.00, 4278000.00, 4158000.00, 'Zapatos', 'shopping', 'TXN-2024-102', 'Falabella', NOW() - INTERVAL '22 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 35000.00, 4158000.00, 4123000.00, 'Uber', 'transport', 'TXN-2024-103', 'Uber', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 65000.00, 4123000.00, 4058000.00, 'Cena cumpleaños', 'dining', 'TXN-2024-104', 'Andrés DC', NOW() - INTERVAL '18 days'),
        (gen_random_uuid(), v_user_savings, 'PAYMENT', 'COMPLETED', 65000.00, 4058000.00, 3993000.00, 'Factura agua', 'utilities', 'PAG-2024-101', 'Acueducto', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_user_savings, 'INCOME', 'COMPLETED', 2200000.00, 3993000.00, 6193000.00, 'Nómina abril', 'salary', 'NOM-2024-101', 'Empresa XYZ', NOW() - INTERVAL '7 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 180000.00, 6193000.00, 6013000.00, 'Plan de datos', 'technology', 'TXN-2024-105', 'Claro', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 95000.00, 6013000.00, 5918000.00, 'Supermercado', 'food', 'TXN-2024-106', 'Éxito', NOW() - INTERVAL '4 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 55000.00, 5918000.00, 5863000.00, 'Farmacia', 'health', 'TXN-2024-107', 'Farmatodo', NOW() - INTERVAL '3 days'),
        (gen_random_uuid(), v_user_savings, 'TRANSFER_OUT', 'COMPLETED', 300000.00, 5863000.00, 5563000.00, 'Ahorro viaje', 'savings', 'TRF-2024-101', 'Meta Viaje', NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 25000.00, 5563000.00, 5538000.00, 'Netflix', 'entertainment', 'TXN-2024-108', 'Netflix', NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_user_savings, 'EXPENSE', 'COMPLETED', 15000.00, 5538000.00, 5523000.00, 'Spotify', 'entertainment', 'TXN-2024-109', 'Spotify', NOW() - INTERVAL '1 day');

    UPDATE accounts SET balance = 5523000.00, available_balance = 5423000.00, updated_at = NOW() WHERE id = v_user_savings;

    -- User CHECKING movements
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_user_checking, 'INCOME', 'COMPLETED', 800000.00, 400000.00, 1200000.00, 'Pago freelance web', 'salary', 'FR-2024-100', 'Cliente Digital', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 30000.00, 1200000.00, 1170000.00, 'Taxi', 'transport', 'TXN-2024-110', 'Taxi Express', NOW() - INTERVAL '28 days'),
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 45000.00, 1170000.00, 1125000.00, 'Comida rápida', 'dining', 'TXN-2024-111', 'McDonald\'s', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 25000.00, 1125000.00, 1100000.00, 'Café y postre', 'dining', 'TXN-2024-112', 'Juan Valdez', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_user_checking, 'INCOME', 'COMPLETED', 500000.00, 1100000.00, 1600000.00, 'Venta celular usado', 'other', 'FR-2024-101', 'Comprador', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 15000.00, 1600000.00, 1585000.00, 'Parqueadero', 'transport', 'TXN-2024-113', 'Parqueadero', NOW() - INTERVAL '12 days'),
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 85000.00, 1585000.00, 1500000.00, 'Ropa outlet', 'shopping', 'TXN-2024-114', 'Outlet Factory', NOW() - INTERVAL '8 days'),
        (gen_random_uuid(), v_user_checking, 'TRANSFER_OUT', 'COMPLETED', 100000.00, 1500000.00, 1400000.00, 'Transferencia a digital', 'transfer', 'TRF-2024-102', 'Cuenta Digital', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 35000.00, 1400000.00, 1365000.00, 'Cine', 'entertainment', 'TXN-2024-115', 'Cinemark', NOW() - INTERVAL '3 days'),
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 40000.00, 1365000.00, 1325000.00, 'Lunch ejecutivo', 'dining', 'TXN-2024-116', 'El Corral', NOW() - INTERVAL '1 day');

    UPDATE accounts SET balance = 1325000.00, available_balance = 1325000.00, updated_at = NOW() WHERE id = v_user_checking;

    -- User DIGITAL movements
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_user_digital, 'INCOME', 'COMPLETED', 200000.00, 0.00, 200000.00, 'Apertura', 'transfer', 'TRF-2024-110', 'Apertura', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_user_digital, 'EXPENSE', 'COMPLETED', 10000.00, 200000.00, 190000.00, 'HBO Max', 'entertainment', 'TXN-2024-120', 'HBO', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_user_digital, 'EXPENSE', 'COMPLETED', 22000.00, 190000.00, 168000.00, 'Prime Video', 'entertainment', 'TXN-2024-121', 'Amazon', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_user_digital, 'EXPENSE', 'COMPLETED', 15000.00, 168000.00, 153000.00, 'Apple Music', 'entertainment', 'TXN-2024-122', 'Apple', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_user_digital, 'INCOME', 'COMPLETED', 100000.00, 153000.00, 253000.00, 'Transferencia', 'transfer', 'TRF-2024-111', 'Cuenta Ahorros', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_user_digital, 'EXPENSE', 'COMPLETED', 8000.00, 253000.00, 245000.00, 'YouTube Premium', 'entertainment', 'TXN-2024-123', 'YouTube', NOW() - INTERVAL '5 days');

    UPDATE accounts SET balance = 245000.00, available_balance = 245000.00, updated_at = NOW() WHERE id = v_user_digital;
          -- Beneficiaries
    INSERT INTO beneficiaries (id, user_id, name, account_number, bank_id, bank_name, type, alias, favorite, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Carlos Pérez', '1000000099', (SELECT id FROM banks WHERE code = 'BCOL'), 'Bancolombia', 'EXTERNAL', 'Carlos', true, NOW()),
        (gen_random_uuid(), v_admin_id, 'Lucía Gómez', '2000000011', (SELECT id FROM banks WHERE code = 'NEQ'), 'Nequi', 'EXTERNAL', 'Mamá', true, NOW()),
        (gen_random_uuid(), v_admin_id, 'Pedro Martínez', '3000000022', (SELECT id FROM banks WHERE code = 'DAVI'), 'Davivienda', 'EXTERNAL', 'Pedro', false, NOW()),
        (gen_random_uuid(), v_user_id, 'María López', '4000000033', (SELECT id FROM banks WHERE code = 'BBVA'), 'BBVA', 'EXTERNAL', 'María', true, NOW());

    -- Favorite QRs
    INSERT INTO favorite_qrs (id, user_id, name, qr_data, category, times_used, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Café Juan Valdez', 'qr_juanvaldez_001', 'dining', 12, NOW()),
        (gen_random_uuid(), v_admin_id, 'Supermercado Éxito', 'qr_exito_001', 'food', 8, NOW());

    -- Frequent recharges
    INSERT INTO frequent_recharges (id, user_id, phone_number, operator, amount, alias, times_used, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, '3001234567', 'Claro', 20000.00, 'Mi número', 5, NOW()),
        (gen_random_uuid(), v_user_id, '3009876543', 'Movistar', 10000.00, 'Mi línea', 3, NOW());

    -- Cashback
    INSERT INTO cashback_entries (id, user_id, amount, description, source, status, created_at, expires_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 25000.00, 'Cashback compras supermercado', 'Éxito', 'AVAILABLE', NOW(), NOW() + INTERVAL '90 days'),
        (gen_random_uuid(), v_admin_id, 15000.00, 'Cashback combustible', 'Terpel', 'AVAILABLE', NOW(), NOW() + INTERVAL '90 days'),
        (gen_random_uuid(), v_user_id, 8000.00, 'Cashback restaurante', 'La Carta', 'AVAILABLE', NOW(), NOW() + INTERVAL '90 days');

    -- Rewards
    INSERT INTO rewards (id, user_id, name, description, icon, category, progress_current, progress_target, status, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Gastador Premium', 'Realiza 20 transacciones con tarjeta', 'credit_card', 'spending', 15, 20, 'IN_PROGRESS', NOW()),
        (gen_random_uuid(), v_admin_id, 'Ahorrador', 'Alcanza $5M en ahorros', 'savings', 'savings', 80, 100, 'IN_PROGRESS', NOW()),
        (gen_random_uuid(), v_user_id, 'Viajero', 'Ahorra $1M para tu viaje', 'flight', 'travel', 45, 100, 'IN_PROGRESS', NOW());

    -- Monthly summaries
    INSERT INTO monthly_summaries (id, user_id, year_month, total_income, total_expenses, top_category, top_category_amount, savings_amount, insight_text, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, '2026-04', 5380000.00, 2285000.00, 'Alimentación', 720000.00, 3095000.00, 'Ahorraste 58% de tus ingresos este mes', NOW()),
        (gen_random_uuid(), v_admin_id, '2026-03', 5200000.00, 3150000.00, 'Vivienda', 850000.00, 2050000.00, 'Tus gastos de vivienda aumentaron', NOW()),
        (gen_random_uuid(), v_admin_id, '2026-02', 5200000.00, 1750000.00, 'Entretenimiento', 420000.00, 3450000.00, 'Buen mes de ahorro', NOW()),
        (gen_random_uuid(), v_user_id, '2026-04', 2200000.00, 1250000.00, 'Alimentación', 380000.00, 950000.00, 'Meta de viaje cada vez más cerca', NOW());

    -- Withdrawals for admin
    INSERT INTO cash_withdrawals (id, user_id, card_id, atm_id, amount, fee, total, status, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, v_admin_card1, (SELECT id FROM atms WHERE name = 'Bancolombia Centro'), 500000.00, 4500.00, 504500.00, 'COMPLETED', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_admin_id, v_admin_card2, (SELECT id FROM atms WHERE name = 'Davivienda Chapinero'), 200000.00, 2500.00, 202500.00, 'COMPLETED', NOW() - INTERVAL '5 days');

    -- Withdrawal for user
    INSERT INTO cash_withdrawals (id, user_id, card_id, atm_id, amount, fee, total, status, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, v_user_card1, (SELECT id FROM atms WHERE name = 'Nequi Zona T'), 100000.00, 1500.00, 101500.00, 'COMPLETED', NOW() - INTERVAL '3 days');

    -- Financial profiles
    INSERT INTO financial_profile (id, user_id, score, total_assets, total_debts, net_worth, monthly_income, monthly_expenses, savings_rate, credit_utilization, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 720, 85000000.00, 15000000.00, 70000000.00, 5200000.00, 2800000.00, 46.15, 25.00, NOW()),
        (gen_random_uuid(), v_user_id, 580, 25000000.00, 8000000.00, 17000000.00, 2200000.00, 1500000.00, 31.82, 35.00, NOW());

    -- Budgets
    INSERT INTO budgets (id, user_id, category, name, allocated, spent, period, start_date, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'food', 'Alimentación', 800000.00, 620000.00, 'MONTHLY', DATE_TRUNC('month', NOW()), NOW()),
        (gen_random_uuid(), v_admin_id, 'transport', 'Transporte', 300000.00, 195000.00, 'MONTHLY', DATE_TRUNC('month', NOW()), NOW()),
        (gen_random_uuid(), v_admin_id, 'entertainment', 'Entretenimiento', 200000.00, 185000.00, 'MONTHLY', DATE_TRUNC('month', NOW()), NOW()),
        (gen_random_uuid(), v_user_id, 'food', 'Alimentación', 500000.00, 380000.00, 'MONTHLY', DATE_TRUNC('month', NOW()), NOW());

END $$;
