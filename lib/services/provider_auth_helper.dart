import '../models/provider_models.dart';

class ProviderAuthHelper {
  static Map<String, String> buildHeaders(
    ProviderCatalogEntry catalogEntry, {
    String? apiKey,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    if (catalogEntry.authType == ProviderAuthType.apiKey &&
        apiKey != null &&
        apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    } else if (catalogEntry.authType == ProviderAuthType.apiKeyHeader &&
        apiKey != null &&
        apiKey.isNotEmpty) {
      final headerName = catalogEntry.authHeaderName ?? 'Authorization';
      headers[headerName] = apiKey;
    }

    if (catalogEntry.id == 'anthropic') {
      headers['anthropic-version'] = '2023-06-01';
    }

    return headers;
  }
}
