import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { BehaviorSubject, catchError, filter, switchMap, take, throwError } from 'rxjs';
import { AuthService } from '../services/auth.service';

let isRefreshing = false;
const refreshTokenSubject = new BehaviorSubject<string | null>(null);

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const isAuthRequest = req.url.includes('/auth/login') ||
                        req.url.includes('/auth/register') ||
                        req.url.includes('/auth/refresh');

  const token = authService.getToken();

  if (token && !isAuthRequest) {
    req = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
  }

  return next(req).pipe(
    catchError((error) => {
      if (error instanceof HttpErrorResponse && error.status === 401 && !isAuthRequest) {
        return handle401Error(req, next, authService, router);
      }
      return throwError(() => error);
    })
  );
};

function handle401Error(
  req: import('@angular/common/http').HttpRequest<unknown>,
  next: import('@angular/common/http').HttpHandlerFn,
  authService: AuthService,
  router: Router
) {
  if (!isRefreshing) {
    isRefreshing = true;
    refreshTokenSubject.next(null);

    const refreshToken = authService.getRefreshToken();

    if (!refreshToken) {
      authService.clearSession();
      router.navigate(['/login']);
      return throwError(() => new Error('No refresh token available'));
    }

    return authService.refreshToken({ refreshToken }).pipe(
      switchMap((res) => {
        isRefreshing = false;
        refreshTokenSubject.next(res.accessToken);
        const cloned = req.clone({
          setHeaders: { Authorization: `Bearer ${res.accessToken}` }
        });
        return next(cloned);
      }),
      catchError((err) => {
        isRefreshing = false;
        authService.clearSession();
        router.navigate(['/login']);
        return throwError(() => err);
      })
    );
  } else {
    return refreshTokenSubject.pipe(
      filter(token => token !== null),
      take(1),
      switchMap((token) => {
        const cloned = req.clone({
          setHeaders: { Authorization: `Bearer ${token}` }
        });
        return next(cloned);
      })
    );
  }
}
