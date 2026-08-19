import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_config.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'code_block_view.dart';

class ChatPanel extends ConsumerStatefulWidget {
  final VoidCallback? onOpenSettings;

  const ChatPanel({super.key, this.onOpenSettings});

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _inputController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final settingsState = ref.watch(settingsProvider);

    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length || next.isGenerating) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        // Chat Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.sidebarDark,
            border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppTheme.primaryAccent),
              const SizedBox(width: 8),
              const Text(
                'Antigravity Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              // Provider Dropdown Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AIProvider>(
                    value: settingsState.activeProvider,
                    isDense: true,
                    dropdownColor: AppTheme.cardDark,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                    items: AIProvider.values.map((provider) {
                      return DropdownMenuItem<AIProvider>(
                        value: provider,
                        child: Text(provider.displayName),
                      );
                    }).toList(),
                    onChanged: (provider) {
                      if (provider != null) {
                        ref.read(settingsProvider.notifier).setActiveProvider(provider);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                tooltip: 'AI Model Settings',
                onPressed: widget.onOpenSettings,
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                tooltip: 'Clear Chat',
                onPressed: () {
                  ref.read(chatProvider.notifier).clearChat();
                },
              ),
            ],
          ),
        ),

        // Message List
        Expanded(
          child: chatState.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatState.messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
        ),

        // Input Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.sidebarDark,
            border: Border(top: BorderSide(color: AppTheme.borderDark)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Ask Antigravity to write code or answer questions...',
                    suffixIcon: chatState.isGenerating
                        ? IconButton(
                            icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent),
                            tooltip: 'Stop Stream',
                            onPressed: () {
                              ref.read(chatProvider.notifier).stopGeneration();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.send_rounded),
                onPressed: chatState.isGenerating ? null : _handleSend,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.auto_awesome_rounded, size: 48, color: AppTheme.textSecondary),
          SizedBox(height: 12),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            'Start a conversation with Antigravity AI Code Editor',
            style: TextStyle(fontSize: 12, color: AppTheme.borderDark),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryAccent,
              child: Icon(Icons.bolt_rounded, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1E2638) : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomLeft: !isUser ? const Radius.circular(0) : null,
                  bottomRight: isUser ? const Radius.circular(0) : null,
                ),
                border: Border.all(
                  color: isUser ? AppTheme.primaryAccent.withOpacity(0.3) : AppTheme.borderDark,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender Header
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUser ? 'You' : 'Antigravity AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isUser ? AppTheme.primaryAccent : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Message Content with Markdown & Custom Code Blocks
                  message.content.isEmpty && message.isStreaming
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4),
                            code: const TextStyle(
                              backgroundColor: Color(0xFF0D1117),
                              color: AppTheme.primaryAccent,
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                          builders: {
                            'code': CustomCodeBlockBuilder(messageId: message.id),
                          },
                        ),

                  if (message.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${message.error}',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.secondaryAccent,
              child: Icon(Icons.person_rounded, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

class CustomCodeBlockBuilder extends MarkdownElementBuilder {
  final String messageId;

  CustomCodeBlockBuilder({required this.messageId});

  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final String codeContent = element.textContent;
    String language = '';

    if (element.attributes.containsKey('class')) {
      final String lg = element.attributes['class'] ?? '';
      if (lg.startsWith('language-')) {
        language = lg.replaceFirst('language-', '');
      }
    }

    // Only render custom code block if it spans multiple lines or has language tag
    if (codeContent.contains('\n') || language.isNotEmpty) {
      return CodeBlockView(
        code: codeContent,
        language: language,
        messageId: messageId,
      );
    }
    return null;
  }
}
