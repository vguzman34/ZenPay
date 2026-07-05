import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { SavingsGoal, GoalContributeRequest } from '../models/savings-goal.model';
import { AccountMovement } from '../models/movement.model';

@Injectable({ providedIn: 'root' })
export class SavingsGoalService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/savings-goals`;

  getGoals(): Observable<SavingsGoal[]> {
    return this.http.get<SavingsGoal[]>(this.apiUrl);
  }

  createGoal(goal: Partial<SavingsGoal>): Observable<SavingsGoal> {
    return this.http.post<SavingsGoal>(this.apiUrl, goal);
  }

  contributeToGoal(id: string, request: GoalContributeRequest): Observable<SavingsGoal> {
    return this.http.post<SavingsGoal>(`${this.apiUrl}/${id}/contribute`, request);
  }

  getGoalMovements(id: string): Observable<AccountMovement[]> {
    return this.http.get<AccountMovement[]>(`${this.apiUrl}/${id}/movements`);
  }
}
