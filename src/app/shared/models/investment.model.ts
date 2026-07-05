export type InvestmentType = 'CDT' | 'FUND';

export interface Investment {
  id: string;
  type: InvestmentType;
  name: string;
  amount: number;
  currentValue: number;
  interestRate: number;
  startDate: string;
  maturityDate: string;
  status: string;
}
