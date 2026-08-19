import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_config.dart';

class SettingsService {
  static const String _keyConfigPrefix = 'antigravity_config_';
  static const String _keyActiveProvider = 'antigravity_active_provider';

  Future<void> saveConfig(AIModelConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(config.toJson());
    await prefs.setString('$_keyConfigPrefix${config.provider.name}', jsonStr);
  }

  Future<AIModelConfig> loadConfig(AIProvider provider) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_keyConfigPrefix${provider.name}');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return AIModelConfig.fromJson(map);
      }
    } catch (_) {
      // Fallback to default
    }
    return AIModelConfig.defaultConfig(provider);
  }

  Future<void> saveActiveProvider(AIProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveProvider, provider.name);
  }

  Future<AIProvider> loadActiveProvider() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyActiveProvider);
      if (name != null) {
        return AIProvider.values.firstWhere(
          (e) => e.name == name,
          orElse: () => AIProvider.openai,
        );
      }
    } catch (_) {}
    return AIProvider.openai;
  }
}
