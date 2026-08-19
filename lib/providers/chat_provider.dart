import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/ai_service_factory.dart';
import 'settings_provider.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String? activeMessageId;

  ChatState({
    required this.messages,
    this.isGenerating = false,
    this.activeMessageId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? activeMessageId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      activeMessageId: activeMessageId ?? this.activeMessageId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  StreamSubscription<String>? _streamSub;
  static const _uuid = Uuid();

  ChatNotifier(this._ref)
      : super(ChatState(messages: [
          ChatMessage(
            id: 'welcome_1',
            sender: MessageSender.ai,
            content:
                'Welcome to **Antigravity AI Code Editor**! 🚀\n\nI can help you write, explain, refactor, and review code across multiple languages.\n\n```dart\n// Example: Quick Flutter Code\nimport "package:flutter/material.dart";\n\nvoid main() {\n  runApp(const MaterialApp(\n    home: Scaffold(\n      body: Center(child: Text("Antigravity Ready!")),\n    ),\n  ));\n}\n```\n\nType your prompt below or configure your AI Provider API keys in Settings.',
          )
        ]));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isGenerating) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.user,
      content: text,
    );

    final aiMessageId = _uuid.v4();
    final aiMessagePlaceholder = ChatMessage(
      id: aiMessageId,
      sender: MessageSender.ai,
      content: '',
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, aiMessagePlaceholder],
      isGenerating: true,
      activeMessageId: aiMessageId,
    );

    final settings = _ref.read(settingsProvider);
    final activeConfig = settings.activeConfig;
    final aiService = AIServiceFactory.getService(activeConfig.provider);

    final messageHistory = state.messages
        .where((m) => m.id != aiMessageId)
        .toList();

    final buffer = StringBuffer();

    _streamSub = aiService
        .streamCompletion(messages: messageHistory, config: activeConfig)
        .listen(
      (chunk) {
        buffer.write(chunk);
        final updatedContent = buffer.toString();
        _updateAiMessage(aiMessageId, updatedContent, isStreaming: true);
      },
      onError: (err) {
        _updateAiMessage(
          aiMessageId,
          buffer.isNotEmpty ? buffer.toString() : 'Error generating response: $err',
          isStreaming: false,
          error: err.toString(),
        );
        _finishStream();
      },
      onDone: () {
        _updateAiMessage(
          aiMessageId,
          buffer.toString(),
          isStreaming: false,
        );
        _finishStream();
      },
    );
  }

  void _updateAiMessage(
    String id,
    String content, {
    required bool isStreaming,
    String? error,
  }) {
    final updatedList = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(
          content: content,
          isStreaming: isStreaming,
          error: error,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updatedList);
  }

  void stopGeneration() {
    _streamSub?.cancel();
    _streamSub = null;
    if (state.activeMessageId != null) {
      _updateAiMessage(state.activeMessageId!, state.messages.firstWhere((m) => m.id == state.activeMessageId).content, isStreaming: false);
    }
    state = state.copyWith(isGenerating: false, activeMessageId: null);
  }

  void _finishStream() {
    _streamSub = null;
    state = state.copyWith(isGenerating: false, activeMessageId: null);
  }

  void clearChat() {
    stopGeneration();
    state = ChatState(messages: []);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
