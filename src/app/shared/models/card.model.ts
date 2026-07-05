export type CardType = 'VISA_INFINITE' | 'MASTERCARD_BLACK' | 'DEBIT_PREMIUM' | 'VIRTUAL';
export type CardStatus = 'ACTIVE' | 'BLOCKED' | 'SUSPENDED' | 'CANCELLED';

export interface Card {
  id: string;
  cardType: CardType;
  status: CardStatus;
  cardNumber: string;
  cardHolderName: string;
  expirationDate: string;
  creditLimit: number;
  usedLimit: number;
  availableLimit: number;
  currentBalance: number;
  paymentDate: number;
  cutoffDate: number;
  isVirtual: boolean;
  issuedAt: string;
}

export interface CardLimitRequest {
  creditLimit: number;
}
