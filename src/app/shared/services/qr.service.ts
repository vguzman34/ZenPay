import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { QrGenerateRequest, QrPayment } from '../models/qr.model';

@Injectable({ providedIn: 'root' })
export class QrService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/qr`;

  generateQr(request: QrGenerateRequest): Observable<QrPayment> {
    return this.http.post<QrPayment>(`${this.apiUrl}/generate`, request);
  }

  scanQr(qrCode: string): Observable<QrPayment> {
    return this.http.post<QrPayment>(`${this.apiUrl}/scan`, { qrCode });
  }

  getQrHistory(): Observable<QrPayment[]> {
    return this.http.get<QrPayment[]>(`${this.apiUrl}/history`);
  }
}
