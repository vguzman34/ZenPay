import { AccountMovement } from './movement.model';

export type AccountType = 'SAVINGS' | 'CHECKING' | 'DIGITAL';
export type AccountStatus = 'ACTIVE' | 'FROZEN' | 'CLOSED';

export interface Account {
  id: string;
  accountNumber: string;
  accountType: AccountType;
  currency: string;
  balance: number;
  availableBalance: number;
  status: AccountStatus;
  createdAt: string;
}

export interface DashboardData {
  totalBalance: number;
  availableBalance: number;
  savingsBalance: number;
  monthlyIncome: number;
  monthlyExpenses: number;
  cashFlow: number;
  financialScore: number;
  recentActivity: AccountMovement[];
}
