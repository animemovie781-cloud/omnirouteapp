enum ProviderAuthType {
  apiKey,
  apiKeyHeader,
  none;

  String get label {
    switch (this) {
      case ProviderAuthType.apiKey:
        return 'API Key (Bearer)';
      case ProviderAuthType.apiKeyHeader:
        return 'API Key (Custom Header)';
      case ProviderAuthType.none:
        return 'None';
    }
  }
}

class ProviderCatalogEntry {
  final String id;
  final String name;
  final String defaultBaseUrl;
  final ProviderAuthType authType;
  final String? authHeaderName;
  final String? envVarHint;
  final bool builtIn;

  const ProviderCatalogEntry({
    required this.id,
    required this.name,
    required this.defaultBaseUrl,
    this.authType = ProviderAuthType.apiKey,
    this.authHeaderName,
    this.envVarHint,
    this.builtIn = true,
  });

  factory ProviderCatalogEntry.fromJson(Map<String, dynamic> json) {
    return ProviderCatalogEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      defaultBaseUrl: json['defaultBaseUrl'] as String,
      authType: ProviderAuthType.values.firstWhere(
        (e) => e.name == json['authType'],
        orElse: () => ProviderAuthType.apiKey,
      ),
      authHeaderName: json['authHeaderName'] as String?,
      envVarHint: json['envVarHint'] as String?,
      builtIn: json['builtIn'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'defaultBaseUrl': defaultBaseUrl,
      'authType': authType.name,
      'authHeaderName': authHeaderName,
      'envVarHint': envVarHint,
      'builtIn': builtIn,
    };
  }
}

class ProviderConfig {
  final String id;
  final String name;
  final String baseUrl;
  final bool enabled;
  final bool isCustom;
  final Map<String, String> extraHeaders;
  final List<String> modelWhitelist;
  final List<String> modelBlacklist;
  final DateTime createdAt;

  const ProviderConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
    this.enabled = true,
    this.isCustom = false,
    this.extraHeaders = const {},
    this.modelWhitelist = const [],
    this.modelBlacklist = const [],
    required this.createdAt,
  });

  factory ProviderConfig.fromJson(Map<String, dynamic> json) {
    final extraHeaders = <String, String>{};
    if (json['extraHeaders'] != null) {
      final map = json['extraHeaders'] as Map<String, dynamic>;
      for (final entry in map.entries) {
        extraHeaders[entry.key] = entry.value as String;
      }
    }
    final modelWhitelist = <String>[];
    if (json['modelWhitelist'] != null) {
      modelWhitelist.addAll(
        List<String>.from(json['modelWhitelist'] as List),
      );
    }
    final modelBlacklist = <String>[];
    if (json['modelBlacklist'] != null) {
      modelBlacklist.addAll(
        List<String>.from(json['modelBlacklist'] as List),
      );
    }
    return ProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      enabled: json['enabled'] as bool? ?? true,
      isCustom: json['isCustom'] as bool? ?? false,
      extraHeaders: extraHeaders,
      modelWhitelist: modelWhitelist,
      modelBlacklist: modelBlacklist,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'enabled': enabled,
      'isCustom': isCustom,
      'extraHeaders': extraHeaders,
      'modelWhitelist': modelWhitelist,
      'modelBlacklist': modelBlacklist,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProviderConfig copyWith({
    String? id,
    String? name,
    String? baseUrl,
    bool? enabled,
    bool? isCustom,
    Map<String, String>? extraHeaders,
    List<String>? modelWhitelist,
    List<String>? modelBlacklist,
    DateTime? createdAt,
  }) {
    return ProviderConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom ?? this.isCustom,
      extraHeaders: extraHeaders ?? this.extraHeaders,
      modelWhitelist: modelWhitelist ?? this.modelWhitelist,
      modelBlacklist: modelBlacklist ?? this.modelBlacklist,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
