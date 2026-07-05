import { Injectable, signal, computed } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class ThemeStore {
  private readonly storageKey = 'zenpay_theme';

  readonly isDarkMode = signal<boolean>(this.loadPreference());

  readonly themeClass = computed(() => this.isDarkMode() ? 'dark' : 'light');

  constructor() {
    this.applyTheme();
  }

  toggleTheme(): void {
    this.isDarkMode.update(val => !val);
    this.persistPreference();
    this.applyTheme();
  }

  private applyTheme(): void {
    if (this.isDarkMode()) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }

  private loadPreference(): boolean {
    const stored = localStorage.getItem(this.storageKey);
    if (stored !== null) {
      return stored === 'true';
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches;
  }

  private persistPreference(): void {
    localStorage.setItem(this.storageKey, String(this.isDarkMode()));
  }
}
