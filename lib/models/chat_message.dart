import 'code_snippet.dart';

enum MessageSender { user, ai, system }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final String? error;
  final List<CodeSnippet> extractedSnippets;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    DateTime? timestamp,
    this.isStreaming = false,
    this.error,
    List<CodeSnippet>? extractedSnippets,
  })  : timestamp = timestamp ?? DateTime.now(),
        extractedSnippets = extractedSnippets ?? _extractSnippets(id, content);

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
    String? error,
    List<CodeSnippet>? extractedSnippets,
  }) {
    final updatedContent = content ?? this.content;
    final updatedId = id ?? this.id;
    return ChatMessage(
      id: updatedId,
      sender: sender ?? this.sender,
      content: updatedContent,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error ?? this.error,
      extractedSnippets: extractedSnippets ?? _extractSnippets(updatedId, updatedContent),
    );
  }

  static List<CodeSnippet> _extractSnippets(String messageId, String text) {
    final List<CodeSnippet> snippets = [];
    final RegExp codeBlockRegex = RegExp(r'```([a-zA-Z0-9_\+#\-]*)\n([\s\S]*?)```');
    final matches = codeBlockRegex.allMatches(text);

    int count = 1;
    for (final match in matches) {
      final lang = match.group(1)?.trim();
      final code = match.group(2) ?? '';
      final language = (lang == null || lang.isEmpty) ? 'dart' : lang;
      snippets.add(
        CodeSnippet(
          id: '${messageId}_snippet_$count',
          language: language,
          code: code,
          title: 'Code Snippet #$count ($language)',
          sourceMessageId: messageId,
        ),
      );
      count++;
    }
    return snippets;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final senderEnum = MessageSender.values.firstWhere(
      (e) => e.name == json['sender'],
      orElse: () => MessageSender.user,
    );
    final id = json['id'] as String;
    final content = json['content'] as String? ?? '';
    return ChatMessage(
      id: id,
      sender: senderEnum,
      content: content,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      error: json['error'] as String?,
      extractedSnippets: _extractSnippets(id, content),
    );
  }
}
