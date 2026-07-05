export type QrStatus = 'ACTIVE' | 'USED' | 'EXPIRED' | 'CANCELLED';

export interface QrGenerateRequest {
  amount: number;
  concept: string;
}

export interface QrPayment {
  id: string;
  qrCode: string;
  amount: number;
  concept: string;
  status: QrStatus;
  expiresAt: string;
}
