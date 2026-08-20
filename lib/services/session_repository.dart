import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_models.dart';

class SessionRepository {
  static const String boxName = 'chat_sessions';

  Future<Box<dynamic>> _box() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<List<ChatSession>> getAll() async {
    final box = await _box();
    final list = <ChatSession>[];
    for (final entry in box.values) {
      if (entry is Map<String, dynamic>) {
        list.add(ChatSession.fromJson(entry));
      }
    }
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  Future<void> upsert(ChatSession session) async {
    final box = await _box();
    await box.put(session.id, session.toJson());
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  Future<Box<dynamic>> messagesBox(String sessionId) async {
    final boxName = 'session_msgs_$sessionId';
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }
}
