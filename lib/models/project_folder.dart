import 'package:uuid/uuid.dart';

class ProjectFolder {
  final String id;
  final String name;
  final String path;
  final DateTime lastOpened;
  final DateTime createdAt;

  ProjectFolder({
    String? id,
    required this.name,
    required this.path,
    DateTime? lastOpened,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        lastOpened = lastOpened ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  ProjectFolder copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? lastOpened,
    DateTime? createdAt,
  }) {
    return ProjectFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      lastOpened: lastOpened ?? this.lastOpened,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'lastOpened': lastOpened.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProjectFolder.fromJson(Map<String, dynamic> json) {
    return ProjectFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      lastOpened: DateTime.parse(json['lastOpened'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}