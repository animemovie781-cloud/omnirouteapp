class ModelInfo {
  final String id;
  final String providerId;
  final String name;
  final String? family;
  final int? contextLimit;
  final int? outputLimit;
  final double? inputCostPer1M;
  final double? outputCostPer1M;
  final bool supportsVision;
  final bool supportsTools;
  final bool disabled;

  const ModelInfo({
    required this.id,
    required this.providerId,
    required this.name,
    this.family,
    this.contextLimit,
    this.outputLimit,
    this.inputCostPer1M,
    this.outputCostPer1M,
    this.supportsVision = false,
    this.supportsTools = true,
    this.disabled = false,
  });
}
