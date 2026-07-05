import { Component, ViewEncapsulation, signal, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AiAssistantService, AiChatResponse } from '../../shared/services/ai-assistant.service';

interface ChatMessage {
  text: string;
  isUser: boolean;
  timestamp: Date;
}

@Component({
  selector: 'app-ai-assistant',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './ai-assistant.component.html',
  styleUrl: './ai-assistant.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class AiAssistantComponent {
  private readonly aiService = inject(AiAssistantService);

  protected readonly messages = signal<ChatMessage[]>([
    { text: '¡Hola! Soy ZenIA, tu asistente financiero. ¿En qué puedo ayudarte hoy?', isUser: false, timestamp: new Date() },
  ]);
  protected readonly inputText = signal('');
  protected readonly isTyping = signal(false);

  protected readonly suggestions = [
    '¿Cuánto gasté este mes?',
    '¿Cuál es mi saldo total?',
    '¿Cómo van mis metas de ahorro?',
    '¿Qué gastos puedo reducir?',
  ];

  protected sendMessage(): void {
    const text = this.inputText().trim();
    if (!text || this.isTyping()) return;

    this.messages.update(msgs => [...msgs, { text, isUser: true, timestamp: new Date() }]);
    this.inputText.set('');
    this.isTyping.set(true);

    this.aiService.chat({ message: text }).subscribe({
      next: (res: AiChatResponse) => {
        this.messages.update(msgs => [...msgs, { text: res.response, isUser: false, timestamp: new Date() }]);
        this.isTyping.set(false);
      },
      error: () => {
        this.messages.update(msgs => [...msgs, {
          text: 'Lo siento, no pude procesar tu consulta. Intenta de nuevo.',
          isUser: false,
          timestamp: new Date()
        }]);
        this.isTyping.set(false);
      }
    });
  }

  protected selectSuggestion(text: string): void {
    this.inputText.set(text);
    this.sendMessage();
  }
}
