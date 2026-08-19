import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_config.dart';
import '../models/chat_message.dart';
import 'ai_service_interface.dart';

class AnthropicService implements AIServiceInterface {
  @override
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    required AIModelConfig config,
  }) async* {
    final client = http.Client();
    final url = Uri.parse('${config.baseUrl}/messages');

    final payloadMessages = <Map<String, String>>[];
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
      'x-api-key': config.apiKey,
      'anthropic-version': '2023-06-01',
    });

    final bodyMap = <String, dynamic>{
      'model': config.modelName,
      'messages': payloadMessages,
      'max_tokens': config.maxTokens,
      'temperature': config.temperature,
      'stream': true,
    };

    if (config.systemPrompt.isNotEmpty) {
      bodyMap['system'] = config.systemPrompt;
    }

    request.body = jsonEncode(bodyMap);

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        yield 'Error ${response.statusCode}: $body';
        return;
      }

      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          try {
            final jsonMap = jsonDecode(data);
            final type = jsonMap['type'];
            if (type == 'content_block_delta') {
              final delta = jsonMap['delta'];
              if (delta != null && delta['text'] != null) {
                yield delta['text'] as String;
              }
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      yield '\n[Connection Error: ${e.toString()}]';
    } finally {
      client.close();
    }
  }
}
