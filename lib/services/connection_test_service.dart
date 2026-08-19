import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/ai_config.dart';

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
  static Future<ConnectionTestResult> testConnection(AIModelConfig config) async {
    final stopwatch = Stopwatch()..start();
    final client = http.Client();

    try {
      final url = Uri.parse('${config.baseUrl}/models');
      final request = http.Request('GET', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        if (config.apiKey.isNotEmpty) 'Authorization': 'Bearer ${config.apiKey}',
      });

      final response = await client.send(request).timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode == 200) {
        return ConnectionTestResult(
          success: true,
          message: 'Connection successful! Gateway is reachable.',
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      } else {
        final body = await response.stream.bytesToString();
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

  static Future<ConnectionTestResult> testOmnirouteConnection(AIModelConfig config) async {
    return testConnection(config);
  }
}