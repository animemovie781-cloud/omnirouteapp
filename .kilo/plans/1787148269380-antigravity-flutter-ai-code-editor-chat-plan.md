# Antigravity: Flutter/Dart AI Code Editor Chat App Plan

## 1. Overview
The goal is to design and build **Antigravity**, a Flutter/Dart cross-platform AI Code Editor Chat application. The app features an adaptive, responsive UI for Desktop (Linux, macOS, Windows), Web, and Mobile (iOS, Android). It provides a chat-centric interface with rich markdown and syntax-highlighted code block rendering, snippet copy/apply features, quick code editing, and multi-provider AI integration (OpenAI, Anthropic, Gemini, Ollama).

---

## 2. Key Requirements & Scope
- **Target Platform**: All Platforms (Adaptive UI - Desktop split panel, Mobile drawer/tab view, Web responsive layout).
- **AI Backend Strategy**: Multi-provider support directly via user-configured API keys and custom API endpoints (OpenAI, Anthropic, Gemini, Ollama, Omniroute).
- **Core Interface**: Chat-centric code viewer with syntax highlighting, inline snippet actions (copy, insert, format), and single-file quick editor view.
- **State & Storage**: Persistence of API keys, model parameters, system prompts, and session chat history using local storage.

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
│   └── code_snippet.dart           # Extracted code snippet model
├── services/
│   ├── ai_service_interface.dart   # Abstract AI service interface
│   ├── openai_service.dart         # OpenAI API & streaming implementation
│   ├── anthropic_service.dart      # Anthropic Claude API implementation
│   ├── gemini_service.dart         # Google Gemini API implementation
│   ├── ollama_service.dart         # Local Ollama endpoint implementation
│   ├── omniroute_service.dart      # Omniroute proxy API implementation
│   └── settings_service.dart       # API key & preference storage
├── providers/
│   ├── chat_provider.dart          # Chat state & message stream handler
│   ├── settings_provider.dart      # Selected AI model & API credentials state
│   └── editor_provider.dart        # Quick editor & current code context state
└── ui/
    ├── screens/
    │   ├── main_screen.dart        # Adaptive layout wrapper (Desktop vs Mobile layout)
    │   └── settings_screen.dart    # AI provider configuration & API key management
    ├── widgets/
    │   ├── chat_panel.dart         # Message feed, streaming bubble, input field
    │   ├── code_viewer_panel.dart  # Syntax highlighted code viewer & snippet inspector
    │   ├── code_block_view.dart    # Highlighting widget with Copy/Apply actions
    │   └── provider_selector.dart  # Dropdown for switching models/providers
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

---

## 6. Validation & Testing Plan
1. **Unit Tests**: Test SSE response parsing for all 4 AI providers (OpenAI, Anthropic, Gemini, Ollama).
2. **Widget Tests**: Test rendering of markdown code blocks, snippet extraction, and copy/quick-edit button interactions.
3. **Adaptive Layout Tests**: Test UI responsiveness across screen resize breakpoints (Mobile vs Desktop viewport dimensions).
4. **Integration Verification**: Verify multi-provider API request formatting and stream state handling.
