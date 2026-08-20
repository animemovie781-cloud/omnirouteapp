import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/chat_models.dart';
import '../../models/model_models.dart';
import '../../providers/chat_provider.dart';
import '../../ui/widgets/model_picker_sheet.dart';
import '../../ui/theme/app_theme.dart';

class ChatPromptInput extends ConsumerStatefulWidget {
  const ChatPromptInput({super.key});

  @override
  ConsumerState<ChatPromptInput> createState() => _ChatPromptInputState();
}

class _ChatPromptInputState extends ConsumerState<ChatPromptInput> {
  final _textController = TextEditingController();
  final List<FilePart> _attachments = [];
  final FocusNode _focusNode = FocusNode();

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    setState(() {
      _attachments.addAll(result.files.map((f) {
        return FilePart(
          id: 'file_${DateTime.now().millisecondsSinceEpoch}_${f.name}',
          fileName: f.name,
          mimeType: f.extension ?? 'application/octet-stream',
          localPath: f.path,
        );
      }));
    });
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;
    ref.read(chatControllerProvider.notifier).sendMessage(text, attachments: _attachments);
    _textController.clear();
    setState(() => _attachments.clear());
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isStreaming = ref.watch(chatControllerProvider.select((s) => s.isStreaming));

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          border: Border(top: BorderSide(color: AppTheme.borderDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachments.isNotEmpty)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: _attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (ctx, i) {
                    final att = _attachments[i];
                    return Chip(
                      label: Text(att.fileName, style: const TextStyle(fontSize: 12)),
                      onDeleted: () => setState(() => _attachments.removeAt(i)),
                      deleteIconColor: AppTheme.textSecondary,
                    );
                  },
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded, size: 20),
                  onPressed: _pickAttachment,
                  tooltip: 'Attach file',
                  color: AppTheme.textSecondary,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppTheme.textSecondary),
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
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isStreaming ? Icons.stop_circle_rounded : Icons.send_rounded,
                    color: isStreaming ? Colors.redAccent : AppTheme.primaryAccent,
                  ),
                  onPressed: isStreaming
                      ? () => ref.read(chatControllerProvider.notifier).stopGeneration()
                      : _send,
                  tooltip: isStreaming ? 'Stop' : 'Send',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
