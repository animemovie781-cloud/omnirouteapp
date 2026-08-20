import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers_controller.dart';
import '../../models/provider_models.dart';

class ModelProviderPickerButton extends ConsumerWidget {
  const ModelProviderPickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(configuredProvidersProvider);

    return providersAsync.when(
      data: (providers) {
        if (providers.isEmpty) {
          return IconButton(
            icon: const Icon(Icons.tune, size: 20),
            onPressed: () {},
            tooltip: 'No providers configured',
          );
        }
        return PopupMenuButton<ProviderConfig>(
          tooltip: 'Choose provider',
          itemBuilder: (ctx) {
            return [
              for (final p in providers)
                PopupMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Icon(
                        p.isCustom ? Icons.extension_rounded : Icons.public_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(p.name),
                    ],
                  ),
                ),
            ];
          },
          onSelected: (p) {
            // TODO: set active provider for next message turn
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.tune, size: 20),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const Icon(Icons.error_outline, size: 20),
    );
  }
}
