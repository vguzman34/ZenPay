import { Component, ViewEncapsulation, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ThemeStore } from '../../shared/stores/theme.store';
import { AuthStore } from '../../shared/stores/auth.store';
import { NotificationStore } from '../../shared/stores/notification.store';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class NavbarComponent implements OnInit {
  protected readonly themeStore = inject(ThemeStore);
  protected readonly authStore = inject(AuthStore);
  protected readonly notificationStore = inject(NotificationStore);

  protected readonly showUserMenu = signal(false);

  ngOnInit(): void {
    this.notificationStore.loadNotifications();
  }

  toggleSidebar(): void {
    const isOpen = document.body.classList.toggle('sidebar-open');
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      document.body.style.position = 'fixed';
      document.body.style.width = '100%';
    } else {
      document.body.style.overflow = '';
      document.body.style.position = '';
      document.body.style.width = '';
    }
  }

  toggleDarkMode(): void {
    this.themeStore.toggleTheme();
  }

  toggleUserMenu(): void {
    this.showUserMenu.update(v => !v);
  }

  closeUserMenu(): void {
    this.showUserMenu.set(false);
  }

  protected getUserInitials(): string {
    const name = this.authStore.user()?.fullName;
    if (!name) return 'U';
    const parts = name.split(' ');
    return (parts[0]?.charAt(0) ?? '') + (parts[1]?.charAt(0) ?? '');
  }
}
