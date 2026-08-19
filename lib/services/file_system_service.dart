import 'dart:io' show Directory, File;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/project_folder.dart';

class FileSystemService {
  Future<ProjectFolder> createFolder(String name, String parentPath) async {
    if (kIsWeb) {
      final path = '$parentPath/$name';
      return ProjectFolder(name: name, path: path);
    } else {
      final path = '$parentPath/$name';
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return ProjectFolder(name: name, path: path);
    }
  }

  Future<ProjectFolder> openFolder(String path) async {
    if (kIsWeb) {
      final name = path.split('/').last;
      return ProjectFolder(name: name, path: path);
    } else {
      final directory = Directory(path);
      if (!await directory.exists()) {
        throw Exception('Folder does not exist: $path');
      }
      final name = path.split('/').last;
      return ProjectFolder(name: name, path: path);
    }
  }

  Future<List<String>> listFiles(String path, {bool recursive = false}) async {
    if (kIsWeb) {
      return [];
    } else {
      final directory = Directory(path);
      if (!await directory.exists()) return [];

      final List<String> files = [];
      await for (final entity in directory.list(recursive: recursive)) {
        if (entity is File) {
          final relativePath = entity.path.replaceFirst('$path/', '');
          files.add(relativePath);
        }
      }
      return files;
    }
  }

  Future<String?> readFile(String path) async {
    if (kIsWeb) {
      return null;
    } else {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    }
  }

  Future<void> writeFile(String path, String content) async {
    if (kIsWeb) {
      return;
    } else {
      final file = File(path);
      await file.writeAsString(content);
    }
  }
}
