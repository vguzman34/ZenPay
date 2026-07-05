import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { TransferRequest, Transfer, Beneficiary, BeneficiaryRequest } from '../models/transfer.model';

@Injectable({ providedIn: 'root' })
export class TransferService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/transfers`;

  createTransfer(request: TransferRequest): Observable<Transfer> {
    return this.http.post<Transfer>(this.apiUrl, request);
  }

  getTransfers(): Observable<Transfer[]> {
    return this.http.get<Transfer[]>(this.apiUrl);
  }

  getBeneficiaries(): Observable<Beneficiary[]> {
    return this.http.get<Beneficiary[]>(`${environment.apiUrl}/transfers/beneficiaries`);
  }

  createBeneficiary(request: BeneficiaryRequest): Observable<Beneficiary> {
    return this.http.post<Beneficiary>(`${environment.apiUrl}/transfers/beneficiaries`, request);
  }

  cancelTransfer(id: string): Observable<void> {
    return this.http.put<void>(`${this.apiUrl}/${id}/cancel`, {});
  }

  executeScheduled(id: string): Observable<void> {
    return this.http.post<void>(`${this.apiUrl}/${id}/execute`, {});
  }
}
