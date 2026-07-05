import { Component, ViewEncapsulation, OnInit, signal, computed, inject } from '@angular/core';
import { CardService } from '../../shared/services';
import { Card as ApiCard, CardLimitRequest } from '../../shared/models';

interface SpendingCategory {
  label: string;
  percentage: number;
  color: string;
  icon: string;
}

interface Purchase {
  date: string;
  description: string;
  amount: number;
  category: string;
  installments?: string;
  status: string;
}

interface Card {
  id: string;
  cardType: 'visa' | 'mastercard' | 'debito' | 'virtual';
  brand: string;
  status: 'ACTIVE' | 'BLOCKED';
  cardNumber: string;
  maskedNumber: string;
  cardHolderName: string;
  expirationDate: string;
  creditLimit: number;
  usedLimit: number;
  availableLimit: number;
  currentBalance: number;
  paymentDate: number;
  cutoffDate: number;
  isVirtual: boolean;
  colorStart: string;
  colorEnd: string;
  textColor: string;
  spendingByCategory: SpendingCategory[];
  recentPurchases: Purchase[];
}

@Component({
  selector: 'app-cards',
  standalone: true,
  templateUrl: './cards.component.html',
  styleUrl: './cards.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class CardsComponent implements OnInit {
  private readonly cardService = inject(CardService);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly cards = signal<Card[]>([]);

  protected readonly selectedCardId = signal<string | null>(null);
  protected readonly showData = signal(false);
  protected readonly flippedCardId = signal<string | null>(null);

  protected readonly selectedCard = computed(() => {
    const id = this.selectedCardId();
    if (id === null) return null;
    return this.cards().find(c => c.id === id) ?? null;
  });

  ngOnInit(): void {
    this.loadCards();
  }

  protected loadCards(): void {
    this.loading.set(true);
    this.error.set(null);
    this.cardService.getCards().subscribe({
      next: (apiCards) => {
        const mapped = apiCards.map(c => this.mapCard(c));
        this.cards.set(mapped);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Error al cargar las tarjetas');
        this.loading.set(false);
      },
    });
  }

  private mapCard(c: ApiCard): Card {
    const brand = this.getCardBrand(c.cardType);
    return {
      id: c.id,
      cardType: this.getCardType(c.cardType),
      brand,
      status: c.status === 'ACTIVE' ? 'ACTIVE' : 'BLOCKED',
      cardNumber: c.cardNumber,
      maskedNumber: '**** **** **** ' + c.cardNumber.slice(-4),
      cardHolderName: c.cardHolderName,
      expirationDate: c.expirationDate,
      creditLimit: c.creditLimit,
      usedLimit: c.usedLimit,
      availableLimit: c.availableLimit,
      currentBalance: c.currentBalance,
      paymentDate: c.paymentDate,
      cutoffDate: c.cutoffDate,
      isVirtual: c.isVirtual,
      colorStart: this.getCardColors(c.cardType).start,
      colorEnd: this.getCardColors(c.cardType).end,
      textColor: '#fff',
      spendingByCategory: [],
      recentPurchases: [],
    };
  }

  private getCardBrand(type: string): string {
    switch (type) {
      case 'VISA_INFINITE': return 'VISA';
      case 'MASTERCARD_BLACK': return 'MASTERCARD';
      case 'DEBIT_PREMIUM': return 'DEBITO';
      case 'VIRTUAL': return 'VISA';
      default: return 'VISA';
    }
  }

  private getCardType(type: string): 'visa' | 'mastercard' | 'debito' | 'virtual' {
    switch (type) {
      case 'VISA_INFINITE': return 'visa';
      case 'MASTERCARD_BLACK': return 'mastercard';
      case 'DEBIT_PREMIUM': return 'debito';
      case 'VIRTUAL': return 'virtual';
      default: return 'visa';
    }
  }

  private getCardColors(type: string): { start: string; end: string } {
    switch (type) {
      case 'VISA_INFINITE': return { start: '#b8860b', end: '#f0d78c' };
      case 'MASTERCARD_BLACK': return { start: '#1a1a2e', end: '#4a4a6a' };
      case 'DEBIT_PREMIUM': return { start: '#0066cc', end: '#4d94ff' };
      case 'VIRTUAL': return { start: '#6c5ce7', end: '#a29bfe' };
      default: return { start: '#0066cc', end: '#4d94ff' };
    }
  }

  protected selectCard(id: string): void {
    this.selectedCardId.set(id);
    this.flippedCardId.set(null);
  }

  protected closeDetail(): void {
    this.selectedCardId.set(null);
  }

  protected toggleShowData(): void {
    this.showData.update(v => !v);
  }

  protected toggleFlip(cardId: string): void {
    this.flippedCardId.update(v => v === cardId ? null : cardId);
  }

  protected toggleCardStatus(cardId: string): void {
    const card = this.cards().find(c => c.id === cardId);
    if (!card) return;

    const obs = card.status === 'ACTIVE'
      ? this.cardService.blockCard(cardId)
      : this.cardService.unblockCard(cardId);

    obs.subscribe({
      next: (updated) => {
        this.cards.update(cards => cards.map(c =>
          c.id === cardId ? { ...c, status: updated.status === 'ACTIVE' ? 'ACTIVE' : 'BLOCKED' } : c
        ));
      },
      error: () => {
        this.error.set('Error al cambiar estado de la tarjeta');
      },
    });
  }

  protected adjustLimit(): void {
    const card = this.selectedCard();
    if (!card) return;
    const request: CardLimitRequest = { creditLimit: card.creditLimit };
    this.cardService.adjustLimit(card.id, request).subscribe({
      next: () => {
        this.loadCards();
      },
      error: () => {
        this.error.set('Error al ajustar límite');
      },
    });
  }

  protected getDisplayNumber(card: Card): string {
    return this.showData() ? card.cardNumber : card.maskedNumber;
  }

  protected formatCurrency(amount: number): string {
    return '$' + amount.toLocaleString('es-CO');
  }

  protected getCardIcon(cardType: string): string {
    switch (cardType) {
      case 'visa': return 'credit_card';
      case 'mastercard': return 'credit_card';
      case 'debito': return 'account_balance';
      case 'virtual': return 'qr_code_scanner';
      default: return 'credit_card';
    }
  }
}
