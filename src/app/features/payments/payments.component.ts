import { Component, ViewEncapsulation, signal, computed, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { PaymentService } from '../../shared/services/payment.service';
import { Payment, PaymentRequest, PaymentCategory } from '../../shared/models/payment.model';

interface ServiceType {
  id: number;
  name: string;
  icon: string;
  color: string;
}

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './payments.component.html',
  styleUrl: './payments.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class PaymentsComponent implements OnInit {
  private readonly paymentService = inject(PaymentService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  serviceTypes: ServiceType[] = [
    { id: 1, name: 'Energía', icon: '⚡', color: '#f59e0b' },
    { id: 2, name: 'Agua', icon: '💧', color: '#3b82f6' },
    { id: 3, name: 'Gas', icon: '🔥', color: '#ef4444' },
    { id: 4, name: 'Internet', icon: '🌐', color: '#6366f1' },
    { id: 5, name: 'Telefonía', icon: '📞', color: '#22c55e' },
    { id: 6, name: 'TV', icon: '📺', color: '#ec4899' },
  ];

  companiesByService: Record<string, string[]> = {
    'Energía': ['ENEL', 'EPM'],
    'Agua': ['Acueducto Bogotá', 'EPM'],
    'Gas': ['Vanti', 'Gases de Occidente'],
    'Internet': ['Claro', 'Movistar', 'Tigo'],
    'Telefonía': ['Claro', 'Movistar', 'Tigo'],
    'TV': ['Claro TV', 'DirecTV'],
  };

  protected readonly pendingBills = signal<Payment[]>([]);
  protected readonly paidHistory = signal<Payment[]>([]);

  selectedServiceId = signal(0);
  selectedCompany = signal('');
  referenceCode = signal('');
  showSuccess = signal(false);
  errorMessage = signal('');

  selectedService = computed(() =>
    this.serviceTypes.find(s => s.id === this.selectedServiceId())
  );

  availableCompanies = computed(() => {
    const svc = this.selectedService();
    return svc ? this.companiesByService[svc.name] || [] : [];
  });

  ngOnInit(): void {
    this.loadPayments();
  }

  protected loadPayments(): void {
    this.loading.set(true);
    this.error.set(null);
    this.paymentService.getPayments().subscribe({
      next: (payments) => {
        this.pendingBills.set(payments.filter(p => p.status === 'PENDING'));
        this.paidHistory.set(payments.filter(p => p.status === 'COMPLETED'));
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar las facturas');
        this.loading.set(false);
      },
    });
  }

  private serviceToCategory(name: string): PaymentCategory {
    const map: Record<string, PaymentCategory> = {
      'Energía': 'ELECTRICITY',
      'Agua': 'WATER',
      'Gas': 'GAS',
      'Internet': 'INTERNET',
      'Telefonía': 'PHONE',
      'TV': 'TV',
    };
    return map[name] || 'OTHER';
  }

  selectService(id: number) {
    this.selectedServiceId.set(id);
    this.selectedCompany.set('');
    this.referenceCode.set('');
    this.errorMessage.set('');
  }

  selectCompany(name: string) {
    this.selectedCompany.set(name);
  }

  setReference(value: string) {
    this.referenceCode.set(value);
  }

  payBill() {
    const svc = this.selectedService();
    if (!svc) { this.errorMessage.set('Selecciona un servicio'); return; }
    const company = this.selectedCompany();
    if (!company) { this.errorMessage.set('Selecciona una empresa'); return; }
    const ref = this.referenceCode().trim();
    if (!ref) { this.errorMessage.set('Ingresa el código de referencia'); return; }

    const category = this.serviceToCategory(svc.name);
    const pending = this.pendingBills().find(p =>
      p.category === category && p.provider === company && p.referenceCode === ref
    );
    if (!pending) {
      this.errorMessage.set('Factura no encontrada o ya fue pagada');
      return;
    }

    const request: PaymentRequest = {
      category,
      provider: company,
      referenceCode: ref,
      amount: pending.amount,
    };

    this.paymentService.createPayment(request).subscribe({
      next: () => {
        this.showSuccess.set(true);
        this.loadPayments();
        setTimeout(() => {
          this.showSuccess.set(false);
          this.selectedServiceId.set(0);
          this.selectedCompany.set('');
          this.referenceCode.set('');
        }, 2000);
      },
      error: () => {
        this.errorMessage.set('Error al procesar el pago');
      },
    });
  }

  payPendingBill(bill: Payment) {
    const svc = this.serviceTypes.find(s => this.serviceToCategory(s.name) === bill.category);
    if (svc) this.selectedServiceId.set(svc.id);
    this.selectedCompany.set(bill.provider);
    this.referenceCode.set(bill.referenceCode);
  }

  protected categoryLabel(category: PaymentCategory): string {
    const labels: Record<string, string> = {
      'ELECTRICITY': 'Energía',
      'WATER': 'Agua',
      'GAS': 'Gas',
      'INTERNET': 'Internet',
      'PHONE': 'Telefonía',
      'TV': 'TV',
      'OTHER': 'Otro',
    };
    return labels[category] || category;
  }

  formatCurrency(n: number) {
    return '$' + n.toLocaleString('es-CO');
  }
}
