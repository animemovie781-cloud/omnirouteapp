import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_config.dart';
import '../models/chat_message.dart';
import 'ai_service_interface.dart';

class GeminiService implements AIServiceInterface {
  @override
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    required AIModelConfig config,
  }) async* {
    final client = http.Client();
    final url = Uri.parse(
        '${config.baseUrl}/models/${config.modelName}:streamGenerateContent?alt=sse&key=${config.apiKey}');

    final contents = <Map<String, dynamic>>[];
    for (final m in messages) {
      final role = m.sender == MessageSender.user ? 'user' : 'model';
      contents.add({
        'role': role,
        'parts': [
          {'text': m.content}
        ]
      });
    }

    final request = http.Request('POST', url);
    request.headers.addAll({
      'Content-Type': 'application/json',
    });

    final bodyMap = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'temperature': config.temperature,
        'maxOutputTokens': config.maxTokens,
      }
    };

    if (config.systemPrompt.isNotEmpty) {
      bodyMap['systemInstruction'] = {
        'parts': [
          {'text': config.systemPrompt}
        ]
      };
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
            final candidates = jsonMap['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final parts = candidates[0]['content']?['parts'] as List?;
              if (parts != null && parts.isNotEmpty) {
                final text = parts[0]['text'] as String?;
                if (text != null) {
                  yield text;
                }
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
