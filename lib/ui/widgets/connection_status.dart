import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_config.dart';
import '../../services/connection_test_service.dart';
import '../theme/app_theme.dart';

class ConnectionStatusWidget extends ConsumerStatefulWidget {
  final AIModelConfig config;

  const ConnectionStatusWidget({super.key, required this.config});

  @override
  ConsumerState<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends ConsumerState<ConnectionStatusWidget> {
  bool _isTesting = false;
  ConnectionTestResult? _result;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _result = null;
    });

    final result = await ConnectionTestService.testConnection(widget.config);
    setState(() {
      _isTesting = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textPrimary),
                    )
                  : const Icon(Icons.wifi_tethering_rounded, size: 18),
              label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.black,
              ),
            ),
            if (_result != null) ...[
              const SizedBox(width: 12),
              Icon(
                _result!.success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: _result!.success ? Colors.green : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _result!.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: _result!.success ? Colors.green : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_result != null && _result!.latencyMs != null) ...[
          const SizedBox(height: 4),
          Text(
            'Latency: ${_result!.latencyMs}ms',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ],
    );
  }
}
