class AgentDefinition {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final String? modelId;
  final String? providerId;
  final List<String> allowedTools;
  final int colorValue;
  final bool isBuiltIn;

  const AgentDefinition({
    required this.id,
    required this.name,
    this.description = '',
    this.systemPrompt = '',
    this.modelId,
    this.providerId,
    this.allowedTools = const [],
    this.colorValue = 0xFF2196F3,
    this.isBuiltIn = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'systemPrompt': systemPrompt,
        'modelId': modelId,
        'providerId': providerId,
        'allowedTools': allowedTools,
        'colorValue': colorValue,
        'isBuiltIn': isBuiltIn,
      };

  factory AgentDefinition.fromJson(Map<String, dynamic> j) => AgentDefinition(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        systemPrompt: j['systemPrompt'] as String? ?? '',
        modelId: j['modelId'] as String?,
        providerId: j['providerId'] as String?,
        allowedTools: List<String>.from(j['allowedTools'] ?? []),
        colorValue: j['colorValue'] as int? ?? 0xFF2196F3,
        isBuiltIn: j['isBuiltIn'] as bool? ?? false,
      );
}
