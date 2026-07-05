import { Component, ViewEncapsulation, signal, computed, OnInit, inject } from '@angular/core';
import { NotificationService } from '../../shared/services/notification.service';
import { Notification } from '../../shared/models/notification.model';

interface CategoryFilter {
  key: string;
  label: string;
  icon: string;
}

@Component({
  selector: 'app-notifications',
  standalone: true,
  templateUrl: './notifications.component.html',
  styleUrl: './notifications.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class NotificationsComponent implements OnInit {
  private readonly notificationService = inject(NotificationService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly activeFilter = signal<string | null>(null);
  protected readonly notifications = signal<Notification[]>([]);

  protected readonly categories: CategoryFilter[] = [
    { key: 'SECURITY', label: 'Seguridad', icon: '🔒' },
    { key: 'MOVEMENT', label: 'Movimientos', icon: '🔄' },
    { key: 'PAYMENT', label: 'Pagos', icon: '💡' },
    { key: 'GOAL', label: 'Metas', icon: '🎯' },
    { key: 'PROMO', label: 'Promociones', icon: '🎉' },
  ];

  protected readonly typeIcons: Record<string, string> = {
    SECURITY: '🔒', MOVEMENT: '🔄', PAYMENT: '💡', GOAL: '🎯', PROMO: '🎉',
  };

  protected readonly typeColors: Record<string, string> = {
    SECURITY: 'var(--color-danger)',
    MOVEMENT: 'var(--color-info)',
    PAYMENT: 'var(--color-warning)',
    GOAL: 'var(--color-success)',
    PROMO: 'var(--color-accent)',
  };

  protected readonly typeLabels: Record<string, string> = {
    SECURITY: 'Seguridad', MOVEMENT: 'Movimiento', PAYMENT: 'Pago', GOAL: 'Meta', PROMO: 'Promoción',
  };

  protected readonly filteredNotifications = computed(() => {
    const f = this.activeFilter();
    return f ? this.notifications().filter(n => n.type === f) : this.notifications();
  });

  protected readonly unreadCount = computed(() => this.notifications().filter(n => !n.read).length);

  ngOnInit(): void {
    this.loadNotifications();
  }

  protected loadNotifications(): void {
    this.loading.set(true);
    this.error.set(null);
    this.notificationService.getNotifications().subscribe({
      next: (data) => {
        this.notifications.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('No se pudieron cargar las notificaciones.');
        this.loading.set(false);
      },
    });
  }

  protected setFilter(category: string | null): void {
    this.activeFilter.set(category);
  }

  protected markAsRead(id: string): void {
    this.notifications.update(n => n.map(item => item.id === id ? { ...item, read: true } : item));
    this.notificationService.markAsRead(id).subscribe();
  }

  protected markAllAsRead(): void {
    this.notifications.update(n => n.map(item => ({ ...item, read: true })));
    this.notificationService.markAllAsRead().subscribe();
  }

  protected getPriority(type: string): string {
    return type === 'SECURITY' ? 'high' : type === 'PAYMENT' ? 'medium' : 'low';
  }

  protected formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const days = Math.floor(diff / 86400000);
    if (days === 0) return 'Hoy';
    if (days === 1) return 'Ayer';
    if (days < 7) return `Hace ${days} días`;
    return date.toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' });
  }

  protected formatTime(dateStr: string): string {
    const date = new Date(dateStr);
    return date.toLocaleTimeString('es-CO', { hour: 'numeric', minute: '2-digit', hour12: true });
  }
}
