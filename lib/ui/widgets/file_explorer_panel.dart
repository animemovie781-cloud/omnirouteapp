import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_folder.dart';
import '../../providers/editor_provider.dart';
import '../../services/file_system_service.dart';
import '../theme/app_theme.dart';

String _extToLang(String path) {
  final ext = path.split('.').last.toLowerCase();
  const map = {
    'dart': 'dart',
    'py': 'python',
    'js': 'javascript',
    'ts': 'typescript',
    'jsx': 'javascript',
    'tsx': 'typescript',
    'java': 'java',
    'cpp': 'cpp',
    'c': 'cpp',
    'h': 'cpp',
    'go': 'go',
    'rs': 'rust',
    'html': 'html',
    'css': 'css',
    'json': 'json',
    'sql': 'sql',
    'md': 'markdown',
    'yml': 'yaml',
    'yaml': 'yaml',
  };
  return map[ext] ?? 'dart';
}

bool _isFolder(Set<String> entries, String path) =>
    entries.any((e) => e != path && e.startsWith('$path/'));

class FileExplorerPanel extends ConsumerStatefulWidget {
  final ProjectFolder project;

  const FileExplorerPanel({super.key, required this.project});

  @override
  ConsumerState<FileExplorerPanel> createState() => _FileExplorerPanelState();
}

class _FileExplorerPanelState extends ConsumerState<FileExplorerPanel> {
  final FileSystemService _fs = FileSystemService();

  Future<List<String>> _loadFiles() async {
    return _fs.listFiles(widget.project.path, recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      width: 240,
      color: AppTheme.sidebarDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded, size: 16, color: AppTheme.primaryAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.project.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _loadFiles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final files = snapshot.data ?? [];
                if (files.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No files yet.\n(Web is metadata-only.)',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  );
                }

                final entries = <String>{};
                for (final f in files) {
                  entries.add(f);
                  final parts = f.split('/');
                  String acc = '';
                  for (int i = 0; i < parts.length - 1; i++) {
                    acc = acc.isEmpty ? parts[i] : '$acc/${parts[i]}';
                    entries.add(acc);
                  }
                }

                final sorted = entries.toList()
                  ..sort((a, b) {
                    final aFolder = _isFolder(entries, a);
                    final bFolder = _isFolder(entries, b);
                    if (aFolder != bFolder) return aFolder ? -1 : 1;
                    return a.compareTo(b);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final entry = sorted[index];
                    final isFolder = _isFolder(entries, entry);
                    final depth = entry.split('/').length - 1;
                    final name = entry.split('/').last;

                    return InkWell(
                      onTap: isFolder
                          ? null
                          : () async {
                              final content = await _fs.readFile('${widget.project.path}/$entry');
                              if (content != null && mounted) {
                                editorNotifier.updateCode(content);
                                editorNotifier.updateLanguage(_extToLang(entry));
                              }
                            },
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 12.0 + depth * 14.0,
                          top: 6,
                          bottom: 6,
                          right: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isFolder ? Icons.folder_rounded : Icons.insert_drive_file_outlined,
                              size: 16,
                              color: isFolder ? AppTheme.primaryAccent : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isFolder ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
