import { Component, ViewEncapsulation, signal, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RechargeService } from '../../shared/services/recharge.service';
import { RechargeRequest, Recharge, Operator } from '../../shared/models/recharge.model';

interface OperatorOption {
  id: number;
  name: string;
  color: string;
  value: Operator;
}

@Component({
  selector: 'app-recharges',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './recharges.component.html',
  styleUrl: './recharges.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class RechargesComponent implements OnInit {
  private readonly rechargeService = inject(RechargeService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  operators: OperatorOption[] = [
    { id: 1, name: 'Claro', color: '#ef4444', value: 'CLARO' },
    { id: 2, name: 'Movistar', color: '#22c55e', value: 'MOVISTAR' },
    { id: 3, name: 'Tigo', color: '#3b82f6', value: 'TIGO' },
    { id: 4, name: 'WOM', color: '#ec4899', value: 'WOM' },
    { id: 5, name: 'ETB', color: '#f59e0b', value: 'ETB' },
  ];

  quickAmounts = [5000, 10000, 20000, 50000, 100000];

  selectedOperator = signal(0);
  phoneNumber = signal('');
  amount = signal(0);

  protected readonly rechargeHistory = signal<Recharge[]>([]);
  frequentRecharges: { operator: string; phone: string; amount: number }[] = [];

  showSuccess = signal(false);
  errorMessage = signal('');

  ngOnInit(): void {
    this.loadRecharges();
  }

  protected loadRecharges(): void {
    this.loading.set(true);
    this.error.set(null);
    this.rechargeService.getRecharges().subscribe({
      next: (recharges) => {
        this.rechargeHistory.set(recharges);
        this.buildFrequent(recharges);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar el historial');
        this.loading.set(false);
      },
    });
  }

  private buildFrequent(recharges: Recharge[]): void {
    const seen = new Set<string>();
    this.frequentRecharges = [];
    for (const r of recharges) {
      const key = `${r.operator}-${r.phoneNumber}`;
      if (!seen.has(key)) {
        seen.add(key);
        this.frequentRecharges.push({
          operator: r.operator,
          phone: r.phoneNumber,
          amount: r.amount,
        });
      }
    }
  }

  selectOperator(id: number) {
    this.selectedOperator.set(id);
  }

  setQuickAmount(amount: number) {
    this.amount.set(amount);
  }

  setFrequent(phone: string, amount: number, operatorName: string) {
    this.phoneNumber.set(phone);
    this.amount.set(amount);
    const op = this.operators.find(o => o.value === operatorName);
    if (op) this.selectedOperator.set(op.id);
  }

  submitRecharge() {
    const op = this.operators.find(o => o.id === this.selectedOperator());
    if (!op) { this.errorMessage.set('Selecciona un operador'); return; }
    const phone = this.phoneNumber().trim();
    if (!phone || phone.length < 7) { this.errorMessage.set('Ingresa un número válido'); return; }
    const amt = this.amount();
    if (!amt || amt <= 0) { this.errorMessage.set('Selecciona o ingresa un monto'); return; }
    this.errorMessage.set('');

    const request: RechargeRequest = {
      operator: op.value,
      phoneNumber: phone,
      amount: amt,
    };

    this.rechargeService.createRecharge(request).subscribe({
      next: (recharge) => {
        this.rechargeHistory.update(list => [recharge, ...list]);
        this.showSuccess.set(true);
        setTimeout(() => this.resetForm(), 2000);
      },
      error: () => {
        this.errorMessage.set('Error al realizar la recarga');
      },
    });
  }

  resetForm() {
    this.showSuccess.set(false);
    this.selectedOperator.set(0);
    this.phoneNumber.set('');
    this.amount.set(0);
    this.errorMessage.set('');
  }

  formatCurrency(n: number) {
    return '$' + n.toLocaleString('es-CO');
  }
}
