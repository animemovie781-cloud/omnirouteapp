# Antigravity - AI Code Editor Chat App (Flutter/Dart)

Antigravity is a modern, cross-platform AI Code Editor Chat Application built with Flutter and Dart. It features an adaptive UI layout for Desktop, Web, and Mobile platforms, multi-provider AI backend capabilities, and rich syntax-highlighted code block features.

---

## 🌟 Key Features

- **Adaptive Responsive UI**:
  - **Desktop / Large Displays (>= 800px)**: Side-by-side split screen with AI Chat on left panel and Code Viewer / Editor on right panel.
  - **Mobile / Small Displays (< 800px)**: Smooth tabbed interface allowing instant toggling between AI Chat and Code Editor.
- **Multi-Provider AI Service Layer**:
  - Direct SSE streaming support for **OpenAI** (`gpt-4o`, `gpt-4o-mini`, `gpt-3.5-turbo`)
  - Direct SSE streaming support for **Anthropic** (`claude-3-5-sonnet`, `claude-3-haiku`, `claude-3-opus`)
  - Direct SSE streaming support for **Google Gemini** (`gemini-1.5-pro`, `gemini-1.5-flash`)
  - Local JSON streaming for **Ollama** (`codellama`, `llama3`, `deepseek-coder`, `mistral`)
- **Chat-Centric Code Inspector**:
  - Render Markdown responses with syntax highlighting powered by `flutter_highlight` (Atom One Dark theme).
  - Code block action header with **Copy Code** and **Open in Editor** actions.
- **Integrated Code Viewer & Quick Editor**:
  - View code snippets with line numbers and custom language selector.
  - Interactive edit mode to update and modify code on the fly.
- **Configurable Settings**:
  - Securely store API keys, base endpoints, model names, temperature, system instructions, and token limits locally via `shared_preferences`.

---

## 🛠️ Project Structure

```
lib/
├── main.dart                       # App entry point & ProviderScope wrapper
├── models/
│   ├── ai_config.dart              # Provider configs, defaults & serialization
│   ├── chat_message.dart           # Chat message & automatic snippet extractor
│   └── code_snippet.dart           # Extracted code snippet model
├── services/
│   ├── ai_service_interface.dart   # Abstract stream completion contract
│   ├── openai_service.dart         # OpenAI SSE streaming integration
│   ├── anthropic_service.dart      # Anthropic Claude streaming integration
│   ├── gemini_service.dart         # Google Gemini streaming integration
│   ├── ollama_service.dart         # Local Ollama streaming integration
│   ├── ai_service_factory.dart     # Service factory by provider
│   └── settings_service.dart       # SharedPreferences configuration storage
├── providers/
│   ├── chat_provider.dart          # Riverpod ChatNotifier for message state & streams
│   ├── settings_provider.dart      # Riverpod SettingsNotifier for active provider & keys
│   └── editor_provider.dart        # Riverpod EditorNotifier for code buffer & edit mode
└── ui/
    ├── theme/
    │   └── app_theme.dart          # Dark futuristic Antigravity IDE theme
    ├── screens/
    │   ├── main_screen.dart        # Responsive layout switcher (Desktop vs Mobile)
    │   └── settings_screen.dart    # AI provider configuration dialog
    └── widgets/
        ├── chat_panel.dart         # Chat list, markdown rendering & input bar
        ├── code_block_view.dart    # Highlighting card widget with Copy & Inspect actions
        └── code_viewer_panel.dart  # Code buffer panel with line numbers & editing
```

---

## 🚀 Getting Started

### Requirements
- Flutter SDK `>= 3.0.0`
- Dart SDK `>= 3.0.0`

### Installation & Run

1. Clone or navigate to project directory:
   ```bash
   cd omnirouteapp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on your desired platform:
   - **Linux / macOS / Windows**: `flutter run -d linux` (or `macos`, `windows`)
   - **Web**: `flutter run -d chrome`
   - **Mobile**: `flutter run`

---

## 📄 License
MIT License
