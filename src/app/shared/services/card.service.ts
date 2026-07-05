import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Card, CardLimitRequest } from '../models/card.model';

@Injectable({ providedIn: 'root' })
export class CardService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/cards`;

  getCards(): Observable<Card[]> {
    return this.http.get<Card[]>(this.apiUrl);
  }

  getCardById(id: string): Observable<Card> {
    return this.http.get<Card>(`${this.apiUrl}/${id}`);
  }

  blockCard(id: string): Observable<Card> {
    return this.http.patch<Card>(`${this.apiUrl}/${id}/block`, {});
  }

  unblockCard(id: string): Observable<Card> {
    return this.http.patch<Card>(`${this.apiUrl}/${id}/unblock`, {});
  }

  adjustLimit(id: string, request: CardLimitRequest): Observable<Card> {
    return this.http.patch<Card>(`${this.apiUrl}/${id}/limit`, request);
  }
}
