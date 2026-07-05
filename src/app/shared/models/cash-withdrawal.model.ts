export type CashWithdrawalStatus = 'ACTIVE' | 'COMPLETED' | 'EXPIRED' | 'CANCELLED';

export interface CashWithdrawalRequest {
  amount: number;
}

export interface CashWithdrawal {
  id: string;
  code: string;
  amount: number;
  qrCode: string;
  status: CashWithdrawalStatus;
  expiresAt: string;
  createdAt: string;
}
