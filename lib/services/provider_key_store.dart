import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProviderKeyStore {
  static const _boxName = 'provider_keys';
  final FlutterSecureStorage _storage;

  ProviderKeyStore(this._storage);

  Future<void> saveKey(String providerId, String apiKey) async {
    await _storage.write(key: '${_boxName}_$providerId', value: apiKey);
  }

  Future<String?> getKey(String providerId) async {
    return _storage.read(key: '${_boxName}_$providerId');
  }

  Future<void> deleteKey(String providerId) async {
    await _storage.delete(key: '${_boxName}_$providerId');
  }
}
