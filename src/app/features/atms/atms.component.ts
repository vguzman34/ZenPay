import { Component, ViewEncapsulation, signal, computed, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AtmService } from '../../shared/services/atm.service';
import { Atm } from '../../shared/models/atm.model';

@Component({
  selector: 'app-atms',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './atms.component.html',
  styleUrl: './atms.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class AtmsComponent implements OnInit {
  private readonly atmService = inject(AtmService);

  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly searchQuery = signal('');
  protected readonly selectedAtmId = signal<string | null>(null);
  protected readonly favoriteIds = signal<Set<string>>(new Set());
  protected readonly showFavoritesOnly = signal(false);

  protected readonly atms = signal<Atm[]>([]);

  ngOnInit(): void {
    this.loadData();
  }

  protected loadData(): void {
    this.error.set(null);
    this.loading.set(true);

    this.atmService.getFavorites().subscribe({
      next: (favs) => this.favoriteIds.set(new Set(favs.map(f => f.id))),
    });

    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (pos) => this.loadNearestAtms(pos.coords.latitude, pos.coords.longitude),
        () => this.loadNearestAtms(4.6097, -74.0817),
        { timeout: 10000 },
      );
    } else {
      this.loadNearestAtms(4.6097, -74.0817);
    }
  }

  private loadNearestAtms(lat: number, lng: number): void {
    this.atmService.getNearestAtms(lat, lng).subscribe({
      next: (data) => {
        this.atms.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('No se pudieron cargar los cajeros cercanos.');
        this.loading.set(false);
      },
    });
  }

  protected readonly filteredAtms = computed(() => {
    let list = this.atms();
    const q = this.searchQuery().toLowerCase().trim();
    if (q) list = list.filter(a => a.name.toLowerCase().includes(q) || a.bankName.toLowerCase().includes(q) || a.address.toLowerCase().includes(q));
    if (this.showFavoritesOnly()) list = list.filter(a => this.favoriteIds().has(a.id));
    return list;
  });

  protected readonly selectedAtm = computed(() => {
    const id = this.selectedAtmId();
    if (id === null) return null;
    return this.atms().find(a => a.id === id) ?? null;
  });

  protected readonly favorites = computed(() => this.atms().filter(a => this.favoriteIds().has(a.id)));

  protected toggleFavorite(atmId: string): void {
    const current = this.favoriteIds();
    const wasFavorited = current.has(atmId);
    const updated = new Set(current);
    wasFavorited ? updated.delete(atmId) : updated.add(atmId);
    this.favoriteIds.set(updated);

    this.atmService.toggleFavorite(atmId).subscribe({
      error: () => {
        const revert = new Set(this.favoriteIds());
        wasFavorited ? revert.add(atmId) : revert.delete(atmId);
        this.favoriteIds.set(revert);
      },
    });
  }

  protected selectAtm(id: string): void {
    this.selectedAtmId.set(id);
  }

  protected closeDetail(): void {
    this.selectedAtmId.set(null);
  }

  protected openMaps(lat: number, lng: number): void {
    window.open(`https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}`, '_blank');
  }

  protected openWaze(lat: number, lng: number): void {
    window.open(`https://waze.com/ul?ll=${lat},${lng}&navigate=yes`, '_blank');
  }

  protected getBankInitial(bankName: string): string {
    return bankName.charAt(0);
  }

  protected getBankColor(bankName: string): string {
    const colors: Record<string, string> = { Bancolombia: '#fdbb2d', Davivienda: '#e31b23', Nequi: '#00b8d4', BBVA: '#072146', Scotiabank: '#d0001c' };
    return colors[bankName] || '#6366f1';
  }

  protected formatDistance(meters: number): string {
    if (meters >= 1000) return `${(meters / 1000).toFixed(1)} km`;
    return `${Math.round(meters)} m`;
  }

  protected formatWalkingTime(minutes: number): string {
    return `${Math.round(minutes)} min`;
  }

  protected formatHours(atm: Atm): string {
    if (atm.isOpen24Hours) return '24hrs';
    return `${atm.openTime} - ${atm.closeTime}`;
  }

  protected readonly directions = computed(() => {
    const atm = this.selectedAtm();
    if (!atm) return [];
    return [
      { icon: '🚶', text: 'Sal de tu ubicación actual' },
      { icon: '🚶', text: `Camina aproximadamente ${this.formatWalkingTime(atm.walkingTime)}` },
      { icon: '📍', text: 'Llegaste a tu destino' },
    ];
  });
}
