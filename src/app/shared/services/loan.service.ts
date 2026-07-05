import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Loan, Installment } from '../models/loan.model';

@Injectable({ providedIn: 'root' })
export class LoanService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/loans`;

  getLoans(): Observable<Loan[]> {
    return this.http.get<Loan[]>(this.apiUrl);
  }

  getLoanById(id: string): Observable<Loan> {
    return this.http.get<Loan>(`${this.apiUrl}/${id}`);
  }

  getInstallments(loanId: string): Observable<Installment[]> {
    return this.http.get<Installment[]>(`${this.apiUrl}/${loanId}/installments`);
  }
}
