import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_folder.dart';
import '../services/settings_service.dart';
import 'settings_provider.dart';

class ProjectState {
  final ProjectFolder? currentProject;
  final List<ProjectFolder> recentProjects;
  final bool isLoading;

  ProjectState({
    this.currentProject,
    this.recentProjects = const [],
    this.isLoading = false,
  });

  ProjectState copyWith({
    ProjectFolder? currentProject,
    List<ProjectFolder>? recentProjects,
    bool? isLoading,
  }) {
    return ProjectState(
      currentProject: currentProject ?? this.currentProject,
      recentProjects: recentProjects ?? this.recentProjects,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  final SettingsService _settingsService;

  ProjectNotifier(this._settingsService) : super(ProjectState()) {
    loadRecentProjects();
  }

  Future<void> loadRecentProjects() async {
    state = state.copyWith(isLoading: true);
    final projects = await _settingsService.loadRecentProjects();
    state = state.copyWith(recentProjects: projects, isLoading: false);
  }

  Future<void> setCurrentProject(ProjectFolder project) async {
    state = state.copyWith(currentProject: project);
    await _settingsService.addRecentProject(project);
    await loadRecentProjects();
  }

  Future<void> clearCurrentProject() async {
    state = state.copyWith(currentProject: null);
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return ProjectNotifier(settingsService);
});
