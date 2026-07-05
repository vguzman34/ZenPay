export type LoanType = 'PERSONAL' | 'VEHICLE' | 'MORTGAGE';
export type LoanStatus = 'ACTIVE' | 'PAID' | 'LATE' | 'CANCELLED';

export interface Loan {
  id: string;
  type: LoanType;
  status: LoanStatus;
  totalAmount: number;
  paidAmount: number;
  remainingAmount: number;
  totalInstallments: number;
  paidInstallments: number;
  interestRate: number;
  nextPaymentDate: string;
  nextPaymentAmount: number;
  purpose: string;
}

export interface Installment {
  id: string;
  number: number;
  amount: number;
  dueDate: string;
  paidDate: string;
  status: string;
}
