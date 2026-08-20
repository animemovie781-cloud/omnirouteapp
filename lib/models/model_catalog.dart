import '../model_models.dart';

class ModelCatalog {
  static const Map<String, List<ModelInfo>> byProvider = {
    'anthropic': [
      ModelInfo(id: 'claude-opus-4-8', providerId: 'anthropic', name: 'Claude Opus 4.8', family: 'claude', contextLimit: 200000, inputCostPer1M: 15, outputCostPer1M: 75, supportsVision: true),
      ModelInfo(id: 'claude-sonnet-5', providerId: 'anthropic', name: 'Claude Sonnet 5', family: 'claude', contextLimit: 200000, inputCostPer1M: 3, outputCostPer1M: 15, supportsVision: true),
      ModelInfo(id: 'claude-haiku-4-5-20251001', providerId: 'anthropic', name: 'Claude Haiku 4.5', family: 'claude', contextLimit: 200000, inputCostPer1M: 0.8, outputCostPer1M: 4, supportsVision: true),
    ],
    'openai': [
      ModelInfo(id: 'gpt-5', providerId: 'openai', name: 'GPT-5', family: 'gpt', contextLimit: 400000, supportsVision: true),
      ModelInfo(id: 'gpt-5-mini', providerId: 'openai', name: 'GPT-5 mini', family: 'gpt', contextLimit: 400000),
    ],
    'google': [
      ModelInfo(id: 'gemini-2.5-pro', providerId: 'google', name: 'Gemini 2.5 Pro', family: 'gemini', contextLimit: 1000000, supportsVision: true),
    ],
    'openrouter': [
      ModelInfo(id: 'openai/gpt-4o', providerId: 'openrouter', name: 'OpenAI GPT-4o', family: 'gpt', contextLimit: 128000, supportsVision: true),
      ModelInfo(id: 'anthropic/claude-3.5-sonnet', providerId: 'openrouter', name: 'Claude 3.5 Sonnet', family: 'claude', contextLimit: 200000, supportsVision: true),
      ModelInfo(id: 'meta-llama/llama-3.1-70b-instruct', providerId: 'openrouter', name: 'Llama 3.1 70B', family: 'llama', contextLimit: 128000),
    ],
    'ollama': [
      ModelInfo(id: 'llama3', providerId: 'ollama', name: 'Llama 3', family: 'llama', contextLimit: 8192),
      ModelInfo(id: 'codellama', providerId: 'ollama', name: 'Code Llama', family: 'llama', contextLimit: 16384),
      ModelInfo(id: 'mistral', providerId: 'ollama', name: 'Mistral', family: 'mistral', contextLimit: 32768),
    ],
    'xai': [
      ModelInfo(id: 'grok-3', providerId: 'xai', name: 'Grok 3', family: 'grok', contextLimit: 128000),
    ],
    'groq': [
      ModelInfo(id: 'llama-3.3-70b-versatile', providerId: 'groq', name: 'Llama 3.3 70B Versatile', family: 'llama', contextLimit: 128000),
    ],
    'deepseek': [
      ModelInfo(id: 'deepseek-chat', providerId: 'deepseek', name: 'DeepSeek Chat', family: 'deepseek', contextLimit: 64000),
      ModelInfo(id: 'deepseek-reasoner', providerId: 'deepseek', name: 'DeepSeek Reasoner', family: 'deepseek', contextLimit: 64000),
    ],
    'fireworks': [
      ModelInfo(id: 'accounts/fireworks/models/llama-v3p1-405b-instruct', providerId: 'fireworks', name: 'Llama 3.1 405B Instruct', family: 'llama', contextLimit: 128000),
    ],
    'togetherai': [
      ModelInfo(id: 'meta-llama/Llama-3.1-70B-Instruct-Turbo', providerId: 'togetherai', name: 'Llama 3.1 70B Turbo', family: 'llama', contextLimit: 128000),
    ],
    'cerebras': [
      ModelInfo(id: 'llama-3.1-70b', providerId: 'cerebras', name: 'Llama 3.1 70B', family: 'llama', contextLimit: 128000),
    ],
    'deepinfra': [
      ModelInfo(id: 'meta-llama/Meta-Llama-3.1-70B-Instruct', providerId: 'deepinfra', name: 'Llama 3.1 70B', family: 'llama', contextLimit: 128000),
    ],
    'azure': [
      ModelInfo(id: 'gpt-4o', providerId: 'azure', name: 'GPT-4o', family: 'gpt', contextLimit: 128000, supportsVision: true),
    ],
    'amazon-bedrock': [
      ModelInfo(id: 'anthropic.claude-3-5-sonnet', providerId: 'amazon-bedrock', name: 'Claude 3.5 Sonnet', family: 'claude', contextLimit: 200000, supportsVision: true),
    ],
    'openai-compatible': [
      ModelInfo(id: 'default', providerId: 'openai-compatible', name: 'Default', family: 'openai', contextLimit: 8192),
    ],
  };

  static List<ModelInfo> forProvider(String providerId) => byProvider[providerId] ?? [];

  static List<ModelInfo> all() => byProvider.values.expand((e) => e).toList();
}
