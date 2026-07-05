export type SavingsCategory = 'HOUSE' | 'VEHICLE' | 'TRAVEL' | 'EDUCATION' | 'OTHER';
export type GoalStatus = 'ACTIVE' | 'COMPLETED' | 'CANCELLED';

export interface SavingsGoal {
  id: string;
  name: string;
  targetAmount: number;
  currentAmount: number;
  deadline: string;
  icon: string;
  colorHex: string;
  category: SavingsCategory;
  status: GoalStatus;
  progress: number;
}

export interface GoalContributeRequest {
  amount: number;
  description: string;
}
