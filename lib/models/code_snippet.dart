class CodeSnippet {
  final String id;
  final String language;
  final String code;
  final String title;
  final String sourceMessageId;
  final DateTime timestamp;

  CodeSnippet({
    required this.id,
    required this.language,
    required this.code,
    required this.title,
    required this.sourceMessageId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  CodeSnippet copyWith({
    String? id,
    String? language,
    String? code,
    String? title,
    String? sourceMessageId,
    DateTime? timestamp,
  }) {
    return CodeSnippet(
      id: id ?? this.id,
      language: language ?? this.language,
      code: code ?? this.code,
      title: title ?? this.title,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'code': code,
      'title': title,
      'sourceMessageId': sourceMessageId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CodeSnippet.fromJson(Map<String, dynamic> json) {
    return CodeSnippet(
      id: json['id'] as String,
      language: json['language'] as String? ?? 'dart',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? 'Snippet',
      sourceMessageId: json['sourceMessageId'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
