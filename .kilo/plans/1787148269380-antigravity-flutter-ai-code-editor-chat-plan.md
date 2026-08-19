# Antigravity: Flutter/Dart AI Code Editor Chat App Plan

## 1. Overview
The goal is to design and build **Antigravity**, a Flutter/Dart cross-platform AI Code Editor Chat application. The app features an adaptive, responsive UI for Desktop (Linux, macOS, Windows), Web, and Mobile (iOS, Android). It provides a chat-centric interface with rich markdown and syntax-highlighted code block rendering, snippet copy/apply features, quick code editing, and multi-provider AI integration (OpenAI, Anthropic, Gemini, Ollama).

---

## 2. Key Requirements & Scope
- **Target Platform**: All Platforms (Adaptive UI - Desktop split panel, Mobile drawer/tab view, Web responsive layout).
- **AI Backend Strategy**: Multi-provider support directly via user-configured API keys and custom API endpoints (OpenAI, Anthropic, Gemini, Ollama, Omniroute).
- **Core Interface**: 
  - **First Screen (Project Screen)**: Create Folder, Open Folder, Clone GitHub Repo actions.
  - **After folder create/open**: Navigate to Editor Screen with file tree and code editor.
  - **Chat-centric code viewer** with syntax highlighting, inline snippet actions.
- **Omniroute Features**: 
  - Check Connection button in Settings to verify gateway connectivity.
  - Model Selector dropdown for switching between `omni/auto`, `omni/best-coding`, `omni/fast`.
- **State & Storage**: Persistence of API keys, model parameters, system prompts, recent folders, and session chat history using local storage.

---

## 3. Technology Stack & Dependencies
- **Language & Framework**: Dart 3.x, Flutter 3.x SDK
- **State Management**: `flutter_riverpod` or `provider`
- **Networking**: `http` / `dio` (supporting Server-Sent Events / SSE streaming)
- **UI & Code Rendering**:
  - `flutter_markdown` or `markdown_widget` for rendering AI responses
  - `flutter_highlight` or `code_text_field` for code block syntax highlighting
  - `flutter_spinkit` / progress indicators for streaming state
- **Storage**: `shared_preferences` / `flutter_secure_storage` for local settings and credentials

---

## 4. Architecture & File Structure

```
lib/
├── main.dart                       # App entrypoint & theme initialization
├── models/
│   ├── chat_message.dart           # Message model (role, content, timestamp, code snippets)
│   ├── ai_config.dart              # Model settings, API keys, provider configs
│   ├── code_snippet.dart           # Extracted code snippet model
│   └── project_folder.dart         # Project folder model (path, name, last opened)
├── services/
│   ├── ai_service_interface.dart   # Abstract AI service interface
│   ├── openai_service.dart         # OpenAI API & streaming implementation
│   ├── anthropic_service.dart      # Anthropic Claude API implementation
│   ├── gemini_service.dart         # Google Gemini API implementation
│   ├── ollama_service.dart         # Local Ollama endpoint implementation
│   ├── omniroute_service.dart      # Omniroute proxy API implementation
│   ├── connection_test_service.dart # API connection test utility
│   ├── file_system_service.dart    # Folder create/open operations
│   └── settings_service.dart       # API key & preference storage
├── providers/
│   ├── chat_provider.dart          # Chat state & message stream handler
│   ├── settings_provider.dart      # Selected AI model & API credentials state
│   ├── editor_provider.dart        # Quick editor & current code context state
│   └── project_provider.dart       # Current project folder & recent projects state
└── ui/
    ├── screens/
    │   ├── project_screen.dart     # First screen: Create/Open/Clone folder actions
    │   ├── main_screen.dart        # Adaptive layout wrapper (Desktop vs Mobile layout)
    │   └── settings_screen.dart    # AI provider configuration & API key management
    ├── widgets/
    │   ├── chat_panel.dart         # Message feed, streaming bubble, input field
    │   ├── code_viewer_panel.dart  # Syntax highlighted code viewer & snippet inspector
    │   ├── code_block_view.dart    # Highlighting widget with Copy/Apply actions
    │   ├── provider_selector.dart  # Dropdown for switching models/providers
    │   ├── connection_status.dart  # Connection test button & status indicator
    │   └── project_actions.dart    # Create Folder, Open Folder, Clone Repo buttons
    └── theme/
        └── app_theme.dart          # Dark/Light IDE color schemes (Antigravity theme)
```

---

## 5. Detailed Execution Steps

### Step 1: Project Setup & Configuration
1. Initialize Flutter project files and `pubspec.yaml` with required dependencies.
2. Define `AppTheme` with custom dark syntax theme (Antigravity futuristic IDE theme).

### Step 2: Data Models & Storage Service
1. Create `ChatMessage`, `AICodeSnippet`, and `AIConfig` data models with JSON serialization.
2. Build `SettingsService` for persisting user API keys, selected default model, system prompts, and custom endpoints securely.

### Step 3: Multi-Provider AI Service Layer
1. Implement `AIServiceInterface` for unified streaming completion contract.
2. Develop stream parsers for:
   - OpenAI (v1/chat/completions SSE parser)
   - Anthropic (/v1/messages streaming parser)
   - Gemini (generateContent stream parser)
   - Ollama (/api/chat local JSON stream parser)
   - Omniroute (OpenAI-compatible gateway SSE parser with default models: `omni/auto`, `omni/best-coding`, `omni/fast`)

### Step 8: Omniroute Provider Integration
1. Add `omniroute` enum entry to `AIProvider` in `lib/models/ai_config.dart`.
2. Configure default base URL `http://localhost:8000/v1` and models (`omni/auto`, `omni/best-coding`, `omni/fast`).
3. Implement `OmnirouteService` in `lib/services/omniroute_service.dart` inheriting from `OpenAIService` or custom gateway client.
4. Update `AIServiceFactory` to return `OmnirouteService` when `AIProvider.omniroute` is selected.
5. Rebuild Flutter Web app (`flutter build web`) and verify live execution.

### Step 4: State Management Implementation
1. Set up state providers for managing chat message threads, active streaming state, code snippet extractions, and model selections.
2. Support cancel/stop generation and regenerate functionality.

### Step 5: Chat-Centric UI & Code Viewer Widgets
1. Build `ChatPanel` with input text field, auto-scrolling message list, and system prompt bar.
2. Build `CodeBlockView` featuring syntax highlighting, line numbers, and action buttons (`Copy Code`, `Quick Edit`, `Apply`).
3. Build `CodeViewerPanel` for viewing full snippets side-by-side or in tabs.

### Step 6: Adaptive Layout Integration
1. Implement `AdaptiveLayout` widget using `LayoutBuilder` / `MediaQuery`:
   - **Desktop/Tablet (> 800px)**: Side-by-side split view (Chat on left/right, Code Viewer on opposite panel).
   - **Mobile (< 800px)**: Single column with bottom navigation/tabs or slide-over drawer to switch between Chat and Code Viewer.

### Step 7: Environment Setup & Flutter Web Execution
1. Install Flutter SDK into `/tmp/flutter` via Git (`git clone https://github.com/flutter/flutter.git -b stable /tmp/flutter`).
2. Add `/tmp/flutter/bin` to system environment PATH.
3. Pre-cache Flutter web binaries (`flutter config --enable-web` and `flutter precache`).
4. Fetch project dependencies (`flutter pub get`).
5. Run Flutter web development server (`flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0`) or build web release (`flutter build web`) and serve using `python3 -m http.server 8080`.

### Step 9: Project Screen & Folder Management (NEW FIRST SCREEN)
1. Create `lib/models/project_folder.dart` with path, name, lastOpened fields.
2. Create `lib/services/file_system_service.dart` for folder create/open operations.
   - **CRITICAL**: Use conditional imports (`dart:io` vs stub) because `dart:io` is unsupported on Flutter Web.
   - Provide web-compatible fallback that stores project metadata in SharedPreferences without real filesystem access.
3. Create `lib/providers/project_provider.dart` for current project & recent projects state.
4. Create `lib/ui/screens/project_screen.dart` with:
   - Large action buttons: **Create Folder**, **Open Folder**, **Clone GitHub Repo**
   - Recent folders list with quick open option
   - Dark IDE-themed UI matching Antigravity theme
5. Update `lib/main.dart` to show `ProjectScreen` as initial route.
6. On folder create/open → navigate to `MainScreen` (Editor + Chat).

### Step 9b: Fix Web FileSystem Compatibility
- Replace `dart:io` usage in `FileSystemService` with conditional imports:
  - `file_system_service_io.dart` for mobile/desktop using `dart:io`
  - `file_system_service_stub.dart` for web using in-memory/SharedPreferences fallback
- Update `pubspec.yaml` if needed to support conditional imports.
- On web, folder creation/opening becomes metadata-only (store path/name in recent projects).
- Ensure `project_screen.dart` handles web path entry gracefully with a text dialog.

### Step 10: Connection Test & Model Selector for Omniroute
1. Create `lib/services/connection_test_service.dart`:
   - `testConnection(AIModelConfig config)` → returns success/failure with latency
   - Send lightweight request to gateway endpoint and validate response
2. Create `lib/ui/widgets/connection_status.dart`:
   - Button with "Test Connection" label
   - Loading spinner during test
   - Green checkmark on success, red X on failure with error message
3. Update `lib/ui/screens/settings_screen.dart`:
   - Add "Test Connection" button below Base URL field for Omniroute provider
   - Add Model Selector dropdown populated from `provider.defaultModels`
   - Display connection status indicator next to Test button
4. Add model selector in ChatPanel header for quick model switching.

### Step 11: Update Navigation Flow
1. Make `ProjectScreen` the app entry point.
2. Store current project folder path in `ProjectProvider`.
3. Pass project context to `MainScreen` for file tree integration.
4. Add "Back to Projects" button in MainScreen header or menu.

### Step 12: GitHub Push & CI/CD Workflow
1. Configure git user name/email for commits.
2. Stage all changes: `git add lib/ .kilo/plans/ pubspec.yaml README.md`
3. Commit with message: `feat: add ProjectScreen, Omniroute provider, connection test, and model selector`
4. Push to remote: `git push origin main`
5. Create GitHub Actions workflow `.github/workflows/flutter_web_build.yml`:
   - Trigger: push to main, pull requests
   - Job: build flutter web
   - Steps:
     - Checkout code
     - Setup Flutter SDK (using `subosito/flutter-action`)
     - Run `flutter pub get`
     - Run `flutter build web`
     - Upload `build/web` as artifact or deploy to GitHub Pages
6. Verify workflow runs successfully in GitHub Actions tab.

---

## 6. Validation & Testing Plan
1. **Unit Tests**: Test SSE response parsing for all 4 AI providers (OpenAI, Anthropic, Gemini, Ollama).
2. **Widget Tests**: Test rendering of markdown code blocks, snippet extraction, and copy/quick-edit button interactions.
3. **Adaptive Layout Tests**: Test UI responsiveness across screen resize breakpoints (Mobile vs Desktop viewport dimensions).
4. **Integration Verification**: Verify multi-provider API request formatting and stream state handling.
