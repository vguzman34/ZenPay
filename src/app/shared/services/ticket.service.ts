import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Ticket, TicketRequest, TicketMessage, TicketMessageRequest } from '../models/ticket.model';

@Injectable({ providedIn: 'root' })
export class TicketService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/tickets`;

  getTickets(): Observable<Ticket[]> {
    return this.http.get<Ticket[]>(this.apiUrl);
  }

  createTicket(request: TicketRequest): Observable<Ticket> {
    return this.http.post<Ticket>(this.apiUrl, request);
  }

  getMessages(ticketId: string): Observable<TicketMessage[]> {
    return this.http.get<TicketMessage[]>(`${this.apiUrl}/${ticketId}/messages`);
  }

  sendMessage(ticketId: string, request: TicketMessageRequest): Observable<TicketMessage> {
    return this.http.post<TicketMessage>(`${this.apiUrl}/${ticketId}/messages`, request);
  }
}
