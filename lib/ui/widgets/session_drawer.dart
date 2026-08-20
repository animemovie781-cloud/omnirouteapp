import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session_models.dart';
import '../../providers/session_controller.dart';
import '../../ui/theme/app_theme.dart';

class SessionDrawer extends ConsumerWidget {
  const SessionDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final activeId = ref.watch(activeSessionIdProvider);
    final actions = ref.read(sessionActionsProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.add_rounded, color: AppTheme.primaryAccent),
              title: const Text('New chat', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                await actions.createNew();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const Divider(color: AppTheme.borderDark),
            Expanded(
              child: sessionsAsync.when(
                data: (sessions) => ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (ctx, i) {
                    final s = sessions[i];
                    return ListTile(
                      selected: s.id == activeId,
                      selectedTileColor: AppTheme.primaryAccent.withValues(alpha: 0.1),
                      leading: Icon(
                        s.pinned ? Icons.push_pin_rounded : Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: s.pinned ? AppTheme.primaryAccent : AppTheme.textSecondary,
                      ),
                      title: Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: s.id == activeId ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(_relativeTime(s.updatedAt), style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        ref.read(activeSessionIdProvider.notifier).state = s.id;
                        Navigator.pop(context);
                      },
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppTheme.textSecondary),
                        onSelected: (v) {
                          if (v == 'pin') actions.togglePin(s);
                          if (v == 'rename') _showRenameDialog(context, ref, s);
                          if (v == 'delete') actions.delete(s.id);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'pin', child: Text(s.pinned ? 'Unpin' : 'Pin')),
                          const PopupMenuItem(value: 'rename', child: Text('Rename')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent)),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.redAccent))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, ChatSession s) {
    final ctrl = TextEditingController(text: s.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Rename chat', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          FilledButton(
            onPressed: () {
              ref.read(sessionActionsProvider).rename(s.id, ctrl.text.trim());
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryAccent, foregroundColor: Colors.black),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
