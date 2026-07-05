import { Component, ViewEncapsulation, OnInit, signal, computed, inject } from '@angular/core';
import { AccountService } from '../../shared/services';
import { AccountMovement } from '../../shared/models';

interface Transaction {
  icon: string;
  description: string;
  category: string;
  date: string;
  dateRaw: Date;
  amount: number;
  type: 'INCOME' | 'EXPENSE';
  status: 'COMPLETED' | 'PENDING' | 'FAILED';
}

type DateFilter = 'all' | 'today' | 'week' | 'month' | 'year';
type TypeFilter = 'all' | 'income' | 'expense';

@Component({
  selector: 'app-movements',
  standalone: true,
  templateUrl: './movements.component.html',
  styleUrl: './movements.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class MovementsComponent implements OnInit {
  private readonly accountService = inject(AccountService);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly transactions = signal<Transaction[]>([]);

  protected readonly dateFilter = signal<DateFilter>('all');
  protected readonly typeFilter = signal<TypeFilter>('all');
  protected readonly categoryFilter = signal<string>('all');
  protected readonly searchQuery = signal('');
  protected readonly sortBy = signal<'date' | 'amount'>('date');
  protected readonly sortDir = signal<'asc' | 'desc'>('desc');
  protected readonly pageSize = 10;
  protected readonly currentPage = signal(1);

  protected readonly categories = [
    'Todas', 'Compras', 'Streaming', 'Ingreso', 'Servicios',
    'Recargas', 'Retiro', 'Restaurante', 'Transporte', 'Pago', 'Transferencia',
  ];

  protected readonly filteredTransactions = computed(() => {
    let result = [...this.transactions()];

    const df = this.dateFilter();
    const now = new Date();
    if (df === 'today') {
      result = result.filter(t => isSameDay(t.dateRaw, now));
    } else if (df === 'week') {
      const weekAgo = new Date(now);
      weekAgo.setDate(weekAgo.getDate() - 7);
      result = result.filter(t => t.dateRaw >= weekAgo);
    } else if (df === 'month') {
      result = result.filter(t => t.dateRaw.getMonth() === now.getMonth() && t.dateRaw.getFullYear() === now.getFullYear());
    } else if (df === 'year') {
      result = result.filter(t => t.dateRaw.getFullYear() === now.getFullYear());
    }

    const tf = this.typeFilter();
    if (tf === 'income') result = result.filter(t => t.type === 'INCOME');
    else if (tf === 'expense') result = result.filter(t => t.type === 'EXPENSE');

    const cf = this.categoryFilter();
    if (cf !== 'all') result = result.filter(t => t.category === cf);

    const sq = this.searchQuery().toLowerCase().trim();
    if (sq) result = result.filter(t => t.description.toLowerCase().includes(sq));

    const sb = this.sortBy();
    const sd = this.sortDir();
    result.sort((a, b) => {
      if (sb === 'date') {
        return sd === 'desc' ? b.dateRaw.getTime() - a.dateRaw.getTime() : a.dateRaw.getTime() - b.dateRaw.getTime();
      } else {
        return sd === 'desc' ? b.amount - a.amount : a.amount - b.amount;
      }
    });

    return result;
  });

  protected readonly paginatedTransactions = computed(() => {
    const start = 0;
    const end = this.currentPage() * this.pageSize;
    return this.filteredTransactions().slice(start, end);
  });

  protected readonly hasMore = computed(() => {
    return this.paginatedTransactions().length < this.filteredTransactions().length;
  });

  protected readonly totalIncome = computed(() => {
    return this.filteredTransactions()
      .filter(t => t.type === 'INCOME')
      .reduce((sum, t) => sum + t.amount, 0);
  });

  protected readonly Math = Math;

  protected readonly totalExpense = computed(() => {
    return this.filteredTransactions()
      .filter(t => t.type === 'EXPENSE')
      .reduce((sum, t) => sum + t.amount, 0);
  });

  protected readonly netBalance = computed(() => this.totalIncome() - this.totalExpense());

  protected readonly showFilters = signal(false);

  ngOnInit(): void {
    this.loadTransactions();
  }

  protected loadTransactions(): void {
    this.loading.set(true);
    this.error.set(null);
    this.accountService.getAccounts().subscribe({
      next: (accounts) => {
        if (accounts.length > 0) {
          this.accountService.getAccountMovements(accounts[0].id).subscribe({
            next: (movements) => {
              const mapped = movements.map(m => this.mapMovement(m));
              this.transactions.set(mapped);
              this.loading.set(false);
            },
            error: () => {
              this.error.set('Error al cargar movimientos');
              this.loading.set(false);
            },
          });
        } else {
          this.transactions.set([]);
          this.loading.set(false);
        }
      },
      error: () => {
        this.error.set('Error al cargar cuentas');
        this.loading.set(false);
      },
    });
  }

  private mapMovement(m: AccountMovement): Transaction {
    return {
      icon: this.getCategoryIcon(m.category),
      description: m.description,
      category: m.category,
      date: this.formatDate(m.createdAt),
      dateRaw: new Date(m.createdAt),
      amount: m.amount,
      type: m.type === 'INCOME' || m.type === 'TRANSFER_IN' ? 'INCOME' : 'EXPENSE',
      status: m.status === 'COMPLETED' || m.status === 'PENDING' || m.status === 'FAILED' ? m.status : 'COMPLETED',
    };
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

  protected setDateFilter(f: DateFilter): void {
    this.dateFilter.set(f);
    this.currentPage.set(1);
  }

  protected setTypeFilter(f: TypeFilter): void {
    this.typeFilter.set(f);
    this.currentPage.set(1);
  }

  protected setCategoryFilter(c: string): void {
    this.categoryFilter.set(c === 'Todas' ? 'all' : c);
    this.currentPage.set(1);
  }

  protected setSearch(q: string): void {
    this.searchQuery.set(q);
    this.currentPage.set(1);
  }

  protected setSort(field: 'date' | 'amount'): void {
    if (this.sortBy() === field) {
      this.sortDir.update(d => d === 'desc' ? 'asc' : 'desc');
    } else {
      this.sortBy.set(field);
      this.sortDir.set('desc');
    }
  }

  protected loadMore(): void {
    this.currentPage.update(p => p + 1);
  }

  protected toggleFilters(): void {
    this.showFilters.update(v => !v);
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO');
  }

  protected getCategoryIcon(category: string): string {
    const map: Record<string, string> = {
      'Compras': 'shopping_cart',
      'Streaming': 'smart_display',
      'Ingreso': 'account_balance',
      'Servicios': 'receipt_long',
      'Recargas': 'phone_iphone',
      'Retiro': 'atm',
      'Restaurante': 'restaurant',
      'Transporte': 'directions_car',
      'Pago': 'credit_card',
      'Transferencia': 'swap_horiz',
    };
    return map[category] || 'description';
  }
}

function isSameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear() &&
         a.getMonth() === b.getMonth() &&
         a.getDate() === b.getDate();
}
