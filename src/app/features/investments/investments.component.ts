import { Component, ViewEncapsulation, signal, computed, inject, OnInit } from '@angular/core';
import { InvestmentService } from '../../shared/services';
import { Investment } from '../../shared/models';

@Component({
  selector: 'app-investments',
  standalone: true,
  templateUrl: './investments.component.html',
  styleUrl: './investments.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class InvestmentsComponent implements OnInit {
  private readonly investmentService = inject(InvestmentService);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly selectedInvestmentId = signal<string | null>(null);
  protected readonly investments = signal<Investment[]>([]);

  protected readonly selectedInvestment = computed(() => {
    const id = this.selectedInvestmentId();
    if (id === null) return null;
    return this.investments().find(i => i.id === id) ?? null;
  });

  protected readonly totalInvested = computed(() =>
    this.investments().reduce((sum, i) => sum + i.amount, 0)
  );

  protected readonly totalCurrentValue = computed(() =>
    this.investments().reduce((sum, i) => sum + i.currentValue, 0)
  );

  protected readonly totalGainLoss = computed(() =>
    this.totalCurrentValue() - this.totalInvested()
  );

  protected readonly totalPerformancePercent = computed(() =>
    this.totalInvested() > 0
      ? ((this.totalGainLoss() / this.totalInvested()) * 100).toFixed(1)
      : '0'
  );

  ngOnInit(): void {
    this.loadInvestments();
  }

  protected loadInvestments(): void {
    this.loading.set(true);
    this.error.set(null);
    this.investmentService.getInvestments().subscribe({
      next: (investments) => {
        this.investments.set(investments);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar las inversiones. Intenta de nuevo.');
        this.loading.set(false);
      },
    });
  }

  protected performanceStr(inv: Investment): string {
    return inv.interestRate >= 0 ? `+${inv.interestRate}%` : `${inv.interestRate}%`;
  }

  protected selectInvestment(id: string): void {
    this.selectedInvestmentId.set(id === this.selectedInvestmentId() ? null : id);
  }

  protected closeDetail(): void {
    this.selectedInvestmentId.set(null);
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO') + ' COP';
  }
}
