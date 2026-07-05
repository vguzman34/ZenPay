CREATE TABLE cash_withdrawals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    code VARCHAR(6) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    qr_code TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE INDEX idx_cash_withdrawals_user ON cash_withdrawals(user_id);
CREATE INDEX idx_cash_withdrawals_code ON cash_withdrawals(code);
CREATE INDEX idx_cash_withdrawals_status ON cash_withdrawals(status);
