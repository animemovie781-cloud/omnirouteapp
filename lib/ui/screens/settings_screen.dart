import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_config.dart';
import '../../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AIProvider _selectedProvider;
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelNameController;
  late TextEditingController _systemPromptController;
  late double _temperature;
  late int _maxTokens;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _selectedProvider = settings.activeProvider;
    _initControllers(settings.configs[_selectedProvider] ?? AIModelConfig.defaultConfig(_selectedProvider));
  }

  void _initControllers(AIModelConfig config) {
    _apiKeyController = TextEditingController(text: config.apiKey);
    _baseUrlController = TextEditingController(text: config.baseUrl);
    _modelNameController = TextEditingController(text: config.modelName);
    _systemPromptController = TextEditingController(text: config.systemPrompt);
    _temperature = config.temperature;
    _maxTokens = config.maxTokens;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelNameController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final newConfig = AIModelConfig(
      provider: _selectedProvider,
      modelName: _modelNameController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim(),
      temperature: _temperature,
      maxTokens: _maxTokens,
      systemPrompt: _systemPromptController.text.trim(),
    );

    ref.read(settingsProvider.notifier).updateConfig(newConfig);
    ref.read(settingsProvider.notifier).setActiveProvider(_selectedProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedProvider.displayName} settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antigravity AI Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppTheme.primaryAccent),
            tooltip: 'Save Settings',
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Provider Selection Card
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Provider',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AIProvider>(
                    value: _selectedProvider,
                    decoration: const InputDecoration(labelText: 'Active Provider'),
                    dropdownColor: AppTheme.cardDark,
                    items: AIProvider.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.displayName),
                      );
                    }).toList(),
                    onChanged: (p) {
                      if (p != null) {
                        setState(() {
                          _selectedProvider = p;
                          final cfg = settings.configs[p] ?? AIModelConfig.defaultConfig(p);
                          _initControllers(cfg);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Provider Specific Credentials Card
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedProvider.displayName} Configuration',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent),
                  ),
                  const SizedBox(height: 12),

                  if (_selectedProvider != AIProvider.ollama) ...[
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: 'Enter API Key (e.g. sk-...)',
                        prefixIcon: Icon(Icons.key_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Base Endpoint URL',
                      hintText: 'e.g. https://api.openai.com/v1',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Connection Test Button (shown once an API key is provided)
                  if (_apiKeyController.text.trim().isNotEmpty &&
                      _baseUrlController.text.trim().isNotEmpty)
                    ConnectionStatusWidget(
                      config: AIModelConfig(
                        provider: _selectedProvider,
                        modelName: _modelNameController.text.trim(),
                        apiKey: _apiKeyController.text.trim(),
                        baseUrl: _baseUrlController.text.trim(),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textSecondary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Enter an API key (and Base URL) above to enable Test Connection.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Model Selection Dropdown
                  DropdownButtonFormField<String>(
                    value: _modelNameController.text.trim().isEmpty 
                        ? _selectedProvider.defaultModels.first 
                        : _modelNameController.text.trim(),
                    decoration: const InputDecoration(
                      labelText: 'Select Model',
                      prefixIcon: Icon(Icons.psychology_outlined),
                    ),
                    dropdownColor: AppTheme.cardDark,
                    items: _selectedProvider.defaultModels.map((model) {
                      return DropdownMenuItem<String>(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    onChanged: (model) {
                      if (model != null) {
                        setState(() {
                          _modelNameController.text = model;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Model Choice Chips
                  Wrap(
                    spacing: 6,
                    children: _selectedProvider.defaultModels.map((m) {
                      return ChoiceChip(
                        label: Text(m, style: const TextStyle(fontSize: 11)),
                        selected: _modelNameController.text == m,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _modelNameController.text = m;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Parameters Card
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generation Parameters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent),
                  ),
                  const SizedBox(height: 12),
                  Text('Temperature: ${_temperature.toStringAsFixed(2)}'),
                  Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 1.5,
                    divisions: 30,
                    activeColor: AppTheme.primaryAccent,
                    onChanged: (val) {
                      setState(() {
                        _temperature = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _systemPromptController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'System Instructions Prompt',
                      hintText: 'Custom instructions for AI code generation...',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
