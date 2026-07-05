export type TransferType = 'OWN' | 'THIRD_PARTY' | 'SCHEDULED' | 'RECURRENT' | 'INTERNATIONAL';
export type TransferStatus = 'COMPLETED' | 'PENDING' | 'FAILED' | 'CANCELLED';
export type TransferFrequency = 'ONE_TIME' | 'WEEKLY' | 'BIWEEKLY' | 'MONTHLY';

export interface TransferRequest {
  destinationAccountNumber: string;
  destinationBank: string;
  destinationName: string;
  amount: number;
  description: string;
  type: TransferType;
  scheduledDate?: string;
}

export interface Transfer {
  id: string;
  amount: number;
  description: string;
  type: TransferType;
  status: TransferStatus;
  destinationName: string;
  destinationBank: string;
  destinationAccountNumber: string;
  scheduledDate: string;
  frequency: TransferFrequency;
  createdAt: string;
}

export interface Beneficiary {
  id: string;
  name: string;
  accountNumber: string;
  bank: string;
  alias: string;
  createdAt: string;
}

export interface BeneficiaryRequest {
  name: string;
  accountNumber: string;
  bank: string;
  documentNumber: string;
  email: string;
  phone: string;
  alias: string;
}
