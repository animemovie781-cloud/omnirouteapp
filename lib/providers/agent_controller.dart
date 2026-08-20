import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/agent_models.dart';
import '../models/built_in_agents.dart';
import '../services/agent_repository.dart';

final agentRepoProvider = Provider<AgentRepository>((ref) => AgentRepository());

final agentsProvider = FutureProvider<List<AgentDefinition>>((ref) async {
  final repo = ref.watch(agentRepoProvider);
  final builtInIds = builtInAgents.map((a) => a.id).toSet();
  for (final builtIn in builtInAgents) {
    if (!builtInIds.contains(builtIn.id)) {
      await repo.upsert(builtIn);
    }
  }
  return repo.getAll();
});

class AgentActions {
  final Ref ref;
  AgentActions(this.ref);

  Future<AgentDefinition> create({
    required String name,
    required String systemPrompt,
    String? modelId,
    String? providerId,
    List<String> allowedTools = const [],
    int colorValue = 0xFF2196F3,
  }) async {
    final repo = ref.read(agentRepoProvider);
    final agent = AgentDefinition(
      id: const Uuid().v4(),
      name: name,
      systemPrompt: systemPrompt,
      modelId: modelId,
      providerId: providerId,
      allowedTools: allowedTools,
      colorValue: colorValue,
    );
    await repo.upsert(agent);
    ref.invalidate(agentsProvider);
    return agent;
  }

  Future<void> update(AgentDefinition agent) async {
    final repo = ref.read(agentRepoProvider);
    await repo.upsert(agent);
    ref.invalidate(agentsProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(agentRepoProvider);
    await repo.delete(id);
    ref.invalidate(agentsProvider);
  }
}

final agentActionsProvider = Provider<AgentActions>((ref) => AgentActions(ref));
