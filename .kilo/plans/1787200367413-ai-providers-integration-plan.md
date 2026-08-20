# AI Providers System — Integration Plan

## Goal
Add Kilocode-style "Providers" management to the existing Flutter app as a **higher-level management layer** that coexists with the current `AIProvider` enum, `AIServiceFactory`, `SettingsService` (SharedPreferences), and per-provider `http`-based SSE services.

## Design Decisions (resolved)
- **Coexist**: Keep `AIProvider` enum, per-provider services, `SettingsService`, and `http` SSE streaming intact.
- **New layer**: Add a catalog-driven `ProviderConfig` system, secure key storage, Hive persistence, and a dedicated Providers management screen.
- **Bridge**: Map catalog IDs → `AIProvider` enum. Update `ConnectionTestService` to use catalog auth headers. `settings_screen.dart` dropdown eventually filters to configured providers.
- **No Dio**: Keep existing `http` for SSE streaming (already working). Add Dio only for connection-test convenience, OR keep `http` everywhere and compute headers via a helper. **Decision: keep `http` entirely; add a header-builder helper extracted from the Dio-interceptor logic.**

## Files to Create

### 1. `lib/models/provider_models.dart`
- `ProviderAuthType` enum (`apiKey`, `apiKeyHeader`, `none`)
- `ProviderCatalogEntry` class (id, name, defaultBaseUrl, authType, authHeaderName, envVarHint)
- `ProviderConfig` class (id, name, baseUrl, enabled, isCustom, extraHeaders, modelWhitelist, modelBlacklist, createdAt) with `copyWith`, `toJson`, `fromJson`

### 2. `lib/models/provider_catalog.dart`
- `ProviderCatalog` with `builtIn` list matching existing `AIProvider` enum values (openai, anthropic, gemini, openrouter, xai, groq, deepseek, fireworks, togetherai, cerebras, deepinfra, azure, amazon-bedrock, openai-compatible, ollama).
- `sorted()` method with priority ordering.
- **Add mapping**: `AIProvider? toAIProvider(String catalogId)` extension/helper that maps catalog IDs to enum values.

### 3. `lib/services/provider_key_store.dart`
- `ProviderKeyStore` using `flutter_secure_storage`.
- `saveKey(id, key)`, `getKey(id)`, `deleteKey(id)`.

### 4. `lib/services/provider_repository.dart`
- `ProviderRepository` using Hive.
- `getAll()`, `upsert(config)`, `delete(id)`.
- Box name: `provider_configs`.

### 5. `lib/services/provider_auth_helper.dart`
- `ProviderAuthHelper.buildHeaders(catalogEntry, apiKey, extraHeaders)` → `Map<String, String>`.
- Handles `apiKey` (Bearer), `apiKeyHeader` (custom), `none`.
- Adds `anthropic-version` for Anthropic.
- **Used by `ConnectionTestService` and eventually by service classes.**

### 6. `lib/providers/providers_controller.dart`
- `ProvidersController` (StateNotifier) with `ProvidersUiState`:
  - `closed()`, `selecting()` (catalog picker), `form(entry, editing)` (credentials form).
- Actions: `openAddSheet()`, `chooseCatalogEntry(entry)`, `openEdit(config)`, `close()`, `saveProvider(...)`, `deleteProvider(id)`.
- Riverpod providers:
  - `providerRepoProvider` (Provider)
  - `providerKeyStoreProvider` (Provider)
  - `configuredProvidersProvider` (FutureProvider<List<ProviderConfig>>)
  - `providersControllerProvider` (StateNotifierProvider)

### 7. `lib/ui/screens/providers_screen.dart`
- `ProvidersScreen` (ConsumerWidget):
  - AppBar with title showing count + Add button.
  - ListView of configured providers with Edit/Delete trailing actions.
- `AddProviderSheet` (ConsumerWidget):
  - Step 1: catalog picker (`ListView` of `ProviderCatalog.sorted()`).
  - Step 2: `_ProviderCredentialsForm` (ConsumerStatefulWidget) with fields for ID, Name, Base URL, API Key, error display, Save/Cancel.
- Navigation to `providers_screen.dart` from `settings_screen.dart` via a new row/button.

## Files to Modify

### 8. `pubspec.yaml`
Add dependencies:
```yaml
dependencies:
  flutter_secure_storage: ^9.2.2
  hive_flutter: ^1.1.0
```

### 9. `lib/main.dart`
- Initialize Hive: `await Hive.initFlutter();` before `runApp`.
- Ensure `ProviderScope` wraps `MaterialApp`.

### 10. `lib/models/ai_config.dart`
- Add a helper method or extension:
  ```dart
  AIProvider? fromCatalogId(String catalogId) {
    // maps 'openai'→AIProvider.openai, 'anthropic'→AIProvider.anthropic, etc.
  }
  ```
- Keep all existing code unchanged otherwise.

### 11. `lib/services/connection_test_service.dart`
- Replace hardcoded `'Authorization': 'Bearer ${config.apiKey}'` header construction with `ProviderAuthHelper.buildHeaders(...)`.
- Pass `ProviderCatalogEntry` (looked up via `AIProvider.fromCatalogId`) so Anthropic gets `x-api-key` header.

### 12. `lib/ui/screens/settings_screen.dart`
- Add a new row/card at the top: "Manage Providers" button that navigates to `ProvidersScreen`.
- Optionally: when a provider is selected from the dropdown, pre-fill from `ProviderRepository` if a matching `ProviderConfig` exists (future enhancement, not required for MVP).

## Migration / Rollout Path
1. Add new model/service/provider/UI files (no breaking changes).
2. Update `pubspec.yaml` and `main.dart` for Hive + secure storage init.
3. Update `ConnectionTestService` to use `ProviderAuthHelper`.
4. Add navigation bridge from `settings_screen.dart` → `ProvidersScreen`.
5. Test: add provider, edit, delete, verify key in secure storage, verify config in Hive, verify connection test uses correct header.

## Out of Scope (explicitly skipped per user prompt)
- OAuth device-code flow.
- Per-model pricing/cost/context-limit catalog.
- Multi-scope config (project vs global).
- Dio interceptor + Dio networking (kept `http` for SSE).
- Replacing existing `AIProvider` enum or `SettingsService`.
