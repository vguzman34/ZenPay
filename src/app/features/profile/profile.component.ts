import { Component, ViewEncapsulation, signal, OnInit, inject } from '@angular/core';
import { UserService } from '../../shared/services/user.service';
import { User } from '../../shared/models/user.model';

@Component({
  selector: 'app-profile',
  standalone: true,
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class ProfileComponent implements OnInit {
  private readonly userService = inject(UserService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly profile = signal<User | null>(null);

  ngOnInit(): void {
    this.loadProfile();
  }

  protected loadProfile(): void {
    this.loading.set(true);
    this.error.set(null);
    this.userService.getProfile().subscribe({
      next: (data) => {
        this.profile.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('No se pudo cargar el perfil.');
        this.loading.set(false);
      },
    });
  }

  protected getInitials(name: string): string {
    return name.split(' ').map(w => w.charAt(0)).join('').slice(0, 2).toUpperCase();
  }

  protected formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    return date.toLocaleDateString('es-CO', { month: 'long', year: 'numeric' });
  }
}
