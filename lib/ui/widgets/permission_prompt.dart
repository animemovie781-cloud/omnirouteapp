import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

Future<bool> askPermission(BuildContext context, {
  required String toolName,
  required String description,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.cardDark,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: Text('Allow "$toolName"?', style: const TextStyle(color: AppTheme.textPrimary)),
      content: Text(description, style: const TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Deny', style: TextStyle(color: AppTheme.textSecondary))),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryAccent, foregroundColor: Colors.black),
          child: const Text('Allow once'),
        ),
      ],
    ),
  );
  return result ?? false;
}
