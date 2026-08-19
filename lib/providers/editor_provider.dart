import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/code_snippet.dart';

class EditorState {
  final CodeSnippet? activeSnippet;
  final String currentCode;
  final String currentLanguage;
  final bool isEditing;

  EditorState({
    this.activeSnippet,
    this.currentCode = '// Welcome to Antigravity AI Code Editor\n// Select a code block from chat or create a new snippet here.\n\nvoid main() {\n  print("Hello, Antigravity!");\n}',
    this.currentLanguage = 'dart',
    this.isEditing = false,
  });

  EditorState copyWith({
    CodeSnippet? activeSnippet,
    String? currentCode,
    String? currentLanguage,
    bool? isEditing,
  }) {
    return EditorState(
      activeSnippet: activeSnippet ?? this.activeSnippet,
      currentCode: currentCode ?? this.currentCode,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(EditorState());

  void selectSnippet(CodeSnippet snippet) {
    state = state.copyWith(
      activeSnippet: snippet,
      currentCode: snippet.code,
      currentLanguage: snippet.language,
    );
  }

  void updateCode(String code) {
    state = state.copyWith(currentCode: code);
  }

  void updateLanguage(String language) {
    state = state.copyWith(currentLanguage: language);
  }

  void toggleEditing([bool? editing]) {
    state = state.copyWith(isEditing: editing ?? !state.isEditing);
  }

  void clearEditor() {
    state = EditorState();
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});
