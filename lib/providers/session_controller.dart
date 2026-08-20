import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/session_models.dart';
import '../services/session_repository.dart';

final sessionRepoProvider = Provider<SessionRepository>((ref) => SessionRepository());

final sessionsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final repo = ref.watch(sessionRepoProvider);
  return repo.getAll();
});

final activeSessionIdProvider = StateProvider<String?>((ref) => null);

class SessionActions {
  final Ref ref;
  SessionActions(this.ref);

  Future<ChatSession> createNew({String? agentId}) async {
    final repo = ref.read(sessionRepoProvider);
    final session = ChatSession(
      id: const Uuid().v4(),
      title: 'New chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      agentId: agentId,
    );
    await repo.upsert(session);
    ref.invalidate(sessionsProvider);
    ref.read(activeSessionIdProvider.notifier).state = session.id;
    return session;
  }

  Future<void> rename(String id, String title) async {
    final repo = ref.read(sessionRepoProvider);
    final list = await repo.getAll();
    final s = list.firstWhere((e) => e.id == id);
    await repo.upsert(ChatSession(
          id: s.id,
          title: title,
          createdAt: s.createdAt,
          updatedAt: DateTime.now(),
          providerId: s.providerId,
          modelId: s.modelId,
          agentId: s.agentId,
          pinned: s.pinned,
        ));
    ref.invalidate(sessionsProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(sessionRepoProvider);
    await repo.delete(id);
    ref.invalidate(sessionsProvider);
  }

  Future<void> togglePin(ChatSession s) async {
    final repo = ref.read(sessionRepoProvider);
    await repo.upsert(ChatSession(
          id: s.id,
          title: s.title,
          createdAt: s.createdAt,
          updatedAt: DateTime.now(),
          providerId: s.providerId,
          modelId: s.modelId,
          agentId: s.agentId,
          pinned: !s.pinned,
        ));
    ref.invalidate(sessionsProvider);
  }
}

final sessionActionsProvider = Provider<SessionActions>((ref) => SessionActions(ref));
