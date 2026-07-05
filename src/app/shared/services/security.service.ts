import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface SecurityOverview {
  securityLevel: string;
  protectionStatus: string;
  lastAccess: string;
  lastActivity: string;
  securityScore: number;
  mfaEnabled: boolean;
  mfaMethod: string;
  phoneBackup: string;
  passwordLastUpdated: string;
  passwordStrength: string;
}

export interface ActiveSession {
  id: string;
  type: string;
  device: string;
  ip: string;
  location: string;
  startedAt: string;
  icon: string;
}

export interface SecurityAlert {
  id: string;
  type: string;
  description: string;
  date: string;
  location: string;
  icon: string;
}

@Injectable({ providedIn: 'root' })
export class SecurityService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/security`;

  getOverview(): Observable<SecurityOverview> {
    return this.http.get<SecurityOverview>(`${this.apiUrl}/overview`);
  }

  getActiveSessions(): Observable<ActiveSession[]> {
    return this.http.get<ActiveSession[]>(`${this.apiUrl}/sessions`);
  }

  getSecurityAlerts(): Observable<SecurityAlert[]> {
    return this.http.get<SecurityAlert[]>(`${this.apiUrl}/alerts`);
  }

  closeSession(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/sessions/${id}`);
  }

  closeAllSessions(): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/sessions`);
  }

  toggleMfa(): Observable<void> {
    return this.http.put<void>(`${this.apiUrl}/mfa`, {});
  }
}
