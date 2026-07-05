import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { CashWithdrawalRequest, CashWithdrawal } from '../models/cash-withdrawal.model';

@Injectable({ providedIn: 'root' })
export class CashWithdrawalService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/cash-withdrawals`;

  generateCode(request: CashWithdrawalRequest): Observable<CashWithdrawal> {
    return this.http.post<CashWithdrawal>(`${this.apiUrl}/generate`, request);
  }

  getWithdrawals(): Observable<CashWithdrawal[]> {
    return this.http.get<CashWithdrawal[]>(this.apiUrl);
  }

  redeemCode(id: string): Observable<CashWithdrawal> {
    return this.http.post<CashWithdrawal>(`${this.apiUrl}/${id}/redeem`, {});
  }

  cancelCode(id: string): Observable<CashWithdrawal> {
    return this.http.post<CashWithdrawal>(`${this.apiUrl}/${id}/cancel`, {});
  }
}
