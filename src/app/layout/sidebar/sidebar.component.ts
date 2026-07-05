import { Component, signal, ViewEncapsulation, HostListener } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';

interface NavItem {
  label: string;
  icon: string;
  route: string;
}

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class SidebarComponent {
  protected readonly collapsed = signal(false);

  protected readonly navItems: NavItem[] = [
    { label: 'Dashboard', icon: '📊', route: '/dashboard' },
    { label: 'Cuentas', icon: '🏦', route: '/accounts' },
    { label: 'Tarjetas', icon: '💳', route: '/cards' },
    { label: 'Movimientos', icon: '📋', route: '/movements' },
    { label: 'Transferencias', icon: '🔄', route: '/transfers' },
    { label: 'Pagos QR', icon: '📱', route: '/qr' },
    { label: 'Recargas', icon: '📞', route: '/recharges' },
    { label: 'Pago Servicios', icon: '💡', route: '/payments' },
    { label: 'Metas Ahorro', icon: '🎯', route: '/savings-goals' },
    { label: 'Créditos', icon: '📈', route: '/loans' },
    { label: 'Inversiones', icon: '📊', route: '/investments' },
    { label: 'Retiro sin Tarjeta', icon: '🏧', route: '/cash-withdrawal' },
    { label: 'Asistente IA', icon: '🤖', route: '/ai-assistant' },
    { label: 'Cajeros y Bancos', icon: '🏦', route: '/atms' },
    { label: 'Soporte', icon: '💬', route: '/support' },
    { label: 'Notificaciones', icon: '🔔', route: '/notifications' },
    { label: 'Perfil', icon: '👤', route: '/profile' },
    { label: 'Seguridad', icon: '🔒', route: '/security' },
  ];

  toggleCollapsed(): void {
    this.collapsed.update(v => !v);
  }

  @HostListener('document:keydown.escape')
  closeMobile(): void {
    this.restoreBody();
  }

  private restoreBody(): void {
    document.body.classList.remove('sidebar-open');
    document.body.style.position = '';
    document.body.style.overflow = '';
    document.body.style.width = '';
  }
}
