import { Component, ViewEncapsulation, signal, computed, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { forkJoin } from 'rxjs';
import { TransferService, AccountService } from '../../shared/services';
import { Account } from '../../shared/models/account.model';
import { Beneficiary, Transfer, TransferRequest, BeneficiaryRequest, TransferType } from '../../shared/models/transfer.model';

@Component({
  selector: 'app-transfers',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './transfers.component.html',
  styleUrl: './transfers.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class TransfersComponent implements OnInit {
  private readonly transferService = inject(TransferService);
  private readonly accountService = inject(AccountService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  tabs = ['Rápida', 'Programadas', 'Historial'];
  selectedTab = signal(0);

  protected readonly accounts = signal<Account[]>([]);
  protected readonly beneficiaries = signal<Beneficiary[]>([]);
  protected readonly scheduledTransfers = signal<Transfer[]>([]);
  protected readonly transferHistory = signal<Transfer[]>([]);

  protected readonly scheduledTotal = computed(() =>
    this.scheduledTransfers().reduce((sum, t) => sum + t.amount, 0)
  );

  protected readonly scheduledCount = computed(() => this.scheduledTransfers().length);

  protected readonly nextExecutionDate = computed(() => {
    const sorted = [...this.scheduledTransfers()].sort((a, b) =>
      new Date(a.scheduledDate).getTime() - new Date(b.scheduledDate).getTime()
    );
    return sorted.length > 0 ? sorted[0].scheduledDate : null;
  });

  fromAccountId = signal('');
  transferType = signal<'own' | 'third'>('own');
  ownDestAccountId = signal('');
  beneficiaryId = signal('');
  newBeneficiaryName = signal('');
  newBeneficiaryAccount = signal('');
  newBeneficiaryBank = signal('');
  amount = signal(0);
  description = signal('');

  showConfirmation = signal(false);
  showSuccess = signal(false);
  errorMessage = signal('');

  ngOnInit(): void {
    this.loadData();
  }

  protected loadData(): void {
    this.loading.set(true);
    this.error.set(null);
    forkJoin({
      accounts: this.accountService.getAccounts(),
      beneficiaries: this.transferService.getBeneficiaries(),
      transfers: this.transferService.getTransfers(),
    }).subscribe({
      next: ({ accounts, beneficiaries, transfers }) => {
        this.accounts.set(accounts);
        this.beneficiaries.set(beneficiaries);
        this.scheduledTransfers.set(transfers.filter(t => t.status === 'PENDING' && t.scheduledDate));
        this.transferHistory.set(transfers.filter(t => t.status !== 'PENDING' || !t.scheduledDate));
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar los datos');
        this.loading.set(false);
      },
    });
  }

  selectTab(index: number) {
    this.selectedTab.set(index);
  }

  selectFromAccount(accountId: string) {
    this.fromAccountId.set(accountId);
  }

  setTransferType(type: 'own' | 'third') {
    this.transferType.set(type);
  }

  selectOwnDest(accountId: string) {
    this.ownDestAccountId.set(accountId);
  }

  selectBeneficiary(id: string) {
    this.beneficiaryId.set(id);
  }

  addNewBeneficiary() {
    const name = this.newBeneficiaryName();
    const account = this.newBeneficiaryAccount();
    const bank = this.newBeneficiaryBank();
    if (!name || !account || !bank) return;
    const request: BeneficiaryRequest = {
      name, accountNumber: account, bank,
      documentNumber: '', email: '', phone: '', alias: '',
    };
    this.transferService.createBeneficiary(request).subscribe({
      next: (ben) => {
        this.beneficiaries.update(list => [...list, ben]);
        this.beneficiaryId.set(ben.id);
      },
      error: () => this.errorMessage.set('Error al crear el beneficiario'),
    });
  }

  submitTransfer() {
    const from = this.accounts().find(a => a.id === this.fromAccountId());
    if (!from) { this.errorMessage.set('Selecciona una cuenta origen'); return; }
    const amt = this.amount();
    if (!amt || amt <= 0) { this.errorMessage.set('Ingresa un monto válido'); return; }
    if (amt > from.availableBalance) { this.errorMessage.set('Saldo insuficiente'); return; }
    this.showConfirmation.set(true);
  }

  confirmTransfer() {
    this.showConfirmation.set(false);
    this.errorMessage.set('');

    const fromAccount = this.accounts().find(a => a.id === this.fromAccountId());
    if (!fromAccount) return;

    let destinationAccountNumber = '';
    let destinationBank = '';
    let destinationName = '';
    let type: TransferType = 'OWN';

    if (this.transferType() === 'own') {
      const dest = this.accounts().find(a => a.id === this.ownDestAccountId());
      if (!dest) { this.errorMessage.set('Selecciona una cuenta destino'); return; }
      destinationAccountNumber = dest.accountNumber;
      destinationName = this.accountLabel(dest);
      type = 'OWN';
    } else {
      const ben = this.beneficiaries().find(b => b.id === this.beneficiaryId());
      if (!ben) { this.errorMessage.set('Selecciona un beneficiario'); return; }
      destinationAccountNumber = ben.accountNumber;
      destinationBank = ben.bank;
      destinationName = ben.name;
      type = 'THIRD_PARTY';
    }

    const request: TransferRequest = {
      destinationAccountNumber,
      destinationBank,
      destinationName,
      amount: this.amount(),
      description: this.description() || destinationName,
      type,
    };

    this.transferService.createTransfer(request).subscribe({
      next: () => {
        this.showSuccess.set(true);
        this.loadData();
        setTimeout(() => this.resetForm(), 2000);
      },
      error: () => {
        this.errorMessage.set('Error al realizar la transferencia');
      },
    });
  }

  cancelTransfer() {
    this.showConfirmation.set(false);
  }

  cancelScheduled(id: string) {
    if (!confirm('¿Cancelar esta transferencia programada?')) return;
    this.transferService.cancelTransfer(id).subscribe({
      next: () => this.loadData(),
      error: () => this.errorMessage.set('Error al cancelar la transferencia'),
    });
  }

  executeScheduledNow(id: string) {
    if (!confirm('¿Ejecutar esta transferencia ahora?')) return;
    this.transferService.executeScheduled(id).subscribe({
      next: () => this.loadData(),
      error: () => this.errorMessage.set('Error al ejecutar la transferencia'),
    });
  }

  protected frequencyLabel(freq: string): string {
    const labels: Record<string, string> = {
      ONE_TIME: 'Única',
      WEEKLY: 'Semanal',
      BIWEEKLY: 'Quincenal',
      MONTHLY: 'Mensual',
    };
    return labels[freq] || freq;
  }

  protected scheduledDateFormat(dateStr: string): string {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('es-CO', { day: 'numeric', month: 'long', year: 'numeric' });
  }

  resetForm() {
    this.showSuccess.set(false);
    this.fromAccountId.set('');
    this.ownDestAccountId.set('');
    this.beneficiaryId.set('');
    this.amount.set(0);
    this.description.set('');
    this.newBeneficiaryName.set('');
    this.newBeneficiaryAccount.set('');
    this.newBeneficiaryBank.set('');
    this.errorMessage.set('');
  }

  protected accountLabel(acc: Account): string {
    const labels: Record<string, string> = {
      SAVINGS: 'Ahorros',
      CHECKING: 'Corriente',
      DIGITAL: 'Digital',
    };
    return labels[acc.accountType] || acc.accountType;
  }

  protected statusClass(status: string): string {
    return status.toLowerCase();
  }

  protected statusLabel(status: string): string {
    const labels: Record<string, string> = {
      COMPLETED: 'Completada',
      PENDING: 'Pendiente',
      FAILED: 'Fallida',
      CANCELLED: 'Cancelada',
    };
    return labels[status] || status;
  }

  formatCurrency(n: number) {
    return '$' + n.toLocaleString('es-CO');
  }
}
