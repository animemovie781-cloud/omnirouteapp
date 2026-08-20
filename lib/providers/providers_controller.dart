import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/provider_models.dart';
import '../services/provider_key_store.dart';
import '../services/provider_repository.dart';

class ProvidersUiState {
  final List<ProviderConfig> configuredProviders;
  final bool isLoading;
  final bool isAdding;
  final bool isEditing;
  final String? editingId;

  const ProvidersUiState({
    this.configuredProviders = const [],
    this.isLoading = false,
    this.isAdding = false,
    this.isEditing = false,
    this.editingId,
  });

  ProvidersUiState copyWith({
    List<ProviderConfig>? configuredProviders,
    bool? isLoading,
    bool? isAdding,
    bool? isEditing,
    String? editingId,
    bool clearEditing = false,
    bool clearAdding = false,
  }) {
    return ProvidersUiState(
      configuredProviders: configuredProviders ?? this.configuredProviders,
      isLoading: isLoading ?? this.isLoading,
      isAdding: clearAdding ? false : (isAdding ?? this.isAdding),
      isEditing: clearEditing ? false : (isEditing ?? this.isEditing),
      editingId: clearEditing ? null : (editingId ?? this.editingId),
    );
  }
}

class ProvidersController extends StateNotifier<ProvidersUiState> {
  final ProviderRepository _repository;
  final ProviderKeyStore _keyStore;

  ProvidersController(this._repository, this._keyStore)
      : super(const ProvidersUiState());

  Future<void> loadProviders() async {
    state = state.copyWith(isLoading: true);
    final providers = _repository.getAll();
    state = state.copyWith(
      configuredProviders: providers,
      isLoading: false,
    );
  }

  void openAddSheet() {
    state = state.copyWith(isAdding: true, clearEditing: true);
  }

  void openEdit(ProviderConfig config) {
    state = state.copyWith(isEditing: true, editingId: config.id, clearAdding: true);
  }

  void close() {
    state = state.copyWith(clearAdding: true, clearEditing: true);
  }

  Future<void> saveProvider({
    required ProviderCatalogEntry catalogEntry,
    required String name,
    required String baseUrl,
    required String apiKey,
    bool isCustom = false,
  }) async {
    final now = DateTime.now();
    final id = isCustom
        ? 'custom_${catalogEntry.id}_${Uuid().v4()}'
        : catalogEntry.id;

    final config = ProviderConfig(
      id: id,
      name: name,
      baseUrl: baseUrl,
      isCustom: isCustom,
      createdAt: now,
    );

    await _repository.upsert(config);
    if (apiKey.isNotEmpty) {
      await _keyStore.saveKey(id, apiKey);
    }

    final providers = _repository.getAll();
    state = state.copyWith(
      configuredProviders: providers,
      clearAdding: true,
      clearEditing: true,
    );
  }

  Future<void> deleteProvider(String id) async {
    await _repository.delete(id);
    await _keyStore.deleteKey(id);
    final providers = _repository.getAll();
    state = state.copyWith(configuredProviders: providers);
  }
}

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return ProviderRepository(Hive.box('provider_configs'));
});

final providerKeyStoreProvider = Provider<ProviderKeyStore>((ref) {
  return ProviderKeyStore(const FlutterSecureStorage());
});

final configuredProvidersProvider = FutureProvider<List<ProviderConfig>>((ref) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getAll();
});

final providersControllerProvider =
    StateNotifierProvider<ProvidersController, ProvidersUiState>((ref) {
  final repo = ref.watch(providerRepositoryProvider);
  final keyStore = ref.watch(providerKeyStoreProvider);
  return ProvidersController(repo, keyStore);
});
