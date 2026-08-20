enum AIProvider {
  openai,
  anthropic,
  gemini,
  ollama,
  omniroute,
  openrouter,
}

extension AIProviderExtension on AIProvider {
  String get displayName {
    switch (this) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.anthropic:
        return 'Anthropic (Claude)';
      case AIProvider.gemini:
        return 'Google Gemini';
      case AIProvider.ollama:
        return 'Ollama (Local)';
      case AIProvider.omniroute:
        return 'Omniroute Gateway';
      case AIProvider.openrouter:
        return 'OpenRouter';
    }
  }

  String get defaultBaseUrl {
    switch (this) {
      case AIProvider.openai:
        return 'https://api.openai.com/v1';
      case AIProvider.anthropic:
        return 'https://api.anthropic.com/v1';
      case AIProvider.gemini:
        return 'https://generativelanguage.googleapis.com/v1beta';
      case AIProvider.ollama:
        return 'http://localhost:11434/api';
      case AIProvider.omniroute:
        return 'http://localhost:8000/v1';
      case AIProvider.openrouter:
        return 'https://openrouter.ai/api/v1';
    }
  }

  List<String> get defaultModels {
    switch (this) {
      case AIProvider.openai:
        return ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-3.5-turbo'];
      case AIProvider.anthropic:
        return ['claude-3-5-sonnet-20240620', 'claude-3-haiku-20240307', 'claude-3-opus-20240229'];
      case AIProvider.gemini:
        return ['gemini-1.5-pro', 'gemini-1.5-flash'];
      case AIProvider.ollama:
        return ['codellama', 'llama3', 'mistral', 'deepseek-coder'];
      case AIProvider.omniroute:
        return ['omni/auto', 'omni/best-coding', 'omni/fast'];
      case AIProvider.openrouter:
        return [
          'openai/gpt-4o',
          'anthropic/claude-3.5-sonnet',
          'google/gemini-pro-1.5',
          'meta-llama/llama-3.1-70b-instruct',
        ];
    }
  }
}

class AIModelConfig {
  final AIProvider provider;
  final String modelName;
  final String apiKey;
  final String baseUrl;
  final double temperature;
  final int maxTokens;
  final String systemPrompt;

  const AIModelConfig({
    required this.provider,
    required this.modelName,
    this.apiKey = '',
    required this.baseUrl,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.systemPrompt =
        'You are Antigravity, an expert AI programming assistant. Output clear, well-structured, production-ready code with accurate syntax formatting.',
  });

  AIModelConfig copyWith({
    AIProvider? provider,
    String? modelName,
    String? apiKey,
    String? baseUrl,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) {
    return AIModelConfig(
      provider: provider ?? this.provider,
      modelName: modelName ?? this.modelName,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'modelName': modelName,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'systemPrompt': systemPrompt,
    };
  }

  factory AIModelConfig.fromJson(Map<String, dynamic> json) {
    final providerEnum = AIProvider.values.firstWhere(
      (e) => e.name == json['provider'],
      orElse: () => AIProvider.openai,
    );
    return AIModelConfig(
      provider: providerEnum,
      modelName: json['modelName'] ?? providerEnum.defaultModels.first,
      apiKey: json['apiKey'] ?? '',
      baseUrl: json['baseUrl'] ?? providerEnum.defaultBaseUrl,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] ?? 2048,
      systemPrompt: json['systemPrompt'] ??
          'You are Antigravity, an expert AI programming assistant.',
    );
  }

  factory AIModelConfig.defaultConfig(AIProvider provider) {
    return AIModelConfig(
      provider: provider,
      modelName: provider.defaultModels.first,
      baseUrl: provider.defaultBaseUrl,
    );
  }
}

extension AIProviderCatalogMapping on AIProvider {
  static AIProvider? fromCatalogId(String catalogId) {
    switch (catalogId) {
      case 'openai':
        return AIProvider.openai;
      case 'anthropic':
        return AIProvider.anthropic;
      case 'gemini':
        return AIProvider.gemini;
      case 'ollama':
        return AIProvider.ollama;
      case 'omniroute':
        return AIProvider.omniroute;
      case 'openrouter':
        return AIProvider.openrouter;
      default:
        return null;
    }
  }
}
