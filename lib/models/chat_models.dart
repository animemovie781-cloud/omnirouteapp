enum MessageRole { user, assistant, system }

enum PartType { text, tool, reasoning, file, error }

enum ToolStatus { pending, running, completed, error }

sealed class MessagePart {
  final String id;
  const MessagePart(this.id);

  Map<String, dynamic> toJson() => {'id': id, 'type': type.name};
  String get type;
}

class TextPart extends MessagePart {
  final String text;
  final bool streaming;
  const TextPart({required super.id, required this.text, this.streaming = false});

  @override
  String get type => 'text';

  TextPart copyWith({String? text, bool? streaming}) {
    return TextPart(id: id, text: text ?? this.text, streaming: streaming ?? this.streaming);
  }
}

class ReasoningPart extends MessagePart {
  final String text;
  final bool collapsed;
  const ReasoningPart({required super.id, required this.text, this.collapsed = true});

  @override
  String get type => 'reasoning';

  ReasoningPart copyWith({String? text, bool? collapsed}) {
    return ReasoningPart(id: id, text: text ?? this.text, collapsed: collapsed ?? this.collapsed);
  }
}

class ToolPart extends MessagePart {
  final String toolName;
  final ToolStatus status;
  final String activeLabel;
  final String doneLabel;
  final Map<String, dynamic> input;
  final String? output;
  final String? errorMessage;

  const ToolPart({
    required super.id,
    required this.toolName,
    required this.status,
    required this.activeLabel,
    required this.doneLabel,
    this.input = const {},
    this.output,
    this.errorMessage,
  });

  @override
  String get type => 'tool';

  ToolPart copyWith({
    String? toolName,
    ToolStatus? status,
    String? activeLabel,
    String? doneLabel,
    Map<String, dynamic>? input,
    String? output,
    String? errorMessage,
  }) {
    return ToolPart(
      id: id,
      toolName: toolName ?? this.toolName,
      status: status ?? this.status,
      activeLabel: activeLabel ?? this.activeLabel,
      doneLabel: doneLabel ?? this.doneLabel,
      input: input ?? this.input,
      output: output ?? this.output,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FilePart extends MessagePart {
  final String fileName;
  final String mimeType;
  final String? localPath;
  final String? url;

  const FilePart({
    required super.id,
    required this.fileName,
    required this.mimeType,
    this.localPath,
    this.url,
  });

  @override
  String get type => 'file';

  FilePart copyWith({String? fileName, String? mimeType, String? localPath, String? url}) {
    return FilePart(
      id: id,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      localPath: localPath ?? this.localPath,
      url: url ?? this.url,
    );
  }
}

class ErrorPart extends MessagePart {
  final String message;
  const ErrorPart({required super.id, required this.message});

  @override
  String get type => 'error';

  ErrorPart copyWith({String? message}) {
    return ErrorPart(id: id, message: message ?? this.message);
  }
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final List<MessagePart> parts;
  final DateTime createdAt;
  final String? providerId;
  final String? modelId;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.role,
    required this.parts,
    DateTime? createdAt,
    this.providerId,
    this.modelId,
    this.isError = false,
  }) : createdAt = createdAt ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    List<MessagePart>? parts,
    DateTime? createdAt,
    String? providerId,
    String? modelId,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      parts: parts ?? this.parts,
      createdAt: createdAt ?? this.createdAt,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      isError: isError ?? this.isError,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role = MessageRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => MessageRole.user,
    );
    final partsJson = json['parts'] as List<dynamic>? ?? [];
    final parts = partsJson.map((p) {
      final type = p['type'] as String;
      switch (type) {
        case 'text':
          return TextPart(id: p['id'] as String, text: p['text'] as String, streaming: p['streaming'] as bool? ?? false);
        case 'reasoning':
          return ReasoningPart(id: p['id'] as String, text: p['text'] as String, collapsed: p['collapsed'] as bool? ?? true);
        case 'tool':
          return ToolPart(
            id: p['id'] as String,
            toolName: p['toolName'] as String,
            status: ToolStatus.values.firstWhere((e) => e.name == p['status'], orElse: () => ToolStatus.pending),
            activeLabel: p['activeLabel'] as String,
            doneLabel: p['doneLabel'] as String,
            input: Map<String, dynamic>.from(p['input'] as Map? ?? {}),
            output: p['output'] as String?,
            errorMessage: p['errorMessage'] as String?,
          );
        case 'file':
          return FilePart(
            id: p['id'] as String,
            fileName: p['fileName'] as String,
            mimeType: p['mimeType'] as String,
            localPath: p['localPath'] as String?,
            url: p['url'] as String?,
          );
        case 'error':
          return ErrorPart(id: p['id'] as String, message: p['message'] as String);
        default:
          return TextPart(id: p['id'] as String, text: p['text'] as String? ?? '');
      }
    }).toList();

    return ChatMessage(
      id: json['id'] as String,
      role: role,
      parts: parts,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      providerId: json['providerId'] as String?,
      modelId: json['modelId'] as String?,
      isError: json['isError'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'parts': parts.map((p) => _partToJson(p)).toList(),
      'createdAt': createdAt.toIso8601String(),
      'providerId': providerId,
      'modelId': modelId,
      'isError': isError,
    };
  }

  static Map<String, dynamic> _partToJson(MessagePart part) {
    final base = {'id': part.id, 'type': part.type};
    if (part is TextPart) {
      return {...base, 'text': part.text, 'streaming': part.streaming};
    } else if (part is ReasoningPart) {
      return {...base, 'text': part.text, 'collapsed': part.collapsed};
    } else if (part is ToolPart) {
      return {
        ...base,
        'toolName': part.toolName,
        'status': part.status.name,
        'activeLabel': part.activeLabel,
        'doneLabel': part.doneLabel,
        'input': part.input,
        'output': part.output,
        'errorMessage': part.errorMessage,
      };
    } else if (part is FilePart) {
      return {
        ...base,
        'fileName': part.fileName,
        'mimeType': part.mimeType,
        'localPath': part.localPath,
        'url': part.url,
      };
    } else if (part is ErrorPart) {
      return {...base, 'message': part.message};
    }
    return base;
  }
}
