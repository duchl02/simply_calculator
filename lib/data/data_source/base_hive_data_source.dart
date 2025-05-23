import 'package:hive/hive.dart';

abstract class BaseHiveLocalDataSource<T extends HiveObject> {
  String get boxName;

  Future<Box<T>> get _box async => await Hive.openBox<T>(boxName);

  Future<void> put(String key, T item) async => (await _box).put(key, item);

  Future<void> putById(T item) async => (await _box).put(_getId(item), item);

  Future<void> putAll(Map<String, T> items) async => (await _box).putAll(items);

  Future<void> putAllById(List<T> items) async {
    final mapped = {for (var item in items) _getId(item): item};
    await putAll(mapped);
  }

  Future<List<T>> getAll() async => (await _box).values.toList();

  Future<T?> get(String key) async => (await _box).get(key);

  Future<void> delete(String key) async => (await _box).delete(key);

  Future<void> deleteById(T item) async => await delete(_getId(item));

  Future<void> clear() async => (await _box).clear();

  String _getId(T item) {
    try {
      final id = (item as dynamic).id;
      if (id is! String) {
        throw Exception('`id` must be a String');
      }
      return id;
    } catch (_) {
      throw Exception(
        'Model ${item.runtimeType} must have a String `id` field.',
      );
    }
  }
}
