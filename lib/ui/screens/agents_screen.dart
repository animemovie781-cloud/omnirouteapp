import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/agent_models.dart';
import '../../providers/agent_controller.dart';
import '../../ui/theme/app_theme.dart';

class AgentsScreen extends ConsumerStatefulWidget {
  const AgentsScreen({super.key});

  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  @override
  Widget build(BuildContext context) {
    final agentsAsync = ref.watch(agentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Agents', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.sidebarDark,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryAccent),
            tooltip: 'New Agent',
            onPressed: () => _showEditor(context),
          ),
        ],
      ),
      body: agentsAsync.when(
        data: (agents) {
          if (agents.isEmpty) {
            return const Center(child: Text('No agents configured', style: TextStyle(color: AppTheme.textSecondary)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return Card(
                color: AppTheme.cardDark,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(agent.colorValue).withValues(alpha: 0.2),
                    child: Icon(Icons.smart_toy_rounded, color: Color(agent.colorValue)),
                  ),
                  title: Text(agent.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    agent.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!agent.isBuiltIn)
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.textSecondary),
                          onPressed: () => _showEditor(context, editing: agent),
                        ),
                      if (!agent.isBuiltIn)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.cardDark,
                                title: const Text('Delete Agent'),
                                content: Text('Remove "${agent.name}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              ref.read(agentActionsProvider).delete(agent.id);
                            }
                          },
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  void _showEditor(BuildContext context, {AgentDefinition? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AgentEditorSheet(editing: editing),
    );
  }
}

class AgentEditorSheet extends ConsumerStatefulWidget {
  final AgentDefinition? editing;
  const AgentEditorSheet({super.key, this.editing});

  @override
  ConsumerState<AgentEditorSheet> createState() => _AgentEditorSheetState();
}

class _AgentEditorSheetState extends ConsumerState<AgentEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _promptCtrl;
  final Set<String> _selectedTools = {};

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.editing?.name ?? '');
    _descCtrl = TextEditingController(text: widget.editing?.description ?? '');
    _promptCtrl = TextEditingController(text: widget.editing?.systemPrompt ?? '');
    _selectedTools.addAll(widget.editing?.allowedTools ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderDark, borderRadius: BorderRadius.circular(2))),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(widget.editing == null ? 'New agent' : 'Edit agent', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppTheme.textSecondary)), style: const TextStyle(color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: AppTheme.textSecondary)), style: const TextStyle(color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                TextField(controller: _promptCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'System prompt', alignLabelWithHint: true, labelStyle: TextStyle(color: AppTheme.textSecondary)), style: const TextStyle(color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                const Text('Allowed tools', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: ['file_read', 'file_write', 'shell_exec', 'web_search', 'send_telegram'].map((tool) {
                    return FilterChip(
                      label: Text(tool, style: const TextStyle(fontSize: 12)),
                      selected: _selectedTools.contains(tool),
                      onSelected: (v) => setState(() => v ? _selectedTools.add(tool) : _selectedTools.remove(tool)),
                      selectedColor: AppTheme.primaryAccent.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryAccent,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    final agent = AgentDefinition(
                      id: widget.editing?.id ?? const Uuid().v4(),
                      name: _nameCtrl.text.trim(),
                      description: _descCtrl.text.trim(),
                      systemPrompt: _promptCtrl.text.trim(),
                      allowedTools: _selectedTools.toList(),
                    );
                    if (widget.editing == null) {
                      await ref.read(agentActionsProvider).create(
                            name: agent.name,
                            systemPrompt: agent.systemPrompt,
                            allowedTools: agent.allowedTools,
                          );
                    } else {
                      await ref.read(agentActionsProvider).update(agent);
                    }
                    if (mounted) Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryAccent, foregroundColor: Colors.black),
                  child: Text(widget.editing == null ? 'Save agent' : 'Update agent'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
