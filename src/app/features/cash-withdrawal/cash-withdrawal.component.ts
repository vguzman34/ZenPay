import { Component, ViewEncapsulation, signal, computed, DestroyRef, inject, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { CashWithdrawalService } from '../../shared/services/cash-withdrawal.service';
import { CashWithdrawal } from '../../shared/models/cash-withdrawal.model';

@Component({
  selector: 'app-cash-withdrawal',
  standalone: true,
  imports: [FormsModule, RouterLink],
  templateUrl: './cash-withdrawal.component.html',
  styleUrl: './cash-withdrawal.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class CashWithdrawalComponent implements OnInit {
  private readonly cashWithdrawalService = inject(CashWithdrawalService);
  private destroyRef = inject(DestroyRef);

  protected readonly loading = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly selectedTab = signal<'generar' | 'historial'>('generar');
  protected readonly amount = signal<number>(0);
  protected readonly generatedCode = signal<CashWithdrawal | null>(null);
  protected readonly timeRemaining = signal<number>(0);
  protected readonly history = signal<CashWithdrawal[]>([]);

  private timerInterval: ReturnType<typeof setInterval> | null = null;

  constructor() {
    this.destroyRef.onDestroy(() => this.stopTimer());
  }

  ngOnInit(): void {
    this.loadHistory();
  }

  protected readonly timerFormatted = computed(() => {
    const s = this.timeRemaining();
    if (s <= 0) return '00:00:00';
    return `${String(Math.floor(s / 3600)).padStart(2, '0')}:${String(Math.floor((s % 3600) / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
  });

  protected readonly isUrgent = computed(() => this.timeRemaining() > 0 && this.timeRemaining() < 600);
  protected readonly qrPattern = computed(() => {
    const code = this.generatedCode()?.code ?? '';
    const rows = 8;
    const bits: string[][] = [];
    for (let r = 0; r < rows; r++) {
      const row: string[] = [];
      for (let c = 0; c < rows; c++) {
        const idx = (r * rows + c) % code.length;
        row.push(parseInt(code[idx]) % 2 === 0 ? '1' : '0');
      }
      bits.push(row);
    }
    return bits;
  });

  protected loadHistory(): void {
    this.cashWithdrawalService.getWithdrawals().subscribe({
      next: (withdrawals) => {
        this.history.set(withdrawals);
      },
      error: () => {
        this.error.set('Error al cargar el historial');
      },
    });
  }

  protected generateCode(): void {
    const amt = this.amount();
    if (amt < 10000) return;
    this.loading.set(true);
    this.error.set(null);
    this.cashWithdrawalService.generateCode({ amount: amt }).subscribe({
      next: (result) => {
        this.generatedCode.set(result);
        const expiresAt = new Date(result.expiresAt);
        const now = new Date();
        const diffSec = Math.max(0, Math.floor((expiresAt.getTime() - now.getTime()) / 1000));
        this.timeRemaining.set(diffSec);
        this.startTimer();
        this.loadHistory();
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al generar el código');
        this.loading.set(false);
      },
    });
  }

  private startTimer(): void {
    this.stopTimer();
    this.timerInterval = setInterval(() => {
      this.timeRemaining.update(t => {
        if (t <= 1) { this.stopTimer(); this.generatedCode.update(c => c ? { ...c, status: 'EXPIRED' } : null); return 0; }
        return t - 1;
      });
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerInterval) { clearInterval(this.timerInterval); this.timerInterval = null; }
  }

  protected formatDate(dateStr: string): string {
    return new Date(dateStr).toLocaleDateString('es-CO', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO') + ' COP';
  }

  protected maskCode(code: string): string {
    return '••••' + code.slice(-2);
  }

  protected getStatusClass(status: string): string {
    return { ACTIVE: 'status-active', COMPLETED: 'status-used', EXPIRED: 'status-expired', CANCELLED: 'status-expired' }[status] ?? '';
  }

  protected getStatusLabel(status: string): string {
    return { ACTIVE: 'Activo', COMPLETED: 'Usado', EXPIRED: 'Expirado', CANCELLED: 'Cancelado' }[status] ?? '';
  }

  protected getStatusIcon(status: string): string {
    return { ACTIVE: '✅', COMPLETED: '✓', EXPIRED: '✕', CANCELLED: '✕' }[status] ?? '';
  }
}
