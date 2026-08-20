import 'package:hive_flutter/hive_flutter.dart';
import '../models/provider_models.dart';

class ProviderRepository {
  static const String _boxName = 'provider_configs';
  final Box<dynamic> _box;

  ProviderRepository(this._box);

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  List<ProviderConfig> getAll() {
    final list = <ProviderConfig>[];
    for (final entry in _box.values) {
      if (entry is Map<String, dynamic>) {
        list.add(ProviderConfig.fromJson(entry));
      }
    }
    return list;
  }

  Future<void> upsert(ProviderConfig config) async {
    await _box.put(config.id, config.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
