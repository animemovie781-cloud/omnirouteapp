import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> streamChatResponse({
  required http.Client client,
  required String baseUrl,
  required String apiKey,
  required Map<String, String> headers,
  required String model,
  required List<Map<String, String>> history,
  required void Function(String chunk) onChunk,
  required void Function() onDone,
  required void Function(String error) onError,
}) async {
  try {
    final url = Uri.parse('$baseUrl/chat/completions');
    final request = http.Request('POST', url);
    request.headers.addAll(headers);

    request.body = jsonEncode({
      'model': model,
      'messages': history,
      'stream': true,
    });

    final response = await client.send(request);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      onError('Error ${response.statusCode}: $body');
      return;
    }

    final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

    await for (final line in stream) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();
        if (data == '[DONE]') break;
        try {
          final jsonMap = jsonDecode(data);
          final choices = jsonMap['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final delta = choices[0]['delta'];
            if (delta != null && delta['content'] != null) {
              onChunk(delta['content'] as String);
            }
          }
        } catch (_) {}
      }
    }

    onDone();
  } catch (e) {
    onError(e.toString());
  }
}
