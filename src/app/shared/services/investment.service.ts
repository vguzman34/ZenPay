import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Investment } from '../models/investment.model';

@Injectable({ providedIn: 'root' })
export class InvestmentService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/investments`;

  getInvestments(): Observable<Investment[]> {
    return this.http.get<Investment[]>(this.apiUrl);
  }
}
