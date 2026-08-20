import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/permission_models.dart';
import '../../ui/theme/app_theme.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  final List<ToolPermission> _permissions = const [
    ToolPermission(toolName: 'file_read', defaultAction: PermissionAction.allow),
    ToolPermission(toolName: 'file_write', defaultAction: PermissionAction.ask),
    ToolPermission(toolName: 'shell_exec', defaultAction: PermissionAction.ask),
    ToolPermission(toolName: 'web_search', defaultAction: PermissionAction.allow),
    ToolPermission(toolName: 'send_telegram', defaultAction: PermissionAction.deny),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Permissions', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.sidebarDark,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Control which tools the AI can use. "Ask" will prompt you before each use.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          for (final p in _permissions)
            ListTile(
              title: Text(p.toolName, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(_describeAction(p.defaultAction), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              trailing: SegmentedButton<PermissionAction>(
                segments: const [
                  ButtonSegment(value: PermissionAction.ask, label: Text('Ask', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: PermissionAction.allow, label: Text('Allow', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: PermissionAction.deny, label: Text('Deny', style: TextStyle(fontSize: 12))),
                ],
                selected: {p.defaultAction},
                onSelectionChanged: (Set<PermissionAction> newSelection) {
                  // TODO: persist via controller
                },
              ),
            ),
        ],
      ),
    );
  }

  String _describeAction(PermissionAction action) {
    switch (action) {
      case PermissionAction.ask:
        return 'Will ask before each use';
      case PermissionAction.allow:
        return 'Always allowed';
      case PermissionAction.deny:
        return 'Always denied';
    }
  }
}
