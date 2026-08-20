# Antigravity: OpenRouter + Folder/Tree Fix + Connection Test (Plan)

## Context
User reported the following on the just-built Android APK (and wants the same behavior on Desktop + Web):
1. **Folder create not working** — `project_screen.dart:179` uses a hardcoded `/home/user/projects` path, which is not writable on Android → create fails. Also the base `file_system_service.dart` has an unconditional top-level `import 'dart:io'`, which **breaks the Flutter Web build** (the `io`/`stub` files exist but are not wired via conditional import).
2. **Omniroute Test Connection errors** — `connection_test_service.dart` only does `GET {baseUrl}/models`; the gateway may not expose that endpoint, and the failure message is cryptic.
3. **Only localhost accepted** — there is no real localhost lock, but the default Omniroute URL is `http://localhost:8000/v1` and the test is fragile; user wants **any URL** to work and a clear result.
4. **No file explorer** — editor has no file/folder tree like Antigravity/Cursor.

## User Decisions (confirmed)
- Platform scope: **Android + Desktop + Web** (Web = metadata-only, no real disk).
- "Open Folder": keep **manual path text entry**.
- "Test Connection": verify via **POST a tiny chat completion** (stricter, real check).

## Changes

### 1. Add OpenRouter provider — `lib/models/ai_config.dart`
- Add `openrouter` to `AIProvider` enum.
- `displayName` → `'OpenRouter'`.
- `defaultBaseUrl` → `'https://openrouter.ai/api/v1'`.
- `defaultModels` → `['openai/gpt-4o','anthropic/claude-3.5-sonnet','google/gemini-pro-1.5','meta-llama/llama-3.1-70b-instruct']`.
- OpenRouter is OpenAI-compatible, so no new service class needed (reuse `OpenAIService`).

### 2. Wire OpenRouter in factory — `lib/services/ai_service_factory.dart`
- `case AIProvider.openrouter: return OpenAIService();`

### 3. Fix FileSystemService for Web — `lib/services/file_system_service.dart`
- Replace the body (which has `import 'dart:io'` at top) with a conditional export so Web compiles:
  ```dart
  export 'file_system_service_stub.dart' if (dart.library.io) 'file_system_service_io.dart';
  ```
- Keep `file_system_service_io.dart` (real FS) and `file_system_service_stub.dart` (metadata-only) unchanged. Verify both expose identical `FileSystemService` API (`createFolder`, `openFolder`, `listFiles`, `readFile`, `writeFile`) — they do.

### 4. Add path_provider — `pubspec.yaml`
- Add `path_provider: ^2.1.0`. Run `/opt/flutter/bin/flutter pub get`.

### 5. Fix folder create — `lib/ui/screens/project_screen.dart`
- Import `package:path_provider/path_provider.dart`.
- In `_showCreateFolderDialog`, replace `'/home/user/projects'` with `await getApplicationDocumentsDirectory().path` so created folders live in the app's writable documents dir (works on Android/Desktop; on Web `path_provider` returns a path and the stub ignores real creation).
- Keep manual path entry for "Open Folder" (per user). Improve its catch message to be actionable.

### 6. Test Connection gated on API key — `lib/ui/screens/settings_screen.dart`
- Render `ConnectionStatusWidget(...)` only when `_apiKeyController.text.trim().isNotEmpty` (and baseUrl non-empty); otherwise show hint text: `"Enter an API key above to enable Test Connection."`

### 7. Test Connection = POST tiny completion — `lib/services/connection_test_service.dart`
- Rewrite `testConnection(AIModelConfig config)`:
  - Light validation: if `baseUrl` does not start with `http://`/`https://`, return clear failure.
  - For OpenAI-compatible providers (openai, omniroute, openrouter, ollama): `POST {baseUrl}/chat/completions` with `model: config.modelName`, `messages: [{role:'user',content:'hi'}]`, `max_tokens: 1`, `stream: false`.
  - For others (anthropic, gemini): fallback to `GET {baseUrl}/models`.
  - Map results clearly: `200` → success + latency; `401/403` → "Invalid API key"; other status → `Error <code>: <body snippet>`; exceptions (e.g. gateway down) → `"Connection failed: <e>"`.
  - Keep `testOmnirouteConnection` as an alias to `testConnection` (or remove if unused).

### 8. Editor 3-dot file tree — `lib/ui/widgets/code_viewer_panel.dart` + new `lib/ui/widgets/file_explorer_panel.dart`
- `CodeViewerPanel` becomes stateful with `bool _showExplorer`. Remove `const` at its instantiation in `main_screen.dart` (`const CodeViewerPanel()` → `const CodeViewerPanel()` is fine if no args; just ensure no `const` where state added — it's already a widget with no const constructor issue; verify).
- Add a **leftmost** `IconButton(icon: Icons.more_vert_rounded, tooltip:'Files')` in the editor header `Row` (top-left corner, per request). Tap toggles `_showExplorer`.
- When shown, render `FileExplorerPanel` as a left column inside the editor body.
- New `FileExplorerPanel`:
  - Reads `projectProvider` `currentProject`. If null → "No project open".
  - Loads files via `FileSystemService().listFiles(project.path, recursive: true)` (async, `setState`/`FutureBuilder`). On Web this returns `[]` → show "No files (web is metadata-only)".
  - Builds a simple tree from relative paths (split by `/`); folders vs files by trailing/extension; icons `Icons.folder`/`Icons.insert_drive_file`.
  - `onFileTap(path)`: `readFile` → `editorProvider.updateCode(content)` + `updateLanguage(extToLang(path))`.
- Add `file_system_service` + `project_provider` + `editor_provider` imports where needed.

### 9. Validation
- `/opt/flutter/bin/flutter analyze` → no errors.
- `/opt/flutter/bin/flutter build apk --release` → succeeds; on device: create folder → appears in Recents → editor → 3-dot → tree shows → tap file loads it.
- `/opt/flutter/bin/flutter build web` → **must succeed** (this is the key regression the `dart:io` fix addresses).
- Settings: select OpenRouter → enter key → Test Connection appears → POST test returns clear success/error. Omniroute: enter any (remote) base URL → Test Connection → clear message, no localhost-only behavior.

## Risks / Notes
- Manual "Open Folder" on Android scoped storage will likely fail for arbitrary paths (user accepted this; text entry kept).
- `path_provider` on Web returns a path but real disk writes are impossible — handled by the stub (metadata-only), matching the agreed Web behavior.
- Anthropic/Gemini Test Connection uses the `/models` fallback (their API shape differs); only OpenAI-compatible providers get the POST completion test.
- If CI workflow runs `flutter build apk`, the newly committed `android/` folder (from prior session) is already present, so it will build.
