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

    -- Helper for current account balances
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

    SELECT id INTO v_admin_id FROM users WHERE email = 'demo@zenpay.com';
    SELECT id INTO v_user_id FROM users WHERE email = 'user@zenpay.com';

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

    --=============================================================================
    -- 1. MOVEMENTS: 20+ historical movements per user
    --=============================================================================

    -- Admin SAVINGS account: historical movements (oldest first)
    -- Start balance was 10000000, then income 5000000 -> 15000000 (from V2)
    -- We'll add more history from earlier dates

    -- First, fix the existing V2 movements to have proper categories and icons
    -- Then add many more

    -- Additional historical movements for admin savings
    -- (beginning from when balance was lower, building up to current)

    -- Month 1 (90 days ago)
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 5200000.00, 4800000.00, 10000000.00, 'Nómina enero', 'salary', 'NOM-2024-010', 'Employer SAS', NOW() - INTERVAL '90 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 180000.00, 10000000.00, 9982000.00, 'Supermercado Carulla', 'food', 'TXN-2024-020', 'Carulla', NOW() - INTERVAL '88 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 95000.00, 9982000.00, 9887000.00, 'Restaurante La Brasserie', 'dining', 'TXN-2024-021', 'La Brasserie', NOW() - INTERVAL '87 days'),
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

    -- Month 4 (recent, up to today)
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 5200000.00, 15807000.00, 21007000.00, 'Nómina abril', 'salary', 'NOM-2024-013', 'Employer SAS', NOW() - INTERVAL '5 days'),
        -- The V2 seed had an INCOME of 5000000 that arrived earlier, so balance before was 16007000
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 320000.00, 16007000.00, 15687000.00, 'Mercado Jumbo', 'food', 'TXN-2024-033', 'Jumbo', NOW() - INTERVAL '4 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 78000.00, 15687000.00, 15609000.00, 'Gasolina', 'transport', 'TXN-2024-034', 'Terpel', NOW() - INTERVAL '3 days'),
        (gen_random_uuid(), v_admin_savings, 'PAYMENT', 'COMPLETED', 185000.00, 15609000.00, 15424000.00, 'Factura Claro internet', 'utilities', 'PAG-2024-023', 'Claro', NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 150000.00, 15424000.00, 15274000.00, 'Spa bienestar', 'wellness', 'TXN-2024-035', 'Spa Relax', NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_admin_savings, 'EXPENSE', 'COMPLETED', 60000.00, 15274000.00, 15214000.00, 'Farmacia', 'health', 'TXN-2024-036', 'Farmatodo', NOW() - INTERVAL '12 hours'),
        (gen_random_uuid(), v_admin_savings, 'INCOME', 'COMPLETED', 180000.00, 15214000.00, 15394000.00, 'Reembolso gastos', 'other', 'NOM-2024-014', 'Employer SAS', NOW() - INTERVAL '6 hours');

    -- Update the admin savings balance to match
    UPDATE accounts SET balance = 15394000.00, available_balance = 15194000.00, updated_at = NOW() WHERE id = v_admin_savings;

    -- Admin CHECKING movements
    INSERT INTO account_movements (id, account_id, type, status, amount, balance_before, balance_after, description, category, reference, counterparty, created_at)
    VALUES
        (gen_random_uuid(), v_admin_checking, 'INCOME', 'COMPLETED', 2000000.00, 1500000.00, 3500000.00, 'Transferencia de savings', 'transfer', 'TRF-2024-040', 'Cuenta Ahorros', NOW() - INTERVAL '45 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 85000.00, 3500000.00, 3415000.00, 'Compras diarias', 'food', 'TXN-2024-040', 'D1', NOW() - INTERVAL '40 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 120000.00, 3415000.00, 3295000.00, 'Ropa deportiva', 'shopping', 'TXN-2024-041', 'Decathlon', NOW() - INTERVAL '35 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 45000.00, 3295000.00, 3250000.00, ' Parqueadero', 'transport', 'TXN-2024-042', 'Parqueadero Centro', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 95000.00, 3250000.00, 3155000.00, 'Lavandería', 'other', 'TXN-2024-043', 'Lavandería Clean', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_admin_checking, 'INCOME', 'COMPLETED', 500000.00, 3155000.00, 3655000.00, 'Pago cliente freelance', 'salary', 'FR-2024-002', 'Cliente Digital', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 75000.00, 3655000.00, 3580000.00, 'PedidosYa', 'dining', 'TXN-2024-044', 'PedidosYa', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 55000.00, 3580000.00, 3525000.00, ' transporte escolar', 'education', 'TXN-2024-045', 'Colegio', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 35000.00, 3525000.00, 3490000.00, 'Cafetería', 'dining', 'TXN-2024-046', 'Juan Valdez', NOW() - INTERVAL '8 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 18000.00, 3490000.00, 3472000.00, 'TransMilenio recarga', 'transport', 'TXN-2024-047', 'TransMilenio', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_admin_checking, 'EXPENSE', 'COMPLETED', 22000.00, 3472000.00, 3450000.00, 'Panadería', ' food', 'TXN-2024-048', 'Panadería San José', NOW() - INTERVAL '3 days'),
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

    -- User SAVINGS movements (20+ historical)
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
        (gen_random_uuid(), v_user_checking, 'EXPENSE', 'COMPLETED', 45000.00, 1170000.00, 1125000.00, 'Comida rápida', 'dining', 'TXN-2024-111', 'McDonald''s', NOW() - INTERVAL '25 days'),
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

    --=============================================================================
    -- 2. TRANSFERS: History + scheduled + beneficiaries
    --=============================================================================

    -- More beneficiaries for admin
    INSERT INTO beneficiaries (id, user_id, name, account_number, bank, document_number, email, phone, alias, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Lucía Gómez', '2000000003', 'Nequi', '1122334455', 'lucia@email.com', '+573005556666', 'Mamá', NOW() - INTERVAL '60 days'),
        (gen_random_uuid(), v_admin_id, 'Pedro Martínez', '2000000004', 'BBVA', '5544332211', 'pedro@email.com', '+573007778888', 'Pedro', NOW() - INTERVAL '45 days'),
        (gen_random_uuid(), v_admin_id, 'Ana Silva', '2000000005', 'Bancolombia', '9988776655', 'ana@email.com', '+573009990000', 'Ana', NOW() - INTERVAL '20 days');

    SELECT id INTO v_benef1 FROM beneficiaries WHERE user_id = v_admin_id AND alias = 'Carlos';
    SELECT id INTO v_benef2 FROM beneficiaries WHERE user_id = v_admin_id AND alias = 'María';
    SELECT id INTO v_benef3 FROM beneficiaries WHERE user_id = v_admin_id AND alias = 'Mamá';
    SELECT id INTO v_benef4 FROM beneficiaries WHERE user_id = v_admin_id AND alias = 'Pedro';

    -- More transfers for admin
    INSERT INTO transfers (id, origin_account_id, destination_account_number, destination_bank, destination_name, amount, description, type, status, scheduled_date, completed_at, created_at)
    VALUES
        -- Completed transfers (history)
        (gen_random_uuid(), v_admin_savings, '2000000003', 'Nequi', 'Lucía Gómez', 350000.00, 'Ayuda mensual', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
        (gen_random_uuid(), v_admin_checking, '2000000004', 'BBVA', 'Pedro Martínez', 180000.00, 'Pago deuda', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_admin_savings, '2000000005', 'Bancolombia', 'Ana Silva', 250000.00, 'Inversión conjunta', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_admin_savings, '1000000003', NULL, 'Cuenta digital propia', 200000.00, 'Para gastos diarios', 'OWN', 'COMPLETED', NULL, NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
        (gen_random_uuid(), v_admin_checking, '2000000002', 'Davivienda', 'María García', 120000.00, 'Rifa empresa', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
        -- Scheduled transfers
        (gen_random_uuid(), v_admin_savings, '2000000003', 'Nequi', 'Lucía Gómez', 350000.00, 'Ayuda mensual mayo', 'THIRD_PARTY', 'PENDING', NOW() + INTERVAL '2 days', NULL, NOW()),
        (gen_random_uuid(), v_admin_savings, '2000000001', 'Bancolombia', 'Carlos Pérez', 150000.00, 'Alquiler mayo', 'THIRD_PARTY', 'PENDING', NOW() + INTERVAL '5 days', NULL, NOW()),
        (gen_random_uuid(), v_admin_checking, '1000000001', NULL, 'Cuenta ahorros propia', 500000.00, 'Ahorro mensual mayo', 'OWN', 'PENDING', NOW() + INTERVAL '1 day', NULL, NOW()),
        (gen_random_uuid(), v_admin_savings, '2000000005', 'Bancolombia', 'Ana Silva', 250000.00, 'Inversión mayo', 'THIRD_PARTY', 'PENDING', NOW() + INTERVAL '10 days', NULL, NOW()),
        (gen_random_uuid(), v_admin_savings, '3000000001', 'Banco de Bogotá', 'Seguro del hogar', 85000.00, 'Seguro mensual', 'THIRD_PARTY', 'PENDING', NOW() + INTERVAL '15 days', NULL, NOW());

    -- Beneficiaries for user
    INSERT INTO beneficiaries (id, user_id, name, account_number, bank, document_number, email, phone, alias, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, 'Laura Jiménez', '2000000010', 'Nequi', '1112223330', 'laura@email.com', '+573001112233', 'Laura', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_user_id, 'Diego Ramírez', '2000000011', 'Davivienda', '4445556660', 'diego@email.com', '+573004445566', 'Diego', NOW() - INTERVAL '15 days');

    -- Transfers for user
    INSERT INTO transfers (id, origin_account_id, destination_account_number, destination_bank, destination_name, amount, description, type, status, scheduled_date, completed_at, created_at)
    VALUES
        (gen_random_uuid(), v_user_savings, '2000000010', 'Nequi', 'Laura Jiménez', 75000.00, 'Regalo', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_user_checking, '2000000011', 'Davivienda', 'Diego Ramírez', 150000.00, 'Deuda', 'THIRD_PARTY', 'COMPLETED', NULL, NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_user_savings, '1000000011', NULL, 'Cuenta corriente propia', 300000.00, 'Transferencia interna', 'OWN', 'COMPLETED', NULL, NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
        (gen_random_uuid(), v_user_savings, '2000000010', 'Nequi', 'Laura Jiménez', 50000.00, 'Cumpleaños Laura', 'THIRD_PARTY', 'PENDING', NOW() + INTERVAL '7 days', NULL, NOW());

    --=============================================================================
    -- 3. QR PAYMENTS: Complete history
    --=============================================================================

    INSERT INTO qr_payments (id, user_id, amount, concept, qr_code, status, expires_at, completed_at, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 45000.00, 'Café Juan Valdez', 'QR-VALDEZ-001', 'USED', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_admin_id, 120000.00, 'Restaurante La Brasserie', 'QR-BRASS-001', 'USED', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
        (gen_random_uuid(), v_admin_id, 35000.00, 'Tienda D1', 'QR-D1-001', 'USED', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
        (gen_random_uuid(), v_admin_id, 85000.00, 'Farmacia Colsubsidio', 'QR-COLS-001', 'USED', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
        (gen_random_uuid(), v_admin_id, 220000.00, 'Electrodomésticos Alkosto', 'QR-ALK-001', 'USED', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_admin_id, 32000.00, 'Panadería San José', 'QR-PAN-001', 'USED', NULL, NOW(), NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_admin_id, 150000.00, 'Pago servicios', 'QR-SERV-001', 'ACTIVE', NOW() + INTERVAL '30 days', NULL, NOW()),
        (gen_random_uuid(), v_admin_id, 280000.00, 'Curso online', 'QR-CURSO-001', 'ACTIVE', NOW() + INTERVAL '15 days', NULL, NOW());

    INSERT INTO qr_payments (id, user_id, amount, concept, qr_code, status, expires_at, completed_at, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, 18000.00, 'Café Starbucks', 'QR-STAR-001', 'USED', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_user_id, 55000.00, 'Almuerzo ejecutivo', 'QR-ALMU-001', 'USED', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_user_id, 95000.00, 'Ropa Zara', 'QR-ZARA-001', 'USED', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),
        (gen_random_uuid(), v_user_id, 42000.00, 'Supermercado', 'QR-SUPER-001', 'USED', NULL, NOW(), NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_user_id, 200000.00, 'Pago matrícula', 'QR-MAT-001', 'ACTIVE', NOW() + INTERVAL '20 days', NULL, NOW());

    -- Favorite QRs for admin
    INSERT INTO favorite_qrs (id, user_id, name, qr_data, category, times_used, last_used_at, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Juan Valdez', 'QR-VALDEZ-PERM', 'dining', 12, NOW() - INTERVAL '2 days', NOW() - INTERVAL '60 days'),
        (gen_random_uuid(), v_admin_id, 'D1 Online', 'QR-D1-PERM', 'food', 8, NOW() - INTERVAL '5 days', NOW() - INTERVAL '45 days');

    --=============================================================================
    -- 4. RECHARGES: History with operators
    --=============================================================================

    INSERT INTO recharges (id, user_id, operator, phone_number, amount, status, completed_at, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'CLARO', '+573001234567', 20000.00, 'COMPLETED', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_admin_id, 'CLARO', '+573001234567', 10000.00, 'COMPLETED', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
        (gen_random_uuid(), v_admin_id, 'MOVISTAR', '+573001234568', 30000.00, 'COMPLETED', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_admin_id, 'TIGO', '+573001234569', 15000.00, 'COMPLETED', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_admin_id, 'CLARO', '+573001234567', 50000.00, 'COMPLETED', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_admin_id, 'CLARO', '+573001234567', 20000.00, 'COMPLETED', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_admin_id, 'WOM', '+573001234570', 10000.00, 'COMPLETED', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
        (gen_random_uuid(), v_admin_id, 'CLARO', '+573001234567', 20000.00, 'COMPLETED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_admin_id, 'CLARO', '+573001234567', 5000.00, 'PENDING', NULL, NOW());

    INSERT INTO recharges (id, user_id, operator, phone_number, amount, status, completed_at, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, 'TIGO', '+573009876543', 15000.00, 'COMPLETED', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_user_id, 'TIGO', '+573009876543', 20000.00, 'COMPLETED', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days'),
        (gen_random_uuid(), v_user_id, 'TIGO', '+573009876543', 10000.00, 'COMPLETED', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
        (gen_random_uuid(), v_user_id, 'CLARO', '+573009876544', 25000.00, 'COMPLETED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');

    -- Frequent recharges for admin
    INSERT INTO frequent_recharges (id, user_id, phone_number, operator, amount, alias, times_used, last_recharged_at, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, '+573001234567', 'CLARO', 20000.00, 'Mi línea personal', 15, NOW() - INTERVAL '1 day', NOW() - INTERVAL '90 days'),
        (gen_random_uuid(), v_admin_id, '+573001234568', 'MOVISTAR', 30000.00, 'Línea trabajo', 5, NOW() - INTERVAL '20 days', NOW() - INTERVAL '60 days'),
        (gen_random_uuid(), v_admin_id, '+573001234569', 'TIGO', 15000.00, 'Herman@', 3, NOW() - INTERVAL '15 days', NOW() - INTERVAL '30 days'),
        (gen_random_uuid(), v_admin_id, '+573001234567', 'CLARO', 50000.00, 'Plan datos ilimitado', 2, NOW() - INTERVAL '10 days', NOW() - INTERVAL '30 days');

    -- Frequent recharges for user
    INSERT INTO frequent_recharges (id, user_id, phone_number, operator, amount, alias, times_used, last_recharged_at, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, '+573009876543', 'TIGO', 15000.00, 'Mi celular', 8, NOW() - INTERVAL '4 days', NOW() - INTERVAL '60 days');

    --=============================================================================
    -- 5. CASH WITHDRAWALS (retiro sin tarjeta)
    --=============================================================================

    INSERT INTO cash_withdrawals (id, user_id, code, amount, qr_code, status, expires_at, completed_at, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, '283746', 200000.00, 'QR-CW-001', 'COMPLETED', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_admin_id, '918273', 350000.00, 'QR-CW-002', 'COMPLETED', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_admin_id, '564738', 150000.00, 'QR-CW-003', 'EXPIRED', NOW() - INTERVAL '5 days', NULL, NOW() - INTERVAL '8 days'),
        (gen_random_uuid(), v_admin_id, '102938', 500000.00, 'QR-CW-004', 'ACTIVE', NOW() + INTERVAL '2 days', NULL, NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_admin_id, '746502', 100000.00, 'QR-CW-005', 'ACTIVE', NOW() + INTERVAL '1 day', NULL, NOW());

    INSERT INTO cash_withdrawals (id, user_id, code, amount, qr_code, status, expires_at, completed_at, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, '375920', 100000.00, 'QR-CW-010', 'COMPLETED', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
        (gen_random_uuid(), v_user_id, '482930', 200000.00, 'QR-CW-011', 'EXPIRED', NOW() - INTERVAL '3 days', NULL, NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_user_id, '673829', 150000.00, 'QR-CW-012', 'ACTIVE', NOW() + INTERVAL '1 day', NULL, NOW());

    --=============================================================================
    -- 6. SUPPORT TICKETS with chat messages
    --=============================================================================

    -- Tickets for admin
    INSERT INTO tickets (id, user_id, subject, description, status, priority, category, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Problema con tarjeta virtual', 'La tarjeta virtual no aparece en mi app después de generarla', 'OPEN', 'HIGH', 'tarjetas', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

    SELECT id INTO v_ticket1 FROM tickets WHERE user_id = v_admin_id AND subject = 'Problema con tarjeta virtual';

    INSERT INTO ticket_messages (id, ticket_id, sender, message, attachments, created_at)
    VALUES
        (gen_random_uuid(), v_ticket1, 'Vanessa Admin', 'Buenos días, generé una tarjeta virtual y no aparece en la sección de tarjetas. Necesito ayuda urgente.', NULL, NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_ticket1, 'Soporte ZenPay', 'Hola Vanessa, gracias por contactarnos. ¿Podrías confirmar si la tarjeta se generó correctamente y si recibiste el correo de confirmación?', NULL, NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_ticket1, 'Vanessa Admin', 'Sí, recibí el correo pero en la app no aparece. El número de referencia es VIRT-2024-001.', NULL, NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_ticket1, 'Soporte ZenPay', 'Entiendo. Estamos revisando tu caso. Por favor intenta cerrar sesión y volver a ingresar. Si el problema persiste, te contactaremos en las próximas 2 horas.', NULL, NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_ticket1, 'Vanessa Admin', 'Ya lo intenté y sigue igual. Espero su respuesta.', NULL, NOW());

    INSERT INTO tickets (id, user_id, subject, description, status, priority, category, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Solicitud aumento límite tarjeta', 'Necesito aumentar el límite de mi tarjeta Visa Infinite para un viaje', 'IN_PROGRESS', 'MEDIUM', 'tarjetas', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');

    SELECT id INTO v_ticket2 FROM tickets WHERE user_id = v_admin_id AND subject = 'Solicitud aumento límite tarjeta';

    INSERT INTO ticket_messages (id, ticket_id, sender, message, attachments, created_at)
    VALUES
        (gen_random_uuid(), v_ticket2, 'Vanessa Admin', 'Hola, voy a viajar a Europa el próximo mes y necesito aumentar el límite de mi tarjeta Visa Infinite de 10 millones a 15 millones temporalmente.', NULL, NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_ticket2, 'Soporte ZenPay', 'Hola Vanessa, hemos recibido tu solicitud. Un asesor revisará tu historial crediticio y te dará respuesta en máximo 48 horas hábiles.', NULL, NOW() - INTERVAL '4 days'),
        (gen_random_uuid(), v_ticket2, 'Soporte ZenPay', '¡Buenas noticias! Tu solicitud fue pre-aprobada. Necesitamos que confirms tu ingreso mensual y el destino del viaje para finalizar el proceso.', NULL, NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_ticket2, 'Vanessa Admin', 'Excelente. Mi ingreso mensual es de 5.2 millones y viajo a España, Francia e Italia durante 3 semanas.', NULL, NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_ticket2, 'Soporte ZenPay', 'Gracias Vanessa. Estamos procesando la actualización. Te notificaremos cuando esté listo.', NULL, NOW());

    INSERT INTO tickets (id, user_id, subject, description, status, priority, category, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Consulta sobre inversiones', 'Quiero conocer más sobre los fondos de inversión disponibles', 'RESOLVED', 'LOW', 'inversiones', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days');

    SELECT id INTO v_ticket3 FROM tickets WHERE user_id = v_admin_id AND subject = 'Consulta sobre inversiones';

    INSERT INTO ticket_messages (id, ticket_id, sender, message, attachments, created_at)
    VALUES
        (gen_random_uuid(), v_ticket3, 'Vanessa Admin', 'Hola, estoy interesada en invertir en fondos. ¿Qué opciones tienen disponibles y cuáles son los rendimientos actuales?', NULL, NOW() - INTERVAL '10 days'),
        (gen_random_uuid(), v_ticket3, 'Soporte ZenPay', 'Hola Vanessa. Actualmente ofrecemos: CDT Bancolombia (8.5% EA), Fondo Acciones Colombia (variable, +15% en el último año) y Fondo Inmobiliario (10% EA). ¿Te gustaría recibir información detallada de alguno?', NULL, NOW() - INTERVAL '9 days'),
        (gen_random_uuid(), v_ticket3, 'Vanessa Admin', 'Gracias por la info. Me interesa el Fondo Acciones Colombia. ¿Cuál es el monto mínimo de inversión?', NULL, NOW() - INTERVAL '8 days'),
        (gen_random_uuid(), v_ticket3, 'Soporte ZenPay', 'El monto mínimo es de $500,000 COP. Puedes iniciar desde la sección de inversiones en la app. ¡Quedamos atentos a cualquier otra pregunta!', NULL, NOW() - INTERVAL '7 days'),
        (gen_random_uuid(), v_ticket3, 'Vanessa Admin', 'Perfecto, ya invertí. ¡Gracias por la ayuda!', NULL, NOW() - INTERVAL '6 days');

    -- Tickets for user
    INSERT INTO tickets (id, user_id, subject, description, status, priority, category, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_user_id, 'Problema con transferencia', 'No puedo realizar una transferencia a un beneficiario nuevo', 'IN_PROGRESS', 'HIGH', 'transferencias', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days');

    SELECT id INTO v_ticket1 FROM tickets WHERE user_id = v_user_id AND subject = 'Problema con transferencia';

    INSERT INTO ticket_messages (id, ticket_id, sender, message, attachments, created_at)
    VALUES
        (gen_random_uuid(), v_ticket1, 'Test User', 'Cuando intento agregar un beneficiario nuevo me aparece "Error al validar datos". Ya intenté con 3 cuentas diferentes.', NULL, NOW() - INTERVAL '3 days'),
        (gen_random_uuid(), v_ticket1, 'Soporte ZenPay', 'Hola, gracias por reportarlo. ¿Podrías indicarnos qué tipo de cuenta estás intentando agregar y desde qué banco?', NULL, NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_ticket1, 'Test User', 'Es una cuenta de Nequi, número 3009876543.', NULL, NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_ticket1, 'Soporte ZenPay', 'Gracias. Hemos identificado el problema. Nuestro equipo de desarrollo está trabajando en una solución. Te notificaremos cuando esté corregido.', NULL, NOW() - INTERVAL '1 day');

    INSERT INTO tickets (id, user_id, subject, description, status, priority, category, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_user_id, 'Estado de cuenta mensual', 'No recibo el estado de cuenta por correo', 'RESOLVED', 'LOW', 'cuentas', NOW() - INTERVAL '15 days', NOW() - INTERVAL '12 days');

    SELECT id INTO v_ticket2 FROM tickets WHERE user_id = v_user_id AND subject = 'Estado de cuenta mensual';

    INSERT INTO ticket_messages (id, ticket_id, sender, message, attachments, created_at)
    VALUES
        (gen_random_uuid(), v_ticket2, 'Test User', 'Desde que abrí la cuenta no he recibido ningún estado de cuenta por correo.', NULL, NOW() - INTERVAL '15 days'),
        (gen_random_uuid(), v_ticket2, 'Soporte ZenPay', 'Hemos verificado tu configuración de correo. El problema era que tenías desactivada la opción de "Enviar estado de cuenta por email". Ya lo activamos y deberías recibir el próximo.', NULL, NOW() - INTERVAL '13 days'),
        (gen_random_uuid(), v_ticket2, 'Test User', '¡Gracias! Ya revisé y está activado.', NULL, NOW() - INTERVAL '12 days');

    --=============================================================================
    -- 7. FINANCIAL PROFILE + BUDGETS + PREMIUM FEATURES
    --=============================================================================

    -- Financial profiles
    INSERT INTO financial_profile (id, user_id, score, total_assets, total_debts, net_worth, monthly_income, monthly_expenses, savings_rate, credit_utilization, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 785, 65200000.00, 11200000.00, 54000000.00, 5900000.00, 3200000.00, 45.76, 25.00, NOW(), NOW()),
        (gen_random_uuid(), v_user_id, 620, 18500000.00, 5000000.00, 13500000.00, 2700000.00, 1800000.00, 33.33, 16.67, NOW(), NOW());

    -- Budgets for admin
    INSERT INTO budgets (id, user_id, category, name, allocated, spent, currency, period, start_date, end_date, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'food', 'Alimentación', 800000.00, 620000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_admin_id, 'transport', 'Transporte', 300000.00, 198000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_admin_id, 'entertainment', 'Entretenimiento', 250000.00, 185000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_admin_id, 'utilities', 'Servicios', 400000.00, 370000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_admin_id, 'shopping', 'Compras', 500000.00, 120000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_admin_id, 'health', 'Salud', 350000.00, 100000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_admin_id, 'dining', 'Restaurantes', 400000.00, 350000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW());

    -- Budgets for user
    INSERT INTO budgets (id, user_id, category, name, allocated, spent, currency, period, start_date, end_date, created_at, updated_at)
    VALUES
        (gen_random_uuid(), v_user_id, 'food', 'Alimentación', 500000.00, 280000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_user_id, 'transport', 'Transporte', 200000.00, 95000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_user_id, 'entertainment', 'Entretenimiento', 150000.00, 85000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW()),
        (gen_random_uuid(), v_user_id, 'utilities', 'Servicios', 250000.00, 160000.00, 'COP', 'MONTHLY', DATE_TRUNC('month', NOW()), DATE_TRUNC('month', NOW()) + INTERVAL '1 month', NOW(), NOW());

    -- Cashback entries for admin
    INSERT INTO cashback_entries (id, user_id, amount, description, source, status, created_at, expires_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 2500.00, 'Cashback compra Éxito', 'SUPERMARKETS', 'AVAILABLE', NOW() - INTERVAL '15 days', NOW() + INTERVAL '45 days'),
        (gen_random_uuid(), v_admin_id, 1800.00, 'Cashback restaurante', 'DINING', 'AVAILABLE', NOW() - INTERVAL '10 days', NOW() + INTERVAL '50 days'),
        (gen_random_uuid(), v_admin_id, 5000.00, 'Cashback vuelo Avianca', 'TRAVEL', 'AVAILABLE', NOW() - INTERVAL '5 days', NOW() + INTERVAL '55 days'),
        (gen_random_uuid(), v_admin_id, 1200.00, 'Cashback farmacia', 'HEALTH', 'AVAILABLE', NOW() - INTERVAL '3 days', NOW() + INTERVAL '57 days'),
        (gen_random_uuid(), v_admin_id, 3500.00, 'Cashback Zara', 'SHOPPING', 'AVAILABLE', NOW() - INTERVAL '1 day', NOW() + INTERVAL '59 days'),
        (gen_random_uuid(), v_admin_id, 1500.00, 'Cashback Uber', 'TRANSPORT', 'AVAILABLE', NOW(), NOW() + INTERVAL '60 days');

    INSERT INTO cashback_entries (id, user_id, amount, description, source, status, created_at, expires_at)
    VALUES
        (gen_random_uuid(), v_user_id, 800.00, 'Cashback mercado', 'SUPERMARKETS', 'AVAILABLE', NOW() - INTERVAL '7 days', NOW() + INTERVAL '53 days'),
        (gen_random_uuid(), v_user_id, 1200.00, 'Cashback Falabella', 'SHOPPING', 'AVAILABLE', NOW() - INTERVAL '3 days', NOW() + INTERVAL '57 days');

    -- Rewards/achievements for admin
    INSERT INTO rewards (id, user_id, name, description, icon, category, progress_current, progress_target, status, unlocked_at, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, 'Primera transferencia', 'Realiza tu primera transferencia exitosa', 'send_money', 'ONBOARDING', 1, 1, 'COMPLETED', NOW() - INTERVAL '1 year', NOW() - INTERVAL '1 year'),
        (gen_random_uuid(), v_admin_id, 'Ahorrador principiante', 'Alcanza $1,000,000 en ahorros', 'savings', 'SAVINGS', 1, 1, 'COMPLETED', NOW() - INTERVAL '6 months', NOW() - INTERVAL '6 months'),
        (gen_random_uuid(), v_admin_id, 'Viajero frecuente', 'Acumula $5,000,000 en tu meta de viaje', 'flight', 'GOALS', 3200000, 5000000, 'IN_PROGRESS', NULL, NOW() - INTERVAL '3 months'),
        (gen_random_uuid(), v_admin_id, 'Inversionista', 'Invierte en tu primer CDT o fondo', 'trending_up', 'INVESTMENTS', 2, 1, 'COMPLETED', NOW() - INTERVAL '3 months', NOW() - INTERVAL '6 months'),
        (gen_random_uuid(), v_admin_id, 'Usuario premium', 'Completa tu perfil financiero', 'stars', 'PROFILE', 100, 100, 'COMPLETED', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
        (gen_random_uuid(), v_admin_id, 'Meta alcanzada', 'Completa una meta de ahorro', 'emoji_events', 'GOALS', 0, 1, 'LOCKED', NULL, NOW()),
        (gen_random_uuid(), v_admin_id, 'Gastos controlados', 'Mantén tus gastos dentro del presupuesto por 3 meses consecutivos', 'bar_chart', 'BUDGET', 3, 3, 'COMPLETED', NOW() - INTERVAL '1 month', NOW() - INTERVAL '4 months');

    -- Rewards for user
    INSERT INTO rewards (id, user_id, name, description, icon, category, progress_current, progress_target, status, unlocked_at, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, 'Primera transferencia', 'Realiza tu primera transferencia exitosa', 'send_money', 'ONBOARDING', 1, 1, 'COMPLETED', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
        (gen_random_uuid(), v_user_id, 'Ahorrador novato', 'Crea tu primera meta de ahorro', 'savings', 'SAVINGS', 1, 1, 'COMPLETED', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months');

    -- Monthly summaries with AI insights for admin
    INSERT INTO monthly_summaries (id, user_id, year_month, total_income, total_expenses, top_category, top_category_amount, savings_amount, insight_text, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, TO_CHAR(NOW() - INTERVAL '3 months', 'YYYY-MM'), 5200000.00, 2235000.00, 'food', 580000.00, 2965000.00, 'Tus gastos en alimentación representan el 26% del total. Podrías ahorrar hasta $80,000 comprando en mercados locales.', NOW()),
        (gen_random_uuid(), v_admin_id, TO_CHAR(NOW() - INTERVAL '2 months', 'YYYY-MM'), 5200000.00, 2450000.00, 'utilities', 620000.00, 2750000.00, 'Gastaste 15% más que el mes anterior en servicios públicos. Revisa tu consumo de energía.', NOW()),
        (gen_random_uuid(), v_admin_id, TO_CHAR(NOW() - INTERVAL '1 month', 'YYYY-MM'), 5380000.00, 2370000.00, 'food', 550000.00, 3010000.00, 'Excelente! Redujiste tus gastos en entretenimiento un 20% comparado con el mes pasado. Sigue así.', NOW());

    --=============================================================================
    -- 8. MORE NOTIFICATIONS for a rich experience
    --=============================================================================

    INSERT INTO notifications (id, user_id, title, message, type, read, reference_id, reference_type, created_at)
    VALUES
        (gen_random_uuid(), v_admin_id, '💰 Cashback disponible', 'Tienes $15,800 en cashback acumulado. ¡No dejes que expire!', 'PROMOTION', false, NULL, NULL, NOW()),
        (gen_random_uuid(), v_admin_id, '📊 Resumen mensual disponible', 'Tu resumen financiero de abril ya está listo. Revisa tus hábitos de gasto.', 'INSIGHT', false, NULL, NULL, NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_admin_id, '🎯 Meta de viaje al 40%', 'Has alcanzado el 40% de tu meta "Viaje a Europa". $3,200,000 de $8,000,000 ahorrados.', 'GOAL', false, NULL, NULL, NOW() - INTERVAL '2 days'),
        (gen_random_uuid(), v_admin_id, '📈 Tu CDT ha generado intereses', 'Tu CDT Bancolombia generó $220,000 en intereses este mes.', 'INVESTMENT', false, NULL, NULL, NOW() - INTERVAL '4 days'),
        (gen_random_uuid(), v_admin_id, '🔔 Recordatorio', 'Tienes una transferencia programada para mañana por $350,000 a Lucía Gómez.', 'SCHEDULED', false, NULL, NULL, NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), v_admin_id, '💳 Tarjeta Visa a punto de cortar', 'Tu tarjeta Visa Infinite corta en 5 días. Saldo actual: $2,500,000.', 'CARD', true, NULL, NULL, NOW() - INTERVAL '6 days');

    INSERT INTO notifications (id, user_id, title, message, type, read, reference_id, reference_type, created_at)
    VALUES
        (gen_random_uuid(), v_user_id, '💰 Cashback disponible', 'Tienes $2,000 en cashback acumulado', 'PROMOTION', false, NULL, NULL, NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_user_id, '📊 Resumen mensual', 'Tu resumen financiero de abril está listo.', 'INSIGHT', false, NULL, NULL, NOW() - INTERVAL '2 days');

END $$;
