import '../models/ai_config.dart';
import '../models/chat_message.dart';

abstract class AIServiceInterface {
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    required AIModelConfig config,
  });
}
