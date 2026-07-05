import { Component, ViewEncapsulation, signal, computed, OnInit, inject } from '@angular/core';
import { DatePipe } from '@angular/common';
import { DeviceService, SecurityService } from '../../shared/services';
import { Device } from '../../shared/models/device.model';
import { SecurityOverview, ActiveSession, SecurityAlert } from '../../shared/services/security.service';

@Component({
  selector: 'app-security',
  standalone: true,
  imports: [DatePipe],
  templateUrl: './security.component.html',
  styleUrl: './security.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class SecurityComponent implements OnInit {
  private readonly deviceService = inject(DeviceService);
  private readonly securityService = inject(SecurityService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly securityLevel = signal('');
  protected readonly protectionStatus = signal('');
  protected readonly lastAccess = signal('');
  protected readonly lastActivity = signal('');
  protected readonly securityScore = signal(0);

  protected readonly mfaEnabled = signal(false);
  protected readonly mfaMethod = signal('');
  protected readonly phoneBackup = signal('');

  protected readonly passwordLastUpdated = signal('');
  protected readonly passwordStrength = signal('');

  protected readonly devices = signal<Device[]>([]);
  protected readonly activeSessions = signal<ActiveSession[]>([]);
  protected readonly securityAlerts = signal<SecurityAlert[]>([]);

  protected readonly privacySettings = signal<{id: string; label: string; enabled: boolean}[]>([
    { id: 'thirdParty', label: 'Compartir datos con terceros', enabled: false },
    { id: 'marketing', label: 'Notificaciones de marketing', enabled: false },
    { id: 'publicHistory', label: 'Historial de transacciones público', enabled: false },
    { id: 'biometry', label: 'Biometría activada', enabled: true },
  ]);

  ngOnInit(): void {
    this.loadSecurityData();
    this.loadDevices();
  }

  private loadSecurityData(): void {
    this.securityService.getOverview().subscribe({
      next: (overview) => {
        this.securityLevel.set(overview.securityLevel);
        this.protectionStatus.set(overview.protectionStatus);
        this.lastAccess.set(this.formatDate(overview.lastAccess));
        this.lastActivity.set(overview.lastActivity);
        this.securityScore.set(overview.securityScore);
        this.mfaEnabled.set(overview.mfaEnabled);
        this.mfaMethod.set(overview.mfaMethod);
        this.phoneBackup.set(overview.phoneBackup);
        this.passwordLastUpdated.set(this.formatDate(overview.passwordLastUpdated));
        this.passwordStrength.set(overview.passwordStrength);
      },
      error: (err) => {
        this.error.set('Error al cargar datos de seguridad');
        console.error('Error loading security overview:', err);
      }
    });

    this.securityService.getActiveSessions().subscribe({
      next: (sessions) => this.activeSessions.set(sessions),
      error: (err) => console.error('Error loading sessions:', err)
    });

    this.securityService.getSecurityAlerts().subscribe({
      next: (alerts) => this.securityAlerts.set(alerts),
      error: (err) => console.error('Error loading alerts:', err)
    });
  }

  private loadDevices(): void {
    this.deviceService.getDevices().subscribe({
      next: (data) => {
        this.devices.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('No se pudieron cargar los dispositivos.');
        this.loading.set(false);
      },
    });
  }

  protected readonly scoreGradient = computed(() => {
    const pct = this.securityScore();
    const color = this.scoreColor();
    return `conic-gradient(${color} 0deg ${pct * 3.6}deg, var(--color-surface-alt) ${pct * 3.6}deg 360deg)`;
  });

  protected readonly scoreColor = computed(() => {
    if (this.securityScore() >= 80) return 'var(--color-success)';
    if (this.securityScore() >= 60) return 'var(--color-warning)';
    return 'var(--color-danger)';
  });

  protected getDeviceIcon(deviceType: string): string {
    const icons: Record<string, string> = { MOBILE: 'smartphone', DESKTOP: 'desktop_windows', TABLET: 'tablet', LAPTOP: 'laptop', BROWSER: 'language' };
    return icons[deviceType] ?? 'devices';
  }

  protected toggleMfa(): void {
    this.securityService.toggleMfa().subscribe({
      next: () => {
        this.mfaEnabled.update(v => !v);
      },
      error: (err) => console.error('Error toggling MFA:', err)
    });
  }

  protected togglePrivacy(settingId: string): void {
    this.privacySettings.update(settings =>
      settings.map(s => s.id === settingId ? { ...s, enabled: !s.enabled } : s)
    );
  }

  protected getStrengthPercent(): number {
    const strength = this.passwordStrength().toLowerCase();
    if (strength === 'fuerte') return 85;
    if (strength === 'moderada') return 60;
    return 30;
  }

  protected getStrengthColor(): string {
    const strength = this.passwordStrength().toLowerCase();
    if (strength === 'fuerte') return 'var(--color-success)';
    if (strength === 'moderada') return 'var(--color-warning)';
    return 'var(--color-danger)';
  }

  protected changePassword(): void {
    alert('Funcionalidad de cambio de contraseña en desarrollo');
  }

  protected configureMfa(): void {
    alert('Configuración MFA en desarrollo');
  }

  protected closeSession(id: string): void {
    this.securityService.closeSession(id).subscribe({
      next: () => {
        this.activeSessions.update(sessions => sessions.filter(s => s.id !== id));
      },
      error: (err) => console.error('Error closing session:', err)
    });
  }

  protected closeAllSessions(): void {
    if (confirm('¿Cerrar todas las sesiones activas?')) {
      this.securityService.closeAllSessions().subscribe({
        next: () => {
          this.activeSessions.set([]);
        },
        error: (err) => console.error('Error closing all sessions:', err)
      });
    }
  }

  protected removeDevice(id: string): void {
    this.deviceService.removeDevice(id).subscribe({
      next: () => this.devices.update(list => list.filter(d => d.id !== id)),
    });
  }

  protected manageData(): void {
    alert('Gestión de datos en desarrollo');
  }

  private formatDate(dateStr: string): string {
    if (!dateStr) return 'N/A';
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return 'Hoy ' + date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });
    if (diffDays === 1) return 'Ayer';
    if (diffDays < 7) return `Hace ${diffDays} días`;
    return date.toLocaleDateString('es-ES', { day: 'numeric', month: 'short', year: 'numeric' });
  }
}
