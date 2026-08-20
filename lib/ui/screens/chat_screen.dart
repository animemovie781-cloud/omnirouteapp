import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../models/chat_models.dart';
import '../../models/model_models.dart';
import '../../providers/chat_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/session_controller.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/chat_prompt_input.dart';
import '../../ui/widgets/markdown_body.dart';
import '../../ui/widgets/reasoning_card.dart';
import '../../ui/widgets/session_drawer.dart';
import '../../ui/widgets/tool_call_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80;
    ref.read(chatControllerProvider.notifier).setAutoScroll(atBottom);
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      if (next.autoScroll &&
          previous != null &&
          next.messages.length != previous.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    final settingsState = ref.watch(settingsProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).loadActiveSession();
    });

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      drawer: const SessionDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.sidebarDark,
        title: const Text('Antigravity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_rounded, color: AppTheme.textSecondary),
            tooltip: 'Choose model',
            onPressed: () async {
              final model = await showModalBottomSheet<ModelInfo>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ModelPickerSheet(),
              );
              if (model != null) {
                // TODO: set selected model for current session/message
              }
            },
          ),
        ],
      ),
      body: Stack(
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: chatState.messages.length,
            itemBuilder: (context, index) {
              final message = chatState.messages[index];
              return MessageBubble(
                message: message,
                modelLabel: message.modelId ?? settingsState.activeConfig.modelName,
              );
            },
          ),
          if (!chatState.autoScroll)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () => _scrollToBottom(),
                backgroundColor: AppTheme.primaryAccent,
                child: const Icon(Icons.arrow_downward, color: Colors.black),
              ),
            ),
        ],
      ),
      bottomSheet: const ChatPromptInput(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String modelLabel;

  const MessageBubble({super.key, required this.message, required this.modelLabel});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF1E2638) : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUser
                  ? AppTheme.primaryAccent.withValues(alpha: 0.3)
                  : AppTheme.borderDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final part in message.parts) _buildPart(context, part),
              if (message.role == MessageRole.assistant)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    modelLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPart(BuildContext context, MessagePart part) {
    return switch (part) {
      TextPart p => MarkdownBody(text: p.text),
      ReasoningPart p => ReasoningCard(text: p.text),
      ToolPart p => ToolCallCard(part: p),
      FilePart p => _FilePreview(part: p),
      ErrorPart p => Text(
          p.message,
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        ),
    };
  }
}

class _FilePreview extends StatelessWidget {
  final FilePart part;
  const _FilePreview({required this.part});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_rounded, size: 16, color: AppTheme.primaryAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              part.fileName,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (part.localPath != null)
            Text(
              part.localPath!,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
