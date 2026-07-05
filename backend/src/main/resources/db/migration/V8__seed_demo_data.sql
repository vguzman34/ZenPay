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
