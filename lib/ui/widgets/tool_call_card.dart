import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_models.dart';
import '../../ui/theme/app_theme.dart';

class ToolCallCard extends ConsumerWidget {
  final ToolPart part;
  const ToolCallCard({super.key, required this.part});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = part.status == ToolStatus.running || part.status == ToolStatus.pending;
    final isError = part.status == ToolStatus.error;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 0.08)
            : AppTheme.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isError ? Colors.redAccent.withValues(alpha: 0.3) : AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline
                : isActive
                    ? Icons.autorenew
                    : Icons.check_circle_outline,
            size: 16,
            color: isError ? Colors.redAccent : (isActive ? AppTheme.primaryAccent : Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isActive
                ? ShimmerText(text: part.activeLabel)
                : Text(
                    part.errorMessage ?? part.doneLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: isError ? Colors.redAccent : AppTheme.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ShimmerText extends StatefulWidget {
  final String text;
  const ShimmerText({super.key, required this.text});

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = AppTheme.textSecondary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              colors: [
                baseColor.withValues(alpha: 0.4),
                baseColor,
                baseColor.withValues(alpha: 0.4),
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        );
      },
    );
  }
}
