enum PermissionAction { ask, allow, deny }

class ToolPermission {
  final String toolName;
  final PermissionAction defaultAction;
  const ToolPermission({required this.toolName, required this.defaultAction});
}

class PermissionRule {
  final String id;
  final String toolName;
  final String pattern;
  final PermissionAction action;

  const PermissionRule({
    required this.id,
    required this.toolName,
    required this.pattern,
    required this.action,
  });
}
