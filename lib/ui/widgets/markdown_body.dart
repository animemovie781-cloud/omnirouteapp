import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter/services.dart';
import '../../models/code_snippet.dart';
import '../../providers/editor_provider.dart';
import '../../ui/theme/app_theme.dart';

class MarkdownBody extends ConsumerWidget {
  final String text;
  final bool selectable;

  const MarkdownBody({super.key, required this.text, this.selectable = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Markdown(
      data: text,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      selectable: selectable,
      builders: {'code': CodeBlockBuilder(context: context, ref: ref)},
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4),
        code: const TextStyle(
          backgroundColor: Color(0xFF0D1117),
          color: AppTheme.primaryAccent,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderDark),
        ),
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final WidgetRef ref;

  CodeBlockBuilder({required this.context, required this.ref});

  @override
  Widget? visitElementAfter(dynamic element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final lang = element.attributes['class']?.replaceFirst('language-', '') ?? '';
    final cleanLang = lang.isEmpty ? 'dart' : lang.toLowerCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code_rounded, size: 16, color: AppTheme.primaryAccent),
                    const SizedBox(width: 6),
                    Text(
                      cleanLang.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.primaryAccent),
                      label: const Text(
                        'Open in Editor',
                        style: TextStyle(fontSize: 11, color: AppTheme.primaryAccent),
                      ),
                      onPressed: () {
                        final snippet = CodeSnippet(
                          id: 'snippet_${DateTime.now().millisecondsSinceEpoch}',
                          language: cleanLang,
                          code: code,
                          title: 'Snippet ($cleanLang)',
                          sourceMessageId: '',
                        );
                        ref.read(editorProvider.notifier).selectSnippet(snippet);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code snippet loaded into Editor panel.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Copy Code',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: HighlightView(
              code,
              language: cleanLang,
              theme: themeMap['atom-one-dark'] ?? {},
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
