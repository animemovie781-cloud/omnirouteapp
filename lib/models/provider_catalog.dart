import '../models/provider_models.dart';
import '../models/ai_config.dart';

class ProviderCatalog {
  static const List<ProviderCatalogEntry> builtIn = [
    ProviderCatalogEntry(
      id: 'openai',
      name: 'OpenAI',
      defaultBaseUrl: 'https://api.openai.com/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'OPENAI_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'anthropic',
      name: 'Anthropic (Claude)',
      defaultBaseUrl: 'https://api.anthropic.com/v1',
      authType: ProviderAuthType.apiKeyHeader,
      authHeaderName: 'x-api-key',
      envVarHint: 'ANTHROPIC_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'gemini',
      name: 'Google Gemini',
      defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'GOOGLE_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'ollama',
      name: 'Ollama (Local)',
      defaultBaseUrl: 'http://localhost:11434/api',
      authType: ProviderAuthType.none,
    ),
    ProviderCatalogEntry(
      id: 'openrouter',
      name: 'OpenRouter',
      defaultBaseUrl: 'https://openrouter.ai/api/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'OPENROUTER_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'omniroute',
      name: 'Omniroute Gateway',
      defaultBaseUrl: 'http://localhost:8000/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'OMNIROUTE_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'xai',
      name: 'xAI (Grok)',
      defaultBaseUrl: 'https://api.x.ai/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'XAI_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'groq',
      name: 'Groq',
      defaultBaseUrl: 'https://api.groq.com/openai/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'GROQ_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'deepseek',
      name: 'DeepSeek',
      defaultBaseUrl: 'https://api.deepseek.com/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'DEEPSEEK_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'fireworks',
      name: 'Fireworks AI',
      defaultBaseUrl: 'https://api.fireworks.ai/inference/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'FIREWORKS_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'togetherai',
      name: 'Together AI',
      defaultBaseUrl: 'https://api.together.xyz/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'TOGETHER_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'cerebras',
      name: 'Cerebras',
      defaultBaseUrl: 'https://api.cerebras.ai/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'CEREBRAS_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'deepinfra',
      name: 'DeepInfra',
      defaultBaseUrl: 'https://api.deepinfra.com/v1/openai',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'DEEPINFRA_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'azure',
      name: 'Azure OpenAI',
      defaultBaseUrl: 'https://{resource}.openai.azure.com/openai/deployments',
      authType: ProviderAuthType.apiKeyHeader,
      authHeaderName: 'api-key',
      envVarHint: 'AZURE_OPENAI_API_KEY',
    ),
    ProviderCatalogEntry(
      id: 'amazon-bedrock',
      name: 'Amazon Bedrock',
      defaultBaseUrl: 'https://bedrock-runtime.us-east-1.amazonaws.com',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'AWS_ACCESS_KEY_ID',
    ),
    ProviderCatalogEntry(
      id: 'openai-compatible',
      name: 'OpenAI Compatible',
      defaultBaseUrl: 'https://api.example.com/v1',
      authType: ProviderAuthType.apiKey,
      envVarHint: 'OPENAI_API_KEY',
    ),
  ];

  static List<ProviderCatalogEntry> get sorted {
    final list = List<ProviderCatalogEntry>.from(builtIn);
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  static ProviderCatalogEntry? byId(String id) {
    try {
      return builtIn.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static AIProvider? toAIProvider(String catalogId) {
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
