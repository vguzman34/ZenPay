import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Atm, AtmDetail } from '../models/atm.model';

@Injectable({ providedIn: 'root' })
export class AtmService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/atms`;

  getNearestAtms(lat: number, lng: number): Observable<Atm[]> {
    return this.http.get<Atm[]>(`${this.apiUrl}/nearest`, { params: { lat, lng } });
  }

  getAtmById(id: string): Observable<AtmDetail> {
    return this.http.get<AtmDetail>(`${this.apiUrl}/${id}`);
  }

  toggleFavorite(atmId: string): Observable<void> {
    return this.http.post<void>(`${this.apiUrl}/${atmId}/favorite`, {});
  }

  getFavorites(): Observable<Atm[]> {
    return this.http.get<Atm[]>(`${this.apiUrl}/favorites`);
  }
}
