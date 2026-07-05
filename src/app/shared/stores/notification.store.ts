import { Injectable, inject, signal, computed } from '@angular/core';
import { NotificationService } from '../services/notification.service';
import { Notification } from '../models/notification.model';

@Injectable({ providedIn: 'root' })
export class NotificationStore {
  private readonly notificationService = inject(NotificationService);

  readonly notifications = signal<Notification[]>([]);

  readonly unreadCount = computed(() => this.notifications().filter(n => !n.read).length);

  loadNotifications(): void {
    this.notificationService.getNotifications().subscribe({
      next: (data) => this.notifications.set(data)
    });
  }

  markAsRead(id: string): void {
    this.notificationService.markAsRead(id).subscribe({
      next: () => {
        this.notifications.update(notifications =>
          notifications.map(n => n.id === id ? { ...n, read: true } : n)
        );
      }
    });
  }

  markAllAsRead(): void {
    this.notificationService.markAllAsRead().subscribe({
      next: () => {
        this.notifications.update(notifications =>
          notifications.map(n => ({ ...n, read: true }))
        );
      }
    });
  }
}
