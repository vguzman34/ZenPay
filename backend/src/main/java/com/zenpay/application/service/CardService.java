package com.zenpay.application.service;

import com.zenpay.application.dto.CardLimitRequest;
import com.zenpay.application.dto.CardResponse;
import com.zenpay.domain.model.Card;
import com.zenpay.domain.model.CardStatus;
import com.zenpay.domain.repository.CardRepository;
import com.zenpay.infrastructure.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CardService {

    private final CardRepository cardRepository;

    public List<CardResponse> getCards(UUID userId) {
        return cardRepository.findByUserId(userId).stream()
                .map(this::toCardResponse)
                .collect(Collectors.toList());
    }

    public CardResponse getCardById(UUID cardId) {
        Card card = findCardById(cardId);
        return toCardResponse(card);
    }

    @Transactional
    public CardResponse blockCard(UUID cardId) {
        Card card = findCardById(cardId);
        if (card.getStatus() == CardStatus.CANCELLED) {
            throw new BusinessException("CARD_CANCELLED", "Cannot block a cancelled card");
        }
        card.setStatus(CardStatus.BLOCKED);
        card = cardRepository.save(card);
        return toCardResponse(card);
    }

    @Transactional
    public CardResponse unblockCard(UUID cardId) {
        Card card = findCardById(cardId);
        if (card.getStatus() != CardStatus.BLOCKED) {
            throw new BusinessException("CARD_NOT_BLOCKED", "Card is not blocked");
        }
        card.setStatus(CardStatus.ACTIVE);
        card = cardRepository.save(card);
        return toCardResponse(card);
    }

    @Transactional
    public CardResponse adjustLimit(UUID cardId, CardLimitRequest request) {
        Card card = findCardById(cardId);
        if (card.getCreditLimit() == null) {
            throw new BusinessException("NO_CREDIT_CARD", "This card does not have a credit limit");
        }
        card.setCreditLimit(request.creditLimit());
        card.setAvailableLimit(request.creditLimit().subtract(card.getUsedLimit()));
        card = cardRepository.save(card);
        return toCardResponse(card);
    }

    private Card findCardById(UUID cardId) {
        return cardRepository.findById(cardId)
                .orElseThrow(() -> new BusinessException("CARD_NOT_FOUND", "Card not found"));
    }

    private CardResponse toCardResponse(Card card) {
        return new CardResponse(
                card.getId(), card.getCardType(), card.getStatus(), card.getCardNumber(),
                card.getCardHolderName(), card.getExpirationDate(), card.getCreditLimit(),
                card.getUsedLimit(), card.getAvailableLimit(), card.getCurrentBalance(),
                card.getPaymentDate(), card.getCutoffDate(), card.getIsVirtual(), card.getIssuedAt());
    }
}
