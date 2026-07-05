export type Operator = 'CLARO' | 'MOVISTAR' | 'TIGO' | 'WOM' | 'ETB';

export interface RechargeRequest {
  operator: Operator;
  phoneNumber: string;
  amount: number;
}

export interface Recharge {
  id: string;
  operator: Operator;
  phoneNumber: string;
  amount: number;
  status: string;
  createdAt: string;
}
