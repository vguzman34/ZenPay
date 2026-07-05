import { Component, ViewEncapsulation, signal, computed, inject, OnInit } from '@angular/core';
import { SavingsGoalService } from '../../shared/services';
import { SavingsGoal, GoalContributeRequest, AccountMovement } from '../../shared/models';

@Component({
  selector: 'app-savings-goals',
  standalone: true,
  templateUrl: './savings-goals.component.html',
  styleUrl: './savings-goals.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class SavingsGoalsComponent implements OnInit {
  private readonly savingsGoalService = inject(SavingsGoalService);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly actionError = signal<string | null>(null);

  protected readonly selectedGoalId = signal<string | null>(null);
  protected readonly showNewGoalForm = signal(false);
  protected readonly newGoalName = signal('');
  protected readonly newGoalTarget = signal(0);
  protected readonly newGoalDeadline = signal('');
  protected readonly contributeAmount = signal(0);

  protected readonly goals = signal<SavingsGoal[]>([]);
  protected readonly goalMovements = signal<AccountMovement[]>([]);

  protected readonly selectedGoal = computed(() => {
    const id = this.selectedGoalId();
    if (id === null) return null;
    return this.goals().find(g => g.id === id) ?? null;
  });

  ngOnInit(): void {
    this.loadGoals();
  }

  protected loadGoals(): void {
    this.loading.set(true);
    this.error.set(null);
    this.savingsGoalService.getGoals().subscribe({
      next: (goals) => {
        this.goals.set(goals);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar las metas de ahorro. Intenta de nuevo.');
        this.loading.set(false);
      },
    });
  }

  protected progressPercent(goal: SavingsGoal): number {
    return Math.round((goal.currentAmount / goal.targetAmount) * 100);
  }

  protected monthlySuggestion(goal: SavingsGoal): number {
    const now = new Date();
    const [monthStr, yearStr] = goal.deadline.split(' ');
    const monthMap: Record<string, number> = { Ene: 0, Feb: 1, Mar: 2, Abr: 3, May: 4, Jun: 5, Jul: 6, Ago: 7, Sep: 8, Oct: 9, Nov: 10, Dic: 11 };
    const deadline = new Date(parseInt(yearStr), monthMap[monthStr], 1);
    const monthsLeft = (deadline.getFullYear() - now.getFullYear()) * 12 + (deadline.getMonth() - now.getMonth());
    if (monthsLeft <= 0) return 0;
    const remaining = goal.targetAmount - goal.currentAmount;
    return Math.ceil(remaining / monthsLeft);
  }

  protected selectGoal(id: string): void {
    this.selectedGoalId.set(id);
    this.contributeAmount.set(0);
    this.loadGoalMovements(id);
  }

  private loadGoalMovements(id: string): void {
    this.savingsGoalService.getGoalMovements(id).subscribe({
      next: (movements) => this.goalMovements.set(movements),
      error: () => this.goalMovements.set([]),
    });
  }

  protected closeDetail(): void {
    this.selectedGoalId.set(null);
    this.goalMovements.set([]);
  }

  protected contribute(): void {
    const goal = this.selectedGoal();
    const amount = this.contributeAmount();
    if (!goal || amount <= 0) return;
    this.actionError.set(null);
    this.savingsGoalService.contributeToGoal(goal.id, { amount, description: 'Aporte desde app' }).subscribe({
      next: (updated) => {
        this.goals.update(goals => goals.map(g => g.id === updated.id ? updated : g));
        this.contributeAmount.set(0);
        this.loadGoalMovements(goal.id);
      },
      error: () => this.actionError.set('Error al realizar el aporte. Intenta de nuevo.'),
    });
  }

  protected toggleNewGoal(): void {
    this.showNewGoalForm.update(v => !v);
    if (!this.showNewGoalForm()) {
      this.newGoalName.set('');
      this.newGoalTarget.set(0);
      this.newGoalDeadline.set('');
    }
  }

  protected addNewGoal(): void {
    const name = this.newGoalName();
    const target = this.newGoalTarget();
    if (!name || target <= 0) return;
    this.actionError.set(null);
    this.savingsGoalService.createGoal({
      name,
      targetAmount: target,
      deadline: this.newGoalDeadline() || undefined,
    }).subscribe({
      next: () => {
        this.loadGoals();
        this.toggleNewGoal();
      },
      error: () => this.actionError.set('Error al crear la meta. Intenta de nuevo.'),
    });
  }

  protected onContributeAmountInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    this.contributeAmount.set(value ? Number(value) : 0);
  }

  protected onNewGoalTargetInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    this.newGoalTarget.set(value ? Number(value) : 0);
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO') + ' COP';
  }

  protected formatDate(dateStr: string): string {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' });
  }
}
