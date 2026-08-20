import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_provider.dart';
import '../../providers/project_provider.dart';
import 'file_explorer_panel.dart';
import '../theme/app_theme.dart';

class CodeViewerPanel extends ConsumerStatefulWidget {
  const CodeViewerPanel({super.key});

  @override
  ConsumerState<CodeViewerPanel> createState() => _CodeViewerPanelState();
}

class _CodeViewerPanelState extends ConsumerState<CodeViewerPanel> {
  late TextEditingController _codeController;
  bool _showExplorer = false;

  static const List<String> supportedLanguages = [
    'dart',
    'python',
    'javascript',
    'typescript',
    'java',
    'cpp',
    'go',
    'rust',
    'html',
    'css',
    'json',
    'sql',
    'markdown',
  ];

  @override
  void initState() {
    super.initState();
    final initialCode = ref.read(editorProvider).currentCode;
    _codeController = TextEditingController(text: initialCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final project = ref.watch(projectProvider).currentProject;

    // Keep controller text synchronized if changed outside
    if (_codeController.text != editorState.currentCode && !editorState.isEditing) {
      _codeController.text = editorState.currentCode;
    }

    final lines = editorState.currentCode.split('\n');

    return Column(
      children: [
        // Editor Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppTheme.sidebarDark,
            border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: _showExplorer ? AppTheme.primaryAccent : AppTheme.textSecondary,
                ),
                tooltip: 'Toggle file explorer',
                onPressed: () => setState(() => _showExplorer = !_showExplorer),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.integration_instructions_rounded, color: AppTheme.primaryAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                editorState.activeSnippet?.title ?? 'Code Editor Buffer',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),

              // Language Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: supportedLanguages.contains(editorState.currentLanguage)
                        ? editorState.currentLanguage
                        : 'dart',
                    isDense: true,
                    dropdownColor: AppTheme.cardDark,
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryAccent),
                    items: supportedLanguages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (lang) {
                      if (lang != null) {
                        ref.read(editorProvider.notifier).updateLanguage(lang);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Toggle Edit Mode
              IconButton(
                icon: Icon(
                  editorState.isEditing ? Icons.visibility_rounded : Icons.edit_note_rounded,
                  size: 20,
                  color: editorState.isEditing ? AppTheme.primaryAccent : AppTheme.textSecondary,
                ),
                tooltip: editorState.isEditing ? 'Switch to View Mode' : 'Switch to Edit Mode',
                onPressed: () {
                  ref.read(editorProvider.notifier).toggleEditing();
                },
              ),

              // Copy Button
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'Copy Code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: editorState.currentCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Editor code copied to clipboard!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Editor Workspace Body (with optional file explorer)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showExplorer && project != null) ...[
                FileExplorerPanel(project: project),
                const VerticalDivider(width: 1, color: AppTheme.borderDark),
              ],
              Expanded(
                child: Container(
                  color: const Color(0xFF0D1117),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Line Numbers Sidebar
                      Container(
                        width: 44,
                  color: const Color(0xFF161B22),
                  padding: const EdgeInsets.only(top: 12, right: 8),
                  child: ListView.builder(
                    itemCount: lines.length,
                    itemBuilder: (context, idx) {
                      return Text(
                        '${idx + 1}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1, color: AppTheme.borderDark),

                // Editor Content (Editable or Highlighted View)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: editorState.isEditing
                          ? SizedBox(
                              width: 800,
                              child: TextField(
                                controller: _codeController,
                                maxLines: null,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  height: 1.4,
                                  color: AppTheme.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (text) {
                                  ref.read(editorProvider.notifier).updateCode(text);
                                },
                              ),
                            )
                          : HighlightView(
                              editorState.currentCode,
                              language: editorState.currentLanguage,
                              theme: themeMap['atom-one-dark'] ?? {},
                              textStyle: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    ),
      ],
    );
  }
}
