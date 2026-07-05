export type TicketStatus = 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';
export type TicketPriority = 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';

export interface TicketRequest {
  subject: string;
  description: string;
  priority: TicketPriority;
  category: string;
}

export interface Ticket {
  id: string;
  subject: string;
  description: string;
  status: TicketStatus;
  priority: TicketPriority;
  category: string;
  createdAt: string;
  updatedAt: string;
}

export interface TicketMessageRequest {
  message: string;
}

export interface TicketMessage {
  id: string;
  message: string;
  sender: string;
  createdAt: string;
}
