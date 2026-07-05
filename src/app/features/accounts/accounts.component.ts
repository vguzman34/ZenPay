import { Component, ViewEncapsulation, OnInit, signal, computed, inject } from '@angular/core';
import { AccountService } from '../../shared/services';
import { AccountMovement as ApiAccountMovement } from '../../shared/models';

interface AccountMovement {
  date: string;
  description: string;
  amount: number;
  type: 'INCOME' | 'EXPENSE';
  status: 'COMPLETED' | 'PENDING';
}

interface Account {
  id: string;
  name: string;
  type: 'savings' | 'checking' | 'digital';
  number: string;
  alias?: string;
  balance: number;
  availableBalance: number;
  heldBalance: number;
  lastMovement: string;
  status: 'ACTIVE' | 'BLOCKED' | 'CLOSED';
  movements: AccountMovement[];
}

@Component({
  selector: 'app-accounts',
  standalone: true,
  templateUrl: './accounts.component.html',
  styleUrl: './accounts.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class AccountsComponent implements OnInit {
  private readonly accountService = inject(AccountService);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly accounts = signal<Account[]>([]);

  protected readonly selectedAccountId = signal<string | null>(null);
  protected readonly showAllMovements = signal(false);

  protected readonly selectedAccount = computed(() => {
    const id = this.selectedAccountId();
    if (id === null) return null;
    return this.accounts().find(a => a.id === id) ?? null;
  });

  protected readonly displayedMovements = computed(() => {
    const account = this.selectedAccount();
    if (!account) return [];
    return this.showAllMovements() ? account.movements : account.movements.slice(0, 3);
  });

  protected readonly quickActions = [
    { icon: 'sync_alt', label: 'Transferir', action: 'transfer' },
    { icon: 'qr_code_scanner', label: 'Recargar', action: 'recharge' },
    { icon: 'lightbulb', label: 'Pagar Servicios', action: 'pay' },
    { icon: 'description', label: 'Descargar Extracto', action: 'download' },
    { icon: 'person', label: 'Compartir Datos', action: 'share' },
  ];

  ngOnInit(): void {
    this.loadAccounts();
  }

  protected loadAccounts(): void {
    this.loading.set(true);
    this.error.set(null);
    this.accountService.getAccounts().subscribe({
      next: (apiAccounts) => {
        const mapped = apiAccounts.map(a => this.mapAccount(a));
        this.accounts.set(mapped);
        this.loading.set(false);
        if (mapped.length > 0) {
          this.loadAllMovements(mapped);
        }
      },
      error: () => {
        this.error.set('Error al cargar las cuentas');
        this.loading.set(false);
      },
    });
  }

  private loadAllMovements(accs: Account[]): void {
    for (const acc of accs) {
      this.accountService.getAccountMovements(acc.id).subscribe({
        next: (movements) => {
          const mapped = movements.map(m => this.mapMovement(m));
          this.accounts.update(list => list.map(a =>
            a.id === acc.id ? { ...a, movements: mapped } : a
          ));
        },
      });
    }
  }

  private mapAccount(a: { id: string; accountNumber: string; accountType: string; balance: number; availableBalance: number; status: string; createdAt: string }): Account {
    return {
      id: a.id,
      name: this.getAccountName(a.accountType),
      type: a.accountType.toLowerCase() as 'savings' | 'checking' | 'digital',
      number: a.accountNumber,
      alias: undefined,
      balance: a.balance,
      availableBalance: a.availableBalance,
      heldBalance: 0,
      lastMovement: this.formatDate(a.createdAt),
      status: a.status === 'ACTIVE' ? 'ACTIVE' : a.status === 'FROZEN' ? 'BLOCKED' : 'CLOSED',
      movements: [],
    };
  }

  private mapMovement(m: ApiAccountMovement): AccountMovement {
    return {
      date: this.formatDate(m.createdAt),
      description: m.description,
      amount: m.amount,
      type: m.type === 'INCOME' || m.type === 'TRANSFER_IN' ? 'INCOME' : 'EXPENSE',
      status: m.status === 'COMPLETED' || m.status === 'PENDING' ? m.status : 'COMPLETED',
    };
  }

  private getAccountName(type: string): string {
    switch (type) {
      case 'SAVINGS': return 'Cuenta Ahorros Premium';
      case 'CHECKING': return 'Cuenta Corriente';
      case 'DIGITAL': return 'Cuenta Digital';
      default: return 'Cuenta';
    }
  }

  private formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    if (diffDays === 0) return 'Hoy ' + date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });
    if (diffDays === 1) return 'Ayer';
    if (diffDays < 7) return `Hace ${diffDays} días`;
    return date.toLocaleDateString('es-ES', { day: 'numeric', month: 'short' });
  }

  protected selectAccount(id: string): void {
    this.selectedAccountId.set(id);
    this.showAllMovements.set(false);
  }

  protected closeDetail(): void {
    this.selectedAccountId.set(null);
  }

  protected toggleMovements(): void {
    this.showAllMovements.update(v => !v);
  }

  protected quickAction(action: string): void {
    console.log('Quick action:', action);
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO') + ' COP';
  }

  protected get accountTypeColor(): Record<string, string> {
    return {
      savings: 'var(--color-warning)',
      checking: 'var(--color-info)',
      digital: 'var(--color-primary)',
    };
  }

  protected get accountTypeLabel(): Record<string, string> {
    return {
      savings: 'Ahorros',
      checking: 'Corriente',
      digital: 'Digital',
    };
  }
}
