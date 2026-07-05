import { Component, ViewEncapsulation } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { SidebarComponent } from '../sidebar/sidebar.component';
import { NavbarComponent } from '../navbar/navbar.component';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [RouterOutlet, SidebarComponent, NavbarComponent],
  templateUrl: './main-layout.component.html',
  styleUrl: './main-layout.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class MainLayoutComponent {
  closeMobileSidebar(): void {
    document.body.classList.remove('sidebar-open');
    document.body.style.position = '';
    document.body.style.overflow = '';
    document.body.style.width = '';
  }
}
