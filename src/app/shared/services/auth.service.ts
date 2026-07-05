import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { LoginRequest, RegisterRequest, AuthResponse, RefreshTokenRequest } from '../models/auth.model';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/auth`;

  login(request: LoginRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/login`, request).pipe(
      tap(res => this.storeTokens(res))
    );
  }

  register(request: RegisterRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/register`, request).pipe(
      tap(res => this.storeTokens(res))
    );
  }

  refreshToken(request: RefreshTokenRequest): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/refresh`, request).pipe(
      tap(res => this.storeTokens(res))
    );
  }

  logout(): Observable<void> {
    const refreshToken = this.getRefreshToken();
    const headers = new HttpHeaders().set('X-Refresh-Token', refreshToken ?? '');
    return this.http.post<void>(`${this.apiUrl}/logout`, {}, { headers });
  }

  private storeTokens(res: AuthResponse): void {
    sessionStorage.setItem('access_token', res.accessToken);
    sessionStorage.setItem('refresh_token', res.refreshToken);
    sessionStorage.setItem('token_type', res.tokenType);
    sessionStorage.setItem('expires_in', String(res.expiresIn));
  }

  getToken(): string | null {
    return sessionStorage.getItem('access_token');
  }

  getRefreshToken(): string | null {
    return sessionStorage.getItem('refresh_token');
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }

  clearSession(): void {
    sessionStorage.removeItem('access_token');
    sessionStorage.removeItem('refresh_token');
    sessionStorage.removeItem('token_type');
    sessionStorage.removeItem('expires_in');
  }
}
