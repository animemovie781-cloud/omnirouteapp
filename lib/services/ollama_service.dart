import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_config.dart';
import '../models/chat_message.dart';
import 'ai_service_interface.dart';

class OllamaService implements AIServiceInterface {
  @override
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    required AIModelConfig config,
  }) async* {
    final client = http.Client();
    final url = Uri.parse('${config.baseUrl}/chat');

    final payloadMessages = <Map<String, String>>[];
    if (config.systemPrompt.isNotEmpty) {
      payloadMessages.add({'role': 'system', 'content': config.systemPrompt});
    }

    for (final m in messages) {
      if (m.sender == MessageSender.user) {
        payloadMessages.add({'role': 'user', 'content': m.content});
      } else if (m.sender == MessageSender.ai) {
        payloadMessages.add({'role': 'assistant', 'content': m.content});
      }
    }

    final request = http.Request('POST', url);
    request.headers.addAll({
      'Content-Type': 'application/json',
    });

    request.body = jsonEncode({
      'model': config.modelName,
      'messages': payloadMessages,
      'stream': true,
      'options': {
        'temperature': config.temperature,
      }
    });

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        yield 'Error ${response.statusCode}: $body';
        return;
      }

      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

      await for (final line in stream) {
        if (line.trim().isEmpty) continue;
        try {
          final jsonMap = jsonDecode(line);
          final message = jsonMap['message'];
          if (message != null && message['content'] != null) {
            yield message['content'] as String;
          }
        } catch (_) {}
      }
    } catch (e) {
      yield '\n[Ollama Connection Error: ${e.toString()}]';
    } finally {
      client.close();
    }
  }
}
