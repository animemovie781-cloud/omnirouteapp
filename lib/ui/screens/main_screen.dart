import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/code_viewer_panel.dart';
import 'chat_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: const ChatScreen(),
                  ),
                  const VerticalDivider(width: 1, color: AppTheme.borderDark),
                  const Expanded(
                    flex: 6,
                    child: CodeViewerPanel(),
                  ),
                ],
              );
            } else {
              return const ChatScreen();
            }
          },
        ),
      ),
    );
  }
}
