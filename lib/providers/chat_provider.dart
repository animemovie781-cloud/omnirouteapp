import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import '../providers/session_controller.dart';
import '../providers/agent_controller.dart';
import 'settings_provider.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final bool autoScroll;
  final String? activeMessageId;

  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.autoScroll = true,
    this.activeMessageId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    bool? autoScroll,
    String? activeMessageId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      autoScroll: autoScroll ?? this.autoScroll,
      activeMessageId: activeMessageId ?? this.activeMessageId,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final Ref _ref;
  StreamSubscription<String>? _streamSub;
  static const _uuid = Uuid();
  String? _currentSessionId;

  ChatController(this._ref)
      : super(const ChatState(messages: [
          ChatMessage(
            id: 'welcome_1',
            role: MessageRole.assistant,
            parts: [
              TextPart(
                id: 'p1',
                text: 'Welcome to **Antigravity AI Code Editor**! 🚀\n\nI can help you write, explain, refactor, and review code across multiple languages.\n\n```dart\n// Example: Quick Flutter Code\nimport "package:flutter/material.dart";\n\nvoid main() {\n  runApp(const MaterialApp(\n    home: Scaffold(\n      body: Center(child: Text("Antigravity Ready!")),\n    ),\n  ));\n}\n```\n\nType your prompt below or configure your AI Provider API keys in Settings.',
              ),
            ],
          ),
        ]));

  Future<void> loadActiveSession() async {
    final sessionId = _ref.read(activeSessionIdProvider);
    await _loadSession(sessionId);
  }

  Future<void> _loadSession(String? sessionId) async {
    if (sessionId == null) {
      _currentSessionId = null;
      state = const ChatState(messages: [
        ChatMessage(
          id: 'welcome_1',
          role: MessageRole.assistant,
          parts: [
            TextPart(
              id: 'p1',
              text: 'Welcome to **Antigravity AI Code Editor**! 🚀\n\nSelect or create a session from the menu to get started.',
            ),
          ],
        ),
      ]);
      return;
    }

    _currentSessionId = sessionId;
    final repo = _ref.read(sessionRepoProvider);
    try {
      final box = await repo.messagesBox(sessionId);
      final raw = box.values.toList();
      final messages = <ChatMessage>[];
      for (final entry in raw) {
        if (entry is Map<String, dynamic>) {
          messages.add(ChatMessage.fromJson(entry));
        }
      }
      if (messages.isEmpty) {
        messages.add(
          const ChatMessage(
            id: 'welcome_1',
            role: MessageRole.assistant,
            parts: [
              TextPart(
                id: 'p1',
                text: 'New session started. How can I help you today?',
              ),
            ],
          ),
        );
      }
      state = ChatState(messages: messages);
    } catch (e) {
      state = ChatState(messages: [
        ChatMessage(
          id: 'welcome_1',
          role: MessageRole.assistant,
          parts: [TextPart(id: 'p1', text: 'Session loaded. How can I help?')],
        ),
      ]);
    }
  }

  Future<void> _persistMessage(ChatMessage message) async {
    final sessionId = _currentSessionId;
    if (sessionId == null) return;
    final repo = _ref.read(sessionRepoProvider);
    try {
      final box = await repo.messagesBox(sessionId);
      await box.put(message.id, message.toJson());
    } catch (_) {}
  }

  Future<void> _updateSessionTimestamp() async {
    final sessionId = _currentSessionId;
    if (sessionId == null) return;
    final repo = _ref.read(sessionRepoProvider);
    try {
      final sessions = await repo.getAll();
      final s = sessions.firstWhere((e) => e.id == sessionId);
      final updated = ChatSession(
        id: s.id,
        title: s.title,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
        providerId: s.providerId,
        modelId: s.modelId,
        agentId: s.agentId,
        pinned: s.pinned,
      );
      await repo.upsert(updated);
      _ref.invalidate(sessionsProvider);
    } catch (_) {}
  }

  Future<void> _autoTitle(String firstUserText) async {
    final sessionId = _currentSessionId;
    if (sessionId == null) return;
    final repo = _ref.read(sessionRepoProvider);
    try {
      final sessions = await repo.getAll();
      final s = sessions.firstWhere((e) => e.id == sessionId);
      if (s.title == 'New chat') {
        final title = firstUserText.length > 40 ? '${firstUserText.substring(0, 40)}...' : firstUserText;
        await repo.upsert(ChatSession(
              id: s.id,
              title: title,
              createdAt: s.createdAt,
              updatedAt: DateTime.now(),
              providerId: s.providerId,
              modelId: s.modelId,
              agentId: s.agentId,
              pinned: s.pinned,
            ));
        _ref.invalidate(sessionsProvider);
      }
    } catch (_) {}
  }

  void addUserMessage(String text, {List<FilePart> attachments = const []}) {
    final msg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      parts: [TextPart(id: 'p1', text: text), ...attachments],
    );
    state = state.copyWith(messages: [...state.messages, msg]);
    _persistMessage(msg);
    _updateSessionTimestamp();
    if (text.trim().isNotEmpty) {
      _autoTitle(text.trim());
    }
  }

  String _getOrCreateAssistantMessageId() {
    if (state.activeMessageId != null) {
      return state.activeMessageId!;
    }
    final id = _uuid.v4();
    final placeholder = ChatMessage(
      id: id,
      role: MessageRole.assistant,
      parts: [TextPart(id: 'stream', text: '', streaming: true)],
    );
    state = state.copyWith(
      messages: [...state.messages, placeholder],
      isStreaming: true,
      activeMessageId: id,
    );
    _persistMessage(placeholder);
    return id;
  }

  void appendAssistantChunk(String messageId, String chunk) {
    final updated = state.messages.map((m) {
      if (m.id != messageId) return m;
      final parts = [...m.parts];
      final lastIdx = parts.lastIndexWhere((p) => p is TextPart);
      if (lastIdx == -1) {
        parts.add(TextPart(id: 'stream', text: chunk, streaming: true));
      } else {
        final old = parts[lastIdx] as TextPart;
        parts[lastIdx] = TextPart(id: old.id, text: old.text + chunk, streaming: true);
      }
      return ChatMessage(
        id: m.id,
        role: m.role,
        parts: parts,
        createdAt: m.createdAt,
        providerId: m.providerId,
        modelId: m.modelId,
      );
    }).toList();
    state = state.copyWith(messages: updated);
    _persistMessage(updated.firstWhere((m) => m.id == messageId));
  }

  void finishStreaming(String messageId) {
    final updated = state.messages.map((m) {
      if (m.id != messageId) return m;
      final parts = m.parts.map((p) {
        if (p is TextPart) {
          return TextPart(id: p.id, text: p.text, streaming: false);
        }
        return p;
      }).toList();
      return ChatMessage(
        id: m.id,
        role: m.role,
        parts: parts,
        createdAt: m.createdAt,
        providerId: m.providerId,
        modelId: m.modelId,
      );
    }).toList();
    state = state.copyWith(messages: updated, isStreaming: false, activeMessageId: null);
    _persistMessage(updated.firstWhere((m) => m.id == messageId));
    _updateSessionTimestamp();
  }

  void updateToolPart(String messageId, String toolPartId, ToolPart updatedPart) {
    final updated = state.messages.map((m) {
      if (m.id != messageId) return m;
      final parts = m.parts.map((p) {
        if (p.id == toolPartId) return updatedPart;
        return p;
      }).toList();
      return ChatMessage(
        id: m.id,
        role: m.role,
        parts: parts,
        createdAt: m.createdAt,
        providerId: m.providerId,
        modelId: m.modelId,
      );
    }).toList();
    state = state.copyWith(messages: updated);
    _persistMessage(updated.firstWhere((m) => m.id == messageId));
  }

  void setAutoScroll(bool value) => state = state.copyWith(autoScroll: value);

  Future<void> sendMessage(String text, {List<FilePart> attachments = const []}) async {
    if (text.trim().isEmpty && attachments.isEmpty) return;
    if (state.isStreaming) return;

    final settings = _ref.read(settingsProvider);
    final activeConfig = settings.activeConfig;

    String? agentSystemPrompt;
    final sessionId = _ref.read(activeSessionIdProvider);
    if (sessionId != null) {
      try {
        final repo = _ref.read(sessionRepoProvider);
        final sessions = await repo.getAll();
        final session = sessions.firstWhere((s) => s.id == sessionId);
        if (session.agentId != null) {
          final agents = await _ref.read(agentsProvider.future);
          final agent = agents.firstWhereOrNull((a) => a.id == session.agentId);
          if (agent != null && agent.systemPrompt.isNotEmpty) {
            agentSystemPrompt = agent.systemPrompt;
          }
        }
      } catch (_) {}
    }

    addUserMessage(text, attachments: attachments);

    final messageId = _getOrCreateAssistantMessageId();

    final client = http.Client();
    try {
      final url = Uri.parse('${activeConfig.baseUrl}/chat/completions');
      final request = http.Request('POST', url);

      final historyMessages = <Map<String, String>>[];
      if (agentSystemPrompt != null) {
        historyMessages.add({'role': 'system', 'content': agentSystemPrompt});
      } else if (activeConfig.systemPrompt.isNotEmpty) {
        historyMessages.add({'role': 'system', 'content': activeConfig.systemPrompt});
      }
      for (final m in state.messages) {
        if (m.role == MessageRole.user) {
          final content = m.parts.whereType<TextPart>().map((p) => p.text).join('\n');
          historyMessages.add({'role': 'user', 'content': content});
        } else if (m.role == MessageRole.assistant) {
          final content = m.parts.whereType<TextPart>().map((p) => p.text).join('\n');
          if (content.isNotEmpty) {
            historyMessages.add({'role': 'assistant', 'content': content});
          }
        }
      }

      final headers = <String, String>{'Content-Type': 'application/json'};
      if (activeConfig.apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${activeConfig.apiKey}';
      }

      request.headers.addAll(headers);
      request.body = jsonEncode({
        'model': activeConfig.modelName,
        'messages': historyMessages,
        'temperature': activeConfig.temperature,
        'max_tokens': activeConfig.maxTokens,
        'stream': true,
      });

      final streamed = await client.send(request);
      if (streamed.statusCode != 200) {
        final body = await streamed.stream.bytesToString();
        finishStreaming(messageId);
        final errorPart = ErrorPart(id: 'err', message: 'Error ${streamed.statusCode}: $body');
        final updated = state.messages.map((m) {
          if (m.id != messageId) return m;
          return ChatMessage(
            id: m.id,
            role: m.role,
            parts: [...m.parts, errorPart],
            createdAt: m.createdAt,
            providerId: m.providerId,
            modelId: m.modelId,
            isError: true,
          );
        }).toList();
        state = state.copyWith(messages: updated);
        return;
      }

      final stream = streamed.stream.transform(utf8.decoder).transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data == '[DONE]') break;
          try {
            final jsonMap = jsonDecode(data);
            final choices = jsonMap['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices[0]['delta'];
              if (delta != null && delta['content'] != null) {
                appendAssistantChunk(messageId, delta['content'] as String);
              }
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      final errorPart = ErrorPart(id: 'err', message: 'Connection Error: ${e.toString()}');
      final updated = state.messages.map((m) {
        if (m.id != messageId) return m;
        return ChatMessage(
          id: m.id,
          role: m.role,
          parts: [...m.parts, errorPart],
          createdAt: m.createdAt,
          providerId: m.providerId,
          modelId: m.modelId,
          isError: true,
        );
      }).toList();
      state = state.copyWith(messages: updated, isStreaming: false, activeMessageId: null);
      _persistMessage(updated.firstWhere((m) => m.id == messageId));
    } finally {
      client.close();
      if (state.activeMessageId == messageId) {
        finishStreaming(messageId);
      }
    }
  }

  void stopGeneration() {
    _streamSub?.cancel();
    _streamSub = null;
    if (state.activeMessageId != null) {
      finishStreaming(state.activeMessageId!);
    }
    state = state.copyWith(isStreaming: false, activeMessageId: null);
  }

  void clearChat() {
    stopGeneration();
    state = const ChatState(messages: []);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref);
});
