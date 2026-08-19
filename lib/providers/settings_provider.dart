import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_config.dart';
import '../services/settings_service.dart';

class SettingsState {
  final AIProvider activeProvider;
  final Map<AIProvider, AIModelConfig> configs;
  final bool isLoading;

  SettingsState({
    required this.activeProvider,
    required this.configs,
    this.isLoading = false,
  });

  AIModelConfig get activeConfig => configs[activeProvider] ?? AIModelConfig.defaultConfig(activeProvider);

  SettingsState copyWith({
    AIProvider? activeProvider,
    Map<AIProvider, AIModelConfig>? configs,
    bool? isLoading,
  }) {
    return SettingsState(
      activeProvider: activeProvider ?? this.activeProvider,
      configs: configs ?? this.configs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsService _service;

  SettingsNotifier(this._service)
      : super(SettingsState(
          activeProvider: AIProvider.openai,
          configs: {
            for (var p in AIProvider.values) p: AIModelConfig.defaultConfig(p),
          },
          isLoading: true,
        )) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    final activeProvider = await _service.loadActiveProvider();
    final Map<AIProvider, AIModelConfig> loadedConfigs = {};

    for (final p in AIProvider.values) {
      loadedConfigs[p] = await _service.loadConfig(p);
    }

    state = SettingsState(
      activeProvider: activeProvider,
      configs: loadedConfigs,
      isLoading: false,
    );
  }

  Future<void> setActiveProvider(AIProvider provider) async {
    state = state.copyWith(activeProvider: provider);
    await _service.saveActiveProvider(provider);
  }

  Future<void> updateConfig(AIModelConfig newConfig) async {
    final updatedMap = Map<AIProvider, AIModelConfig>.from(state.configs);
    updatedMap[newConfig.provider] = newConfig;
    state = state.copyWith(configs: updatedMap);
    await _service.saveConfig(newConfig);
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service);
});
