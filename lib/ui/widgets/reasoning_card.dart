import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class ReasoningCard extends StatefulWidget {
  final String text;
  const ReasoningCard({super.key, required this.text});

  @override
  State<ReasoningCard> createState() => _ReasoningCardState();
}

class _ReasoningCardState extends State<ReasoningCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Thinking',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(widget.text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ),
        ],
      ),
    );
  }
}
