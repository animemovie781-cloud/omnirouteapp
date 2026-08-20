import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_config.dart';
import '../models/provider_catalog.dart';
import '../models/provider_models.dart';
import '../services/provider_auth_helper.dart';

class ConnectionTestResult {
  final bool success;
  final String message;
  final int? latencyMs;

  ConnectionTestResult({
    required this.success,
    required this.message,
    this.latencyMs,
  });
}

class ConnectionTestService {
  static final Set<AIProvider> _openAiCompatible = {
    AIProvider.openai,
    AIProvider.omniroute,
    AIProvider.openrouter,
    AIProvider.ollama,
  };

  static Future<ConnectionTestResult> testConnection(AIModelConfig config) async {
    final baseUrl = config.baseUrl.trim();
    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      return ConnectionTestResult(
        success: false,
        message: 'Invalid Base URL. It must start with http:// or https://',
      );
    }

    final stopwatch = Stopwatch()..start();
    final client = http.Client();

    try {
      late final http.Response response;
      final catalogEntry = ProviderCatalog.byId(config.provider.name);
      final headers = ProviderAuthHelper.buildHeaders(
        catalogEntry ??
            ProviderCatalogEntry(
              id: config.provider.name,
              name: config.provider.displayName,
              defaultBaseUrl: baseUrl,
            ),
        apiKey: config.apiKey.isNotEmpty ? config.apiKey : null,
      );

      if (_openAiCompatible.contains(config.provider)) {
        final url = Uri.parse('$baseUrl/chat/completions');
        response = await client
            .post(
              url,
              headers: headers,
              body: jsonEncode({
                'model': config.modelName.isNotEmpty ? config.modelName : 'gpt-4o-mini',
                'messages': [
                  {'role': 'user', 'content': 'hi'}
                ],
                'max_tokens': 1,
                'stream': false,
              }),
            )
            .timeout(const Duration(seconds: 15));
      } else {
        final url = Uri.parse('$baseUrl/models');
        final request = http.Request('GET', url);
        request.headers.addAll(headers);
        final streamed = await client.send(request).timeout(const Duration(seconds: 15));
        response = await http.Response.fromStream(streamed);
      }

      stopwatch.stop();

      if (response.statusCode == 200) {
        return ConnectionTestResult(
          success: true,
          message: 'Connection successful! Endpoint is reachable.',
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return ConnectionTestResult(
          success: false,
          message: 'Error ${response.statusCode}: Invalid API key / unauthorized.',
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      } else {
        final body = response.body.length > 300
            ? '${response.body.substring(0, 300)}...'
            : response.body;
        return ConnectionTestResult(
          success: false,
          message: 'Error ${response.statusCode}: $body',
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      }
    } catch (e) {
      stopwatch.stop();
      return ConnectionTestResult(
        success: false,
        message: 'Connection failed: ${e.toString()}',
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } finally {
      client.close();
    }
  }

  static Future<ConnectionTestResult> testOmnirouteConnection(AIModelConfig config) =>
      testConnection(config);
}
