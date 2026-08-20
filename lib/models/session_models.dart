class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? providerId;
  final String? modelId;
  final String? agentId;
  final bool pinned;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.providerId,
    this.modelId,
    this.agentId,
    this.pinned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'providerId': providerId,
        'modelId': modelId,
        'agentId': agentId,
        'pinned': pinned,
      };

  factory ChatSession.fromJson(Map<String, dynamic> j) => ChatSession(
        id: j['id'] as String,
        title: j['title'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        providerId: j['providerId'] as String?,
        modelId: j['modelId'] as String?,
        agentId: j['agentId'] as String?,
        pinned: j['pinned'] as bool? ?? false,
      );
}
