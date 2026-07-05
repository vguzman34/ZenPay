export type PaymentCategory = 'ELECTRICITY' | 'WATER' | 'GAS' | 'INTERNET' | 'PHONE' | 'TV' | 'OTHER';
export type PaymentStatus = 'COMPLETED' | 'PENDING' | 'FAILED' | 'CANCELLED';

export interface PaymentRequest {
  category: PaymentCategory;
  provider: string;
  referenceCode: string;
  amount: number;
}

export interface Payment {
  id: string;
  category: PaymentCategory;
  provider: string;
  referenceCode: string;
  amount: number;
  status: PaymentStatus;
  paidAt: string;
}
