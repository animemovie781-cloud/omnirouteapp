import '../models/ai_config.dart';
import 'ai_service_interface.dart';
import 'openai_service.dart';
import 'anthropic_service.dart';
import 'gemini_service.dart';
import 'ollama_service.dart';
import 'omniroute_service.dart';

class AIServiceFactory {
  static AIServiceInterface getService(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return OpenAIService();
      case AIProvider.anthropic:
        return AnthropicService();
      case AIProvider.gemini:
        return GeminiService();
      case AIProvider.ollama:
        return OllamaService();
      case AIProvider.omniroute:
        return OmnirouteService();
    }
  }
}
