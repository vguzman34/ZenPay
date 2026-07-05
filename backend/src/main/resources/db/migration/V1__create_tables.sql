CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    photo_url VARCHAR(500),
    role VARCHAR(50) NOT NULL DEFAULT 'ROLE_USER',
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    account_non_locked BOOLEAN NOT NULL DEFAULT TRUE,
    mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    account_number VARCHAR(10) NOT NULL UNIQUE,
    account_type VARCHAR(50) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    balance DECIMAL(19,2) NOT NULL DEFAULT 0,
    available_balance DECIMAL(19,2) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    opened_at TIMESTAMP,
    closed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE account_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL REFERENCES accounts(id),
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'COMPLETED',
    amount DECIMAL(19,2) NOT NULL,
    balance_before DECIMAL(19,2),
    balance_after DECIMAL(19,2),
    description TEXT,
    category VARCHAR(100),
    reference VARCHAR(255),
    counterparty VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    account_id UUID NOT NULL REFERENCES accounts(id),
    card_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    card_number VARCHAR(255) NOT NULL,
    card_holder_name VARCHAR(255) NOT NULL,
    expiration_date VARCHAR(10) NOT NULL,
    cvv VARCHAR(255),
    credit_limit DECIMAL(19,2),
    used_limit DECIMAL(19,2) DEFAULT 0,
    available_limit DECIMAL(19,2),
    current_balance DECIMAL(19,2) DEFAULT 0,
    payment_date INTEGER,
    cutoff_date INTEGER,
    is_virtual BOOLEAN DEFAULT FALSE,
    issued_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    origin_account_id UUID NOT NULL REFERENCES accounts(id),
    destination_account_id UUID REFERENCES accounts(id),
    destination_account_number VARCHAR(50),
    destination_bank VARCHAR(255),
    destination_name VARCHAR(255),
    amount DECIMAL(19,2) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    scheduled_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE TABLE beneficiaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    bank VARCHAR(255),
    document_number VARCHAR(50),
    email VARCHAR(255),
    phone VARCHAR(50),
    alias VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    category VARCHAR(50) NOT NULL,
    provider VARCHAR(255) NOT NULL,
    reference_code VARCHAR(100),
    amount DECIMAL(19,2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    paid_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE qr_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(19,2) NOT NULL,
    concept VARCHAR(255),
    qr_code VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE TABLE recharges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    operator VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    total_amount DECIMAL(19,2) NOT NULL,
    paid_amount DECIMAL(19,2) DEFAULT 0,
    remaining_amount DECIMAL(19,2),
    total_installments INTEGER,
    paid_installments INTEGER DEFAULT 0,
    interest_rate DECIMAL(5,2),
    next_payment_date DATE,
    next_payment_amount DECIMAL(19,2),
    purpose TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE installments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES loans(id),
    number INTEGER NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(100)
);

CREATE TABLE savings_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    target_amount DECIMAL(19,2) NOT NULL,
    current_amount DECIMAL(19,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'COP',
    deadline DATE,
    icon VARCHAR(100),
    color_hex VARCHAR(7),
    category VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE goal_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goal_id UUID NOT NULL REFERENCES savings_goals(id),
    amount DECIMAL(19,2) NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    current_value DECIMAL(19,2),
    interest_rate DECIMAL(5,2),
    start_date DATE,
    maturity_date DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT,
    type VARCHAR(50) NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    reference_id VARCHAR(255),
    reference_type VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'OPEN',
    priority VARCHAR(50) NOT NULL DEFAULT 'MEDIUM',
    category VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMP
);

CREATE TABLE ticket_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES tickets(id),
    sender VARCHAR(255) NOT NULL,
    message TEXT,
    attachments TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    device_name VARCHAR(255),
    device_type VARCHAR(100),
    os VARCHAR(100),
    browser VARCHAR(100),
    ip_address VARCHAR(50),
    location VARCHAR(255),
    is_trusted BOOLEAN DEFAULT FALSE,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE banks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    logo_url VARCHAR(500),
    color_hex VARCHAR(7)
);

CREATE TABLE atms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bank_id UUID NOT NULL REFERENCES banks(id),
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500) NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    open_time VARCHAR(10),
    close_time VARCHAR(10),
    is_open_24_hours BOOLEAN DEFAULT FALSE,
    has_withdrawal BOOLEAN DEFAULT TRUE,
    has_deposit BOOLEAN DEFAULT TRUE,
    level VARCHAR(50)
);

CREATE TABLE atm_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    atm_id UUID NOT NULL REFERENCES atms(id),
    service VARCHAR(100) NOT NULL
);

CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    atm_id UUID NOT NULL REFERENCES atms(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, atm_id)
);

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    token TEXT,
    refresh_token TEXT,
    ip_address VARCHAR(50),
    device_info TEXT,
    last_activity_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_accounts_account_number ON accounts(account_number);
CREATE INDEX idx_account_movements_account_id ON account_movements(account_id);
CREATE INDEX idx_cards_user_id ON cards(user_id);
CREATE INDEX idx_transfers_origin_account ON transfers(origin_account_id);
CREATE INDEX idx_beneficiaries_user_id ON beneficiaries(user_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_loans_user_id ON loans(user_id);
CREATE INDEX idx_installments_loan_id ON installments(loan_id);
CREATE INDEX idx_savings_goals_user_id ON savings_goals(user_id);
CREATE INDEX idx_investments_user_id ON investments(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_tickets_user_id ON tickets(user_id);
CREATE INDEX idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);
CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_atms_bank_id ON atms(bank_id);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_refresh_token ON sessions(refresh_token);
