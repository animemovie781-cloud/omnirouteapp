import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_panel.dart';
import '../widgets/code_viewer_panel.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _mobileSelectedIndex = 0;

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              // Desktop / Tablet Side-by-Side View
              return Row(
                children: [
                  // Left Side: Chat Panel
                  Expanded(
                    flex: 5,
                    child: ChatPanel(
                      onOpenSettings: () => _openSettings(context),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppTheme.borderDark),
                  // Right Side: Code Viewer & Editor Panel
                  const Expanded(
                    flex: 6,
                    child: CodeViewerPanel(),
                  ),
                ],
              );
            } else {
              // Mobile View with Bottom Tab Switcher
              return IndexedStack(
                index: _mobileSelectedIndex,
                children: [
                  ChatPanel(
                    onOpenSettings: () => _openSettings(context),
                  ),
                  const CodeViewerPanel(),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 800
          ? BottomNavigationBar(
              currentIndex: _mobileSelectedIndex,
              backgroundColor: AppTheme.sidebarDark,
              selectedItemColor: AppTheme.primaryAccent,
              unselectedItemColor: AppTheme.textSecondary,
              onTap: (index) {
                setState(() {
                  _mobileSelectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'AI Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.code_rounded),
                  activeIcon: Icon(Icons.code_rounded),
                  label: 'Code Editor',
                ),
              ],
            )
          : null,
    );
  }
}
