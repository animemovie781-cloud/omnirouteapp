import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_folder.dart';
import '../../providers/project_provider.dart';
import '../../services/file_system_service.dart';
import '../theme/app_theme.dart';
import '../widgets/project_actions.dart';
import 'main_screen.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({super.key});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  final FileSystemService _fileSystem = FileSystemService();
  bool _isCreating = false;
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final recentProjects = projectState.recentProjects;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Title
                  Column(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 64,
                        color: AppTheme.primaryAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Antigravity',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI Code Editor & Chat',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Action Buttons
                  ProjectActions(
                    onCreateFolder: () => _showCreateFolderDialog(context),
                    onOpenFolder: () => _showOpenFolderDialog(context),
                    onCloneRepo: () => _showCloneRepoDialog(context),
                    isLoading: _isCreating || _isOpening,
                  ),

                  const SizedBox(height: 32),

                  // Recent Projects
                  if (recentProjects.isNotEmpty) ...[
                    const Divider(color: AppTheme.borderDark),
                    const SizedBox(height: 16),
                    Text(
                      'Recent Projects',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentProjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final project = recentProjects[index];
                        return _buildRecentProjectCard(project);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProjectCard(ProjectFolder project) {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: ListTile(
        leading: const Icon(Icons.folder_rounded, color: AppTheme.primaryAccent, size: 28),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        subtitle: Text(
          project.path,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: Text(
          _formatDate(project.lastOpened),
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        onTap: () => _openProject(project),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Create New Folder', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            hintText: 'my-project',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                setState(() => _isCreating = true);
                try {
                  final project = await _fileSystem.createFolder(name, '/home/user/projects');
                  ref.read(projectProvider.notifier).setCurrentProject(project);
                  _navigateToEditor();
                } catch (e) {
                  _showError('Failed to create folder: $e');
                } finally {
                  setState(() => _isCreating = false);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showOpenFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Open Folder', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Folder Path',
            hintText: '/home/user/projects/my-project',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                Navigator.pop(context);
                setState(() => _isOpening = true);
                try {
                  final project = await _fileSystem.openFolder(path);
                  ref.read(projectProvider.notifier).setCurrentProject(project);
                  _navigateToEditor();
                } catch (e) {
                  _showError('Failed to open folder: $e');
                } finally {
                  setState(() => _isOpening = false);
                }
              }
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _showCloneRepoDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Clone GitHub Repository', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Repository URL',
            hintText: 'https://github.com/user/repo.git',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              _showError('Git clone not yet implemented. Use terminal: git clone <url>');
            },
            child: const Text('Clone'),
          ),
        ],
      ),
    );
  }

  void _openProject(ProjectFolder project) {
    ref.read(projectProvider.notifier).setCurrentProject(project);
    _navigateToEditor();
  }

  void _navigateToEditor() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
