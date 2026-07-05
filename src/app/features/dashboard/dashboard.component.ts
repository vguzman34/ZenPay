import { Component, ViewEncapsulation, OnInit, signal, computed, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AccountService } from '../../shared/services';
import { AuthStore } from '../../shared/stores/auth.store';
import { AccountMovement, DashboardData } from '../../shared/models';

interface BalanceCard {
  icon: string;
  label: string;
  amount: string;
  trend: string;
  trendUp: boolean;
  accent: string;
}

interface Transaction {
  icon: string;
  description: string;
  category: string;
  date: string;
  amount: string;
  isIncome: boolean;
  status: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class DashboardComponent implements OnInit {
  private readonly accountService = inject(AccountService);
  private readonly authStore = inject(AuthStore);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly dashboardData = signal<DashboardData | null>(null);

  protected readonly today = new Date();
  protected readonly userName = computed(() => this.authStore.user()?.fullName ?? 'Usuario');
  protected readonly totalBalanceLabel = 'COP';

  protected readonly quickActions = [
    { icon: 'swap_horiz', label: 'Transferir', route: '/transfers' },
    { icon: 'phone_iphone', label: 'Recargar', route: '/recharges' },
    { icon: 'receipt_long', label: 'Pagar', route: '/payments' },
    { icon: 'qr_code_scanner', label: 'QR', route: '/qr' },
  ];

  protected readonly balanceCards = computed<BalanceCard[]>(() => {
    const data = this.dashboardData();
    if (!data) return [];
    return [
      { icon: 'account_balance_wallet', label: 'Dinero Disponible', amount: this.formatCurrency(data.availableBalance), trend: '+2.4%', trendUp: true, accent: 'var(--color-success)' },
      { icon: 'savings', label: 'Dinero Ahorrado', amount: this.formatCurrency(data.savingsBalance), trend: '+5.7%', trendUp: true, accent: 'var(--color-info)' },
      { icon: 'trending_up', label: 'Ingresos del Mes', amount: this.formatCurrency(data.monthlyIncome), trend: '+12.3%', trendUp: true, accent: 'var(--color-primary)' },
      { icon: 'trending_down', label: 'Gastos del Mes', amount: this.formatCurrency(data.monthlyExpenses), trend: '-3.1%', trendUp: false, accent: 'var(--color-danger)' },
    ];
  });

  protected readonly transactions = computed<Transaction[]>(() => {
    const activity = this.dashboardData()?.recentActivity;
    if (!activity) return [];
    return activity.slice(0, 8).map(m => ({
      icon: this.getMovementIcon(m),
      description: m.description,
      category: m.category,
      date: this.formatDate(m.createdAt),
      amount: `${m.type === 'INCOME' || m.type === 'TRANSFER_IN' ? '+' : '-'}${this.formatCurrency(m.amount)}`,
      isIncome: m.type === 'INCOME' || m.type === 'TRANSFER_IN',
      status: m.status,
    }));
  });

  protected readonly financialScore = computed(() => this.dashboardData()?.financialScore ?? 0);

  protected readonly totalBalance = computed(() => this.dashboardData() ? this.formatCurrency(this.dashboardData()!.totalBalance) : '$0');

  protected readonly cashFlow = computed(() => this.dashboardData() ? this.formatCurrency(this.dashboardData()!.cashFlow) : '$0');

  protected readonly monthlyIncome = computed(() => this.dashboardData() ? this.formatCurrency(this.dashboardData()!.monthlyIncome) : '$0');

  protected readonly monthlyExpenses = computed(() => this.dashboardData() ? this.formatCurrency(this.dashboardData()!.monthlyExpenses) : '$0');

  protected readonly incomeBarWidth = computed(() => {
    const data = this.dashboardData();
    if (!data) return '50%';
    const total = data.monthlyIncome + data.monthlyExpenses;
    if (total === 0) return '50%';
    return (data.monthlyIncome / total * 100) + '%';
  });

  protected readonly expenseBarWidth = computed(() => {
    const data = this.dashboardData();
    if (!data) return '50%';
    const total = data.monthlyIncome + data.monthlyExpenses;
    if (total === 0) return '50%';
    return (data.monthlyExpenses / total * 100) + '%';
  });

  protected readonly monthLabels = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];

  protected readonly monthlyCashFlow = computed(() => {
    const data = this.dashboardData();
    if (!data) return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    const month = new Date().getMonth();
    const bars = new Array(12).fill(0);
    const income = data.monthlyIncome;
    const expenses = data.monthlyExpenses;
    const maxVal = Math.max(income, expenses, 1);
    const incomePct = (income / maxVal) * 95;
    const expensePct = (expenses / maxVal) * 95;
    bars[month] = Math.round(incomePct);
    bars[(month + 1) % 12] = Math.round(-expensePct);
    return bars;
  });

  protected formatChartValue(val: number): string {
    const data = this.dashboardData();
    if (!data) return '$0';
    const total = Math.max(data.monthlyIncome, data.monthlyExpenses, 1);
    const pct = Math.abs(val) / 95;
    const amount = Math.round(total * pct);
    if (amount >= 1000000) return '$' + (amount / 1000000).toFixed(1) + 'M';
    if (amount >= 1000) return '$' + (amount / 1000).toFixed(0) + 'k';
    return '$' + amount;
  }

  ngOnInit(): void {
    this.loadDashboard();
  }

  protected loadDashboard(): void {
    this.loading.set(true);
    this.error.set(null);
    this.accountService.getDashboard().subscribe({
      next: (data) => {
        this.dashboardData.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar el dashboard');
        this.loading.set(false);
      },
    });
  }

  get dateFormatted(): string {
    return this.today.toLocaleDateString('es-ES', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  }

  get scoreColor(): string {
    const score = this.financialScore();
    if (score >= 80) return 'var(--color-success)';
    if (score >= 60) return 'var(--color-warning)';
    return 'var(--color-danger)';
  }

  get scoreGradient(): string {
    const pct = this.financialScore();
    return `conic-gradient(${this.scoreColor} 0deg ${pct * 3.6}deg, var(--color-surface-alt) ${pct * 3.6}deg 360deg)`;
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO');
  }

  private getMovementIcon(m: AccountMovement): string {
    const categoryMap: Record<string, string> = {
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
    if (categoryMap[m.category]) return categoryMap[m.category];
    const typeMap: Record<string, string> = {
      'INCOME': 'account_balance',
      'EXPENSE': 'money_off',
      'TRANSFER_IN': 'account_balance',
      'TRANSFER_OUT': 'send_money',
      'PAYMENT': 'credit_card',
      'RECHARGE': 'phone_iphone',
      'WITHDRAWAL': 'atm',
      'CARD_PAYMENT': 'credit_card',
    };
    return typeMap[m.type] || 'description';
  }

  private formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    if (diffDays === 0) return 'Hoy';
    if (diffDays === 1) return 'Ayer';
    if (diffDays < 7) return `Hace ${diffDays} días`;
    return date.toLocaleDateString('es-ES', { day: 'numeric', month: 'short' });
  }
}
