import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_config.dart';
import '../models/project_folder.dart';

class SettingsService {
  static const String _keyConfigPrefix = 'antigravity_config_';
  static const String _keyActiveProvider = 'antigravity_active_provider';
  static const String _keyRecentProjects = 'antigravity_recent_projects';

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

  Future<void> saveRecentProjects(List<ProjectFolder> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = projects.map((p) => p.toJson()).toList();
    await prefs.setString(_keyRecentProjects, jsonEncode(jsonList));
  }

  Future<List<ProjectFolder>> loadRecentProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyRecentProjects);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => ProjectFolder.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> addRecentProject(ProjectFolder project) async {
    final recent = await loadRecentProjects();
    // Remove if already exists
    recent.removeWhere((p) => p.path == project.path);
    // Add to front
    recent.insert(0, project);
    // Keep only last 10
    if (recent.length > 10) recent.removeRange(10, recent.length);
    await saveRecentProjects(recent);
  }
}
