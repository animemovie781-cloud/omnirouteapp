import 'package:hive_flutter/hive_flutter.dart';
import '../models/agent_models.dart';

class AgentRepository {
  static const String boxName = 'agents';

  Future<Box<dynamic>> _box() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<List<AgentDefinition>> getAll() async {
    final box = await _box();
    final list = <AgentDefinition>[];
    for (final entry in box.values) {
      if (entry is Map<String, dynamic>) {
        list.add(AgentDefinition.fromJson(entry));
      }
    }
    return list;
  }

  Future<void> upsert(AgentDefinition agent) async {
    final box = await _box();
    await box.put(agent.id, agent.toJson());
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }
}
