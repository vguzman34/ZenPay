import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { RechargeRequest, Recharge } from '../models/recharge.model';

@Injectable({ providedIn: 'root' })
export class RechargeService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/recharges`;

  createRecharge(request: RechargeRequest): Observable<Recharge> {
    return this.http.post<Recharge>(this.apiUrl, request);
  }

  getRecharges(): Observable<Recharge[]> {
    return this.http.get<Recharge[]>(this.apiUrl);
  }
}
