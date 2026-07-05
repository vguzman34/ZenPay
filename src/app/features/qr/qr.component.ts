import { Component, ViewEncapsulation, signal, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { QrService } from '../../shared/services/qr.service';
import { QrGenerateRequest, QrPayment } from '../../shared/models/qr.model';

@Component({
  selector: 'app-qr',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './qr.component.html',
  styleUrl: './qr.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class QrComponent implements OnInit {
  private readonly qrService = inject(QrService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  tabs = ['Generar QR', 'Escanear QR', 'Historial'];
  selectedTab = signal(0);

  protected readonly qrHistory = signal<QrPayment[]>([]);

  qrAmount = signal(0);
  qrConcept = signal('');
  generatedQr = signal<QrPayment | null>(null);
  showSuccess = signal(false);

  ngOnInit(): void {
    this.loadHistory();
  }

  protected loadHistory(): void {
    this.loading.set(true);
    this.error.set(null);
    this.qrService.getQrHistory().subscribe({
      next: (history) => {
        this.qrHistory.set(history);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar el historial');
        this.loading.set(false);
      },
    });
  }

  selectTab(index: number) {
    this.selectedTab.set(index);
    if (index === 2) {
      this.loadHistory();
    }
  }

  generateQr() {
    const amount = this.qrAmount();
    const concept = this.qrConcept();
    if (!amount || amount <= 0 || !concept.trim()) return;

    this.generatedQr.set(null);
    const request: QrGenerateRequest = { amount, concept: concept.trim() };
    this.qrService.generateQr(request).subscribe({
      next: (qr) => {
        this.generatedQr.set(qr);
        this.qrHistory.update(list => [qr, ...list]);
      },
    });
  }

  clearQr() {
    this.generatedQr.set(null);
    this.qrAmount.set(0);
    this.qrConcept.set('');
  }

  protected statusIcon(status: string): string {
    switch (status) {
      case 'ACTIVE': return '🟢';
      case 'USED': return '🔵';
      case 'EXPIRED': return '🔴';
      case 'CANCELLED': return '⚪';
      default: return '';
    }
  }

  formatCurrency(n: number) {
    return '$' + n.toLocaleString('es-CO');
  }
}
