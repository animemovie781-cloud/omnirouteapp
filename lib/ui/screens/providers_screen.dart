import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/provider_catalog.dart';
import '../../models/provider_models.dart';
import '../../providers/providers_controller.dart';
import '../../ui/theme/app_theme.dart';

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(providersControllerProvider);
    final controller = ref.read(providersControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Providers (${uiState.configuredProviders.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryAccent),
            tooltip: 'Add Provider',
            onPressed: () {
              controller.openAddSheet();
              _showAddProviderSheet(context, ref);
            },
          ),
        ],
      ),
      body: uiState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryAccent),
            )
          : uiState.configuredProviders.isEmpty
              ? _buildEmptyState(context, ref)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: uiState.configuredProviders.length,
                  itemBuilder: (context, index) {
                    final provider = uiState.configuredProviders[index];
                    return _ProviderTile(
                      config: provider,
                      onEdit: () {
                        controller.openEdit(provider);
                        _showEditProviderSheet(context, ref, provider);
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.cardDark,
                            title: const Text('Delete Provider'),
                            content: Text(
                              'Remove "${provider.name}" and its API key?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          controller.deleteProvider(provider.id);
                        }
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.public_rounded, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No providers configured',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(providersControllerProvider.notifier).openAddSheet();
              _showAddProviderSheet(context, ref);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Provider'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProviderSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddProviderSheet(isEditing: false),
    );
  }

  void _showEditProviderSheet(BuildContext context, WidgetRef ref, ProviderConfig config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProviderSheet(isEditing: true, existingConfig: config),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final ProviderConfig config;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProviderTile({
    required this.config,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.2),
          child: Icon(
            config.isCustom ? Icons.extension_rounded : Icons.public_rounded,
            color: AppTheme.primaryAccent,
          ),
        ),
        title: Text(config.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          config.baseUrl,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

class AddProviderSheet extends ConsumerStatefulWidget {
  final bool isEditing;
  final ProviderConfig? existingConfig;

  const AddProviderSheet({
    super.key,
    required this.isEditing,
    this.existingConfig,
  });

  @override
  ConsumerState<AddProviderSheet> createState() => _AddProviderSheetState();
}

class _AddProviderSheetState extends ConsumerState<AddProviderSheet> {
  late int _step;
  late ProviderCatalogEntry? _selectedEntry;
  late final TextEditingController _idCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _keyCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _step = 1;
    _selectedEntry = null;
    _idCtrl = TextEditingController(text: widget.existingConfig?.id ?? '');
    _nameCtrl = TextEditingController(text: widget.existingConfig?.name ?? '');
    _urlCtrl = TextEditingController(text: widget.existingConfig?.baseUrl ?? '');
    _keyCtrl = TextEditingController();
    _error = null;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _keyCtrl.dispose();
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
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  widget.isEditing ? 'Edit Provider' : 'Add Provider',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryAccent,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(providersControllerProvider.notifier).close();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _step == 1 ? _buildCatalogPicker() : _buildCredentialsForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogPicker() {
    final catalog = ProviderCatalog.sorted;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: catalog.length,
      itemBuilder: (context, index) {
        final entry = catalog[index];
        return Card(
          color: AppTheme.cardDark,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(entry.name),
            subtitle: Text(
              entry.defaultBaseUrl,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            trailing: entry.authType == ProviderAuthType.none
                ? const Icon(Icons.lock_open_rounded, color: AppTheme.textSecondary)
                : const Icon(Icons.lock_rounded, color: AppTheme.textSecondary),
            onTap: () {
              setState(() {
                _selectedEntry = entry;
                _step = 2;
                _nameCtrl.text = entry.name;
                _urlCtrl.text = entry.defaultBaseUrl;
                _error = null;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCredentialsForm() {
    final controller = ref.read(providersControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error ?? '', style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _idCtrl,
          decoration: const InputDecoration(
            labelText: 'Provider ID',
            hintText: 'e.g. openai, anthropic',
            prefixIcon: Icon(Icons.tag_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'e.g. My OpenAI',
            prefixIcon: Icon(Icons.label_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _urlCtrl,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'e.g. https://api.openai.com/v1',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _keyCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: 'Enter API key',
            prefixIcon: Icon(Icons.key_rounded),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _step = 1;
                    _error = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.borderDark),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final id = _idCtrl.text.trim();
                  final name = _nameCtrl.text.trim();
                  final url = _urlCtrl.text.trim();
                  final key = _keyCtrl.text.trim();

                  if (id.isEmpty || name.isEmpty || url.isEmpty) {
                    setState(() => _error = 'Please fill in all required fields.');
                    return;
                  }

                  final idPattern = RegExp(r'^[a-z0-9][a-z0-9\-_]*$');
                  if (!idPattern.hasMatch(id)) {
                    setState(() => _error = 'ID must start with a letter/number and contain only lowercase letters, numbers, hyphens, and underscores.');
                    return;
                  }

                  final entry = _selectedEntry ?? ProviderCatalog.byId(id);

                  await controller.saveProvider(
                    catalogEntry: entry ??
                        ProviderCatalogEntry(
                          id: id,
                          name: name,
                          defaultBaseUrl: url,
                        ),
                    name: name,
                    baseUrl: url,
                    apiKey: key,
                    isCustom: entry == null,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.black,
                ),
                child: Text(widget.isEditing ? 'Save' : 'Add Provider'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
