import 'dart:io';
import '../models/project_folder.dart';

class FileSystemService {
  Future<ProjectFolder> createFolder(String name, String parentPath) async {
    final path = '$parentPath/$name';
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return ProjectFolder(name: name, path: path);
  }

  Future<ProjectFolder> openFolder(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw Exception('Folder does not exist: $path');
    }
    final name = path.split('/').last;
    return ProjectFolder(name: name, path: path);
  }

  Future<List<String>> listFiles(String path, {bool recursive = false}) async {
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

  Future<String?> readFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
