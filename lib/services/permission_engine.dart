import 'package:glob/glob.dart';
import '../models/permission_models.dart';

class PermissionEngine {
  final List<ToolPermission> defaults;
  final List<PermissionRule> rules;

  PermissionEngine({required this.defaults, required this.rules});

  PermissionAction resolve(String toolName, String inputSummary) {
    for (final rule in rules.reversed) {
      if (rule.toolName != toolName) continue;
      if (Glob(rule.pattern).matches(inputSummary)) return rule.action;
    }
    final def = defaults.where((d) => d.toolName == toolName).firstOrNull;
    return def?.defaultAction ?? PermissionAction.ask;
  }
}
