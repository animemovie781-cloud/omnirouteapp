import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/model_models.dart';
import '../../models/model_catalog.dart';
import '../../providers/providers_controller.dart';
import '../../ui/theme/app_theme.dart';

class ModelPickerSheet extends ConsumerStatefulWidget {
  final void Function(ModelInfo)? onSelect;
  final String? selectedModelId;
  final String? selectedProviderId;

  const ModelPickerSheet({super.key, this.onSelect, this.selectedModelId, this.selectedProviderId});

  @override
  ConsumerState<ModelPickerSheet> createState() => _ModelPickerSheetState();
}

class _ModelPickerSheetState extends ConsumerState<ModelPickerSheet> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(configuredProvidersProvider);

    return Container(
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
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                hintText: 'Search models',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderDark),
                ),
              ),
              onChanged: (v) => setState(() => search = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: providersAsync.when(
              data: (providers) {
                if (providers.isEmpty) {
                  return const Center(child: Text('No providers configured', style: TextStyle(color: AppTheme.textSecondary)));
                }
                final filteredProviders = search.isEmpty
                    ? providers
                    : providers.where((p) => p.name.toLowerCase().contains(search)).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    for (final p in filteredProviders) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.public_rounded, size: 16, color: AppTheme.primaryAccent),
                            const SizedBox(width: 8),
                            Text(
                              p.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      for (final m in ModelCatalog.forProvider(p.id))
                        if (search.isEmpty || m.name.toLowerCase().contains(search))
                          _ModelTile(
                            model: m,
                            isSelected: widget.selectedModelId == m.id && widget.selectedProviderId == p.id,
                            onTap: () {
                              widget.onSelect?.call(m);
                              Navigator.pop(context);
                            },
                          ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent)),
              error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  final ModelInfo model;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelTile({required this.model, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAccent.withValues(alpha: 0.1) : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.primaryAccent : AppTheme.borderDark),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.name, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    '${model.contextLimit != null ? "${(model.contextLimit! / 1000).round()}K ctx" : ""}'
                    '${model.inputCostPer1M != null ? " · \$${model.inputCostPer1M}/1M in" : ""}'
                    '${model.supportsVision ? " · Vision" : ""}'
                    '${model.supportsTools ? " · Tools" : ""}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, color: AppTheme.primaryAccent, size: 20),
          ],
        ),
      ),
    );
  }
}
