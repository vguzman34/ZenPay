import { Component, ViewEncapsulation, signal, computed, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TicketService } from '../../shared/services/ticket.service';
import { Ticket, TicketRequest, TicketMessage, TicketPriority } from '../../shared/models/ticket.model';

interface FaqItem {
  question: string;
  answer: string;
}

@Component({
  selector: 'app-support',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './support.component.html',
  styleUrl: './support.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class SupportComponent implements OnInit {
  private readonly ticketService = inject(TicketService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly selectedTab = signal<'mis-tickets' | 'nuevo-ticket'>('mis-tickets');
  protected readonly selectedTicketId = signal<string | null>(null);
  protected readonly expandedFaq = signal<number | null>(null);

  protected readonly newSubject = signal('');
  protected readonly newDescription = signal('');
  protected readonly newCategory = signal('general');
  protected readonly newPriority = signal<'low' | 'medium' | 'high'>('medium');

  protected readonly tickets = signal<Ticket[]>([]);
  protected readonly selectedTicketMessages = signal<TicketMessage[]>([]);

  protected readonly faqItems: FaqItem[] = [
    { question: '¿Cómo puedo bloquear mi tarjeta?', answer: 'Puedes bloquear tu tarjeta desde la sección "Tarjetas" en la app, o llamando a nuestra línea de atención 24/7 al #123 desde tu celular.' },
    { question: '¿Cuánto tiempo tarda una transferencia entre cuentas ZenPay?', answer: 'Las transferencias entre cuentas ZenPay son inmediatas. Si envías a otro banco, puede tardar hasta 24 horas hábiles.' },
    { question: '¿Cómo activo las notificaciones de seguridad?', answer: 'Ve a Configuración > Seguridad > Notificaciones y selecciona las alertas que deseas recibir: inicios de sesión, compras internacionales, cambios de clave, etc.' },
    { question: '¿Cuál es el límite diario de retiro sin tarjeta?', answer: 'El límite diario es de $3,000,000 COP. Cada código generado tiene un valor máximo de $500,000 COP y expira en 60 minutos.' },
  ];

  ngOnInit(): void {
    this.loadTickets();
  }

  protected loadTickets(): void {
    this.loading.set(true);
    this.error.set(null);
    this.ticketService.getTickets().subscribe({
      next: (data) => {
        this.tickets.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('No se pudieron cargar los tickets.');
        this.loading.set(false);
      },
    });
  }

  protected readonly selectedTicket = computed(() => {
    const id = this.selectedTicketId();
    if (id === null) return null;
    return this.tickets().find(t => t.id === id) ?? null;
  });

  protected selectTicket(id: string): void {
    this.selectedTicketId.set(id);
    this.loading.set(true);
    this.ticketService.getMessages(id).subscribe({
      next: (msgs) => {
        this.selectedTicketMessages.set(msgs);
        this.loading.set(false);
      },
      error: () => {
        this.selectedTicketMessages.set([]);
        this.loading.set(false);
      },
    });
  }

  protected closeTicketDetail(): void {
    this.selectedTicketId.set(null);
    this.selectedTicketMessages.set([]);
  }

  protected submitTicket(): void {
    if (!this.newSubject().trim() || !this.newDescription().trim()) return;
    const request: TicketRequest = {
      subject: this.newSubject(),
      description: this.newDescription(),
      priority: this.newPriority().toUpperCase() as TicketPriority,
      category: this.newCategory(),
    };
    this.ticketService.createTicket(request).subscribe({
      next: (ticket) => {
        this.tickets.update(list => [ticket, ...list]);
        this.newSubject.set('');
        this.newDescription.set('');
        this.newCategory.set('general');
        this.newPriority.set('medium');
        this.selectedTab.set('mis-tickets');
      },
    });
  }

  protected toggleFaq(index: number): void {
    this.expandedFaq.update(i => i === index ? null : index);
  }

  protected getPriorityIcon(priority: string): string {
    const icons: Record<string, string> = { HIGH: '🔴', MEDIUM: '⚡', LOW: '📋', URGENT: '🚨', high: '🔴', medium: '⚡', low: '📋' };
    return icons[priority] ?? '📋';
  }

  protected getStatusClass(status: string): string {
    const classes: Record<string, string> = { OPEN: 'status-open', IN_PROGRESS: 'status-in-progress', RESOLVED: 'status-resolved', CLOSED: 'status-resolved' };
    return classes[status] ?? '';
  }

  protected getStatusLabel(status: string): string {
    const labels: Record<string, string> = { OPEN: 'Abierto', IN_PROGRESS: 'En Proceso', RESOLVED: 'Resuelto', CLOSED: 'Cerrado' };
    return labels[status] ?? status;
  }

  protected setPriority(value: string): void {
    this.newPriority.set(value as 'low' | 'medium' | 'high');
  }

  protected isAgentMessage(msg: TicketMessage): boolean {
    return msg.sender.toLowerCase() !== 'tú' && msg.sender.length > 0;
  }
}
