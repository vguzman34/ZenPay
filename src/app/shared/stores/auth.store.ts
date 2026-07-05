import { Injectable, inject, signal, computed } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { UserService } from '../services/user.service';
import { LoginRequest, RegisterRequest } from '../models/auth.model';
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class AuthStore {
  private readonly authService = inject(AuthService);
  private readonly userService = inject(UserService);
  private readonly router = inject(Router);

  readonly user = signal<User | null>(null);
  readonly loginError = signal<string | null>(null);

  readonly isAuthenticated = computed(() => this.authService.isLoggedIn() && this.user() !== null);

  constructor() {
    if (this.authService.isLoggedIn()) {
      this.loadUser().subscribe();
    }
  }

  login(request: LoginRequest): Observable<void> {
    this.loginError.set(null);
    return new Observable(subscriber => {
      this.authService.login(request).subscribe({
        next: () => {
          this.loadUser().subscribe({
            next: () => {
              subscriber.next();
              subscriber.complete();
            },
            error: (err) => {
              this.authService.clearSession();
              this.loginError.set('Error al cargar perfil');
              subscriber.error(err);
            }
          });
        },
        error: (err) => {
          this.authService.clearSession();
          this.loginError.set('Credenciales inválidas');
          subscriber.error(err);
        }
      });
    });
  }

  register(request: RegisterRequest): Observable<void> {
    this.loginError.set(null);
    return new Observable(subscriber => {
      this.authService.register(request).subscribe({
        next: () => {
          this.loadUser().subscribe({
            next: () => {
              subscriber.next();
              subscriber.complete();
            },
            error: (err) => {
              this.authService.clearSession();
              subscriber.error(err);
            }
          });
        },
        error: (err) => {
          this.authService.clearSession();
          subscriber.error(err);
        }
      });
    });
  }

  logout(): void {
    this.authService.logout().subscribe({
      complete: () => {
        this.authService.clearSession();
        this.user.set(null);
        this.router.navigate(['/login']);
      },
      error: () => {
        this.authService.clearSession();
        this.user.set(null);
        this.router.navigate(['/login']);
      }
    });
  }

  refresh(): void {
    const refreshToken = this.authService.getRefreshToken();
    if (refreshToken) {
      this.authService.refreshToken({ refreshToken }).subscribe({
        next: () => {
          this.loadUser().subscribe();
        },
        error: () => {
          this.authService.clearSession();
          this.user.set(null);
          this.router.navigate(['/login']);
        }
      });
    }
  }

  loadUser(): Observable<User> {
    return this.userService.getProfile().pipe(
      tap({
        next: (user) => this.user.set(user),
        error: () => {
          this.authService.clearSession();
          this.user.set(null);
          this.router.navigate(['/login']);
        }
      })
    );
  }
}
