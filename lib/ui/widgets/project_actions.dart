import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProjectActions extends StatelessWidget {
  final VoidCallback onCreateFolder;
  final VoidCallback onOpenFolder;
  final VoidCallback onCloneRepo;
  final bool isLoading;

  const ProjectActions({
    super.key,
    required this.onCreateFolder,
    required this.onOpenFolder,
    required this.onCloneRepo,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.create_new_folder_rounded,
          label: 'Create Folder',
          subtitle: 'Start a new project',
          color: AppTheme.primaryAccent,
          onTap: onCreateFolder,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.folder_open_rounded,
          label: 'Open Folder',
          subtitle: 'Open existing project',
          color: AppTheme.secondaryAccent,
          onTap: onOpenFolder,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.code_rounded,
          label: 'Clone GitHub Repo',
          subtitle: 'Clone from URL',
          color: const Color(0xFF4CAF50),
          onTap: onCloneRepo,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
