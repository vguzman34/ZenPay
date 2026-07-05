export type MovementType = 'INCOME' | 'EXPENSE' | 'TRANSFER_IN' | 'TRANSFER_OUT' | 'PAYMENT' | 'RECHARGE' | 'WITHDRAWAL' | 'CARD_PAYMENT';
export type MovementStatus = 'COMPLETED' | 'PENDING' | 'FAILED' | 'CANCELLED';

export interface AccountMovement {
  id: string;
  type: MovementType;
  status: MovementStatus;
  amount: number;
  balanceBefore: number;
  balanceAfter: number;
  description: string;
  category: string;
  reference: string;
  counterparty: string;
  createdAt: string;
}
