package com.zenpay.application.service;

import com.zenpay.application.dto.*;
import com.zenpay.domain.model.*;
import com.zenpay.domain.repository.TicketMessageRepository;
import com.zenpay.domain.repository.TicketRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TicketService {

    private final TicketRepository ticketRepository;
    private final TicketMessageRepository ticketMessageRepository;

    public List<TicketResponse> getTickets(UUID userId) {
        return ticketRepository.findByUserId(userId).stream()
                .map(this::toTicketResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public TicketResponse createTicket(UUID userId, TicketRequest request) {
        Ticket ticket = Ticket.builder()
                .user(User.builder().id(userId).build())
                .subject(request.subject())
                .description(request.description())
                .priority(request.priority() != null ? request.priority() : TicketPriority.MEDIUM)
                .category(request.category())
                .build();

        ticket = ticketRepository.save(ticket);
        return toTicketResponse(ticket);
    }

    public List<TicketMessageResponse> getMessages(UUID ticketId) {
        return ticketMessageRepository.findByTicketIdOrderByCreatedAtAsc(ticketId).stream()
                .map(m -> new TicketMessageResponse(
                        m.getId(), m.getMessage(), m.getSender(), m.getCreatedAt()))
                .collect(Collectors.toList());
    }

    @Transactional
    public TicketMessageResponse sendMessage(UUID ticketId, TicketMessageRequest request, String sender) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new BusinessException("TICKET_NOT_FOUND", "Ticket not found"));

        TicketMessage message = TicketMessage.builder()
                .ticket(ticket)
                .sender(sender)
                .message(request.message())
                .build();

        message = ticketMessageRepository.save(message);
        return new TicketMessageResponse(
                message.getId(), message.getMessage(), message.getSender(), message.getCreatedAt());
    }

    private TicketResponse toTicketResponse(Ticket ticket) {
        return new TicketResponse(
                ticket.getId(), ticket.getSubject(), ticket.getDescription(),
                ticket.getStatus(), ticket.getPriority(), ticket.getCategory(),
                ticket.getCreatedAt(), ticket.getUpdatedAt());
    }
}
