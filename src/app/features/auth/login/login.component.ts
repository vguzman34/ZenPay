import { Component, signal, ViewEncapsulation, inject, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { Subscription } from 'rxjs';
import { AuthStore } from '../../../shared/stores/auth.store';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class LoginComponent implements OnDestroy {
  private readonly authStore = inject(AuthStore);
  private readonly router = inject(Router);
  private loginSub: Subscription | null = null;

  protected readonly email = signal('');
  protected readonly password = signal('');
  protected readonly loading = signal(false);
  protected readonly error = signal('');

  ngOnDestroy(): void {
    this.loginSub?.unsubscribe();
  }

  onSubmit(): void {
    this.loading.set(true);
    this.error.set('');

    if (!this.email() || !this.password()) {
      this.error.set('Por favor ingresa tu email y contraseña');
      this.loading.set(false);
      return;
    }

    this.loginSub = this.authStore.login({
      email: this.email().trim(),
      password: this.password().trim()
    }).subscribe({
      next: () => {
        this.loading.set(false);
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.loading.set(false);
        let msg = 'Error de conexión. Verifica que el servidor esté activo.';
        if (err?.status === 401) {
          msg = 'Credenciales inválidas. Intenta de nuevo.';
        } else if (err?.status === 0) {
          msg = 'No se puede conectar con el servidor. Verifica que el backend esté corriendo en el puerto 8080.';
        } else if (err?.status === 500) {
          msg = 'Error interno del servidor. Intenta más tarde.';
        } else if (err?.message) {
          msg = `Error: ${err.message}`;
        }
        this.error.set(msg);
      }
    });
  }
}
