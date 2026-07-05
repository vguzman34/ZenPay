export type NotificationType = 'MOVEMENT' | 'SECURITY' | 'PAYMENT' | 'GOAL' | 'PROMO';

export interface Notification {
  id: string;
  title: string;
  message: string;
  type: NotificationType;
  read: boolean;
  referenceId: string;
  referenceType: string;
  createdAt: string;
}
