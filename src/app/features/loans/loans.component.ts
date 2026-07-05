import { Component, ViewEncapsulation, signal, computed, inject, OnInit } from '@angular/core';
import { LoanService } from '../../shared/services';
import { Loan, Installment, LoanType } from '../../shared/models';

@Component({
  selector: 'app-loans',
  standalone: true,
  templateUrl: './loans.component.html',
  styleUrl: './loans.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class LoansComponent implements OnInit {
  private readonly loanService = inject(LoanService);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly selectedLoanId = signal<string | null>(null);
  protected readonly loans = signal<Loan[]>([]);
  protected readonly installments = signal<Installment[]>([]);

  protected readonly selectedLoan = computed(() => {
    const id = this.selectedLoanId();
    if (id === null) return null;
    return this.loans().find(l => l.id === id) ?? null;
  });

  private readonly loanTypeConfig: Record<LoanType, { label: string; icon: string }> = {
    PERSONAL: { label: 'Crédito Personal', icon: '\u{1F4B3}' },
    VEHICLE: { label: 'Crédito Vehículo', icon: '\u{1F697}' },
    MORTGAGE: { label: 'Crédito Hipotecario', icon: '\u{1F3E1}' },
  };

  ngOnInit(): void {
    this.loadLoans();
  }

  protected loadLoans(): void {
    this.loading.set(true);
    this.error.set(null);
    this.loanService.getLoans().subscribe({
      next: (loans) => {
        this.loans.set(loans);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar los créditos. Intenta de nuevo.');
        this.loading.set(false);
      },
    });
  }

  protected loanDisplay(type: LoanType): { label: string; icon: string } {
    return this.loanTypeConfig[type] || { label: type, icon: '\u{2753}' };
  }

  protected loanAccentColor(type: LoanType): string {
    const colors: Record<LoanType, string> = {
      PERSONAL: 'var(--color-primary)',
      VEHICLE: 'var(--color-info)',
      MORTGAGE: 'var(--color-warning)',
    };
    return colors[type] || 'var(--color-primary)';
  }

  protected progressPercent(loan: Loan): number {
    return Math.round((loan.paidInstallments / loan.totalInstallments) * 100);
  }

  protected selectLoan(id: string): void {
    this.selectedLoanId.set(id);
    this.loadInstallments(id);
  }

  private loadInstallments(loanId: string): void {
    this.loanService.getInstallments(loanId).subscribe({
      next: (installments) => this.installments.set(installments),
      error: () => this.installments.set([]),
    });
  }

  protected closeDetail(): void {
    this.selectedLoanId.set(null);
    this.installments.set([]);
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO') + ' COP';
  }
}
