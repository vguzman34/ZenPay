import { Routes } from '@angular/router';
import { authGuard } from './shared/guards/auth.guard';
import { MainLayoutComponent } from './layout/main-layout/main-layout.component';
import { DashboardComponent } from './features/dashboard/dashboard.component';
import { AccountsComponent } from './features/accounts/accounts.component';
import { CardsComponent } from './features/cards/cards.component';
import { MovementsComponent } from './features/movements/movements.component';
import { TransfersComponent } from './features/transfers/transfers.component';
import { QrComponent } from './features/qr/qr.component';
import { RechargesComponent } from './features/recharges/recharges.component';
import { PaymentsComponent } from './features/payments/payments.component';
import { SavingsGoalsComponent } from './features/savings-goals/savings-goals.component';
import { LoansComponent } from './features/loans/loans.component';
import { InvestmentsComponent } from './features/investments/investments.component';
import { CashWithdrawalComponent } from './features/cash-withdrawal/cash-withdrawal.component';
import { AiAssistantComponent } from './features/ai-assistant/ai-assistant.component';
import { AtmsComponent } from './features/atms/atms.component';
import { SupportComponent } from './features/support/support.component';
import { NotificationsComponent } from './features/notifications/notifications.component';
import { ProfileComponent } from './features/profile/profile.component';
import { SecurityComponent } from './features/security/security.component';
import { LoginComponent } from './features/auth/login/login.component';

export const routes: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: DashboardComponent },
      { path: 'accounts', component: AccountsComponent },
      { path: 'cards', component: CardsComponent },
      { path: 'movements', component: MovementsComponent },
      { path: 'transfers', component: TransfersComponent },
      { path: 'qr', component: QrComponent },
      { path: 'recharges', component: RechargesComponent },
      { path: 'payments', component: PaymentsComponent },
      { path: 'savings-goals', component: SavingsGoalsComponent },
      { path: 'loans', component: LoansComponent },
      { path: 'investments', component: InvestmentsComponent },
      { path: 'cash-withdrawal', component: CashWithdrawalComponent },
      { path: 'ai-assistant', component: AiAssistantComponent },
      { path: 'atms', component: AtmsComponent },
      { path: 'support', component: SupportComponent },
      { path: 'notifications', component: NotificationsComponent },
      { path: 'profile', component: ProfileComponent },
      { path: 'security', component: SecurityComponent },
    ]
  },
  { path: 'login', component: LoginComponent },
  { path: '**', redirectTo: 'dashboard' }
];
