import '../models/project_folder.dart';

class FileSystemService {
  Future<ProjectFolder> createFolder(String name, String parentPath) async {
    final path = '$parentPath/$name';
    return ProjectFolder(name: name, path: path);
  }

  Future<ProjectFolder> openFolder(String path) async {
    final name = path.split('/').last;
    return ProjectFolder(name: name, path: path);
  }

  Future<List<String>> listFiles(String path, {bool recursive = false}) async {
    return [];
  }

  Future<String?> readFile(String path) async {
    return null;
  }

  Future<void> writeFile(String path, String content) async {
    return;
  }
}
