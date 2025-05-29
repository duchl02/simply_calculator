import 'package:hive/hive.dart';

abstract class BaseHiveStorage<T> {
  final String boxName;

  BaseHiveStorage(this.boxName);

  Future<Box<T>> get _box async =>
      Hive.isBoxOpen(boxName)
          ? Hive.box<T>(boxName)
          : await Hive.openBox<T>(boxName);

  Future<void> save(dynamic key, T value) async => (await _box).put(key, value);

  Future<T?> get(dynamic key) async => (await _box).get(key);

  Future<List<T>> getAll() async => (await _box).values.toList();

  Future<void> _deleteKey(dynamic key) async => (await _box).delete(key);

  Future<void> clearAll() async => (await _box).clear();

  Future<void> deleteBox() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<T>(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  Future<void> putById(T item) async => (await _box).put(_getId(item), item);

  Future<void> putAllById(List<T> items) async {
    final map = {for (var item in items) _getId(item): item};
    await (await _box).putAll(map);
  }

  Future<void> deleteById(T item) async => await _deleteKey(_getId(item));

  Future<void> deleteMultiple(List<T> items) async {
    final keys = items.map((item) => _getId(item)).toList();
    await (await _box).deleteAll(keys);
  }

  Stream<BoxEvent> watch() async* {
    final box = await _box;
    yield* box.watch();
  }

  dynamic _getId(T item) {
    try {
      dynamic id = (item as dynamic).id;
      if (id is String || id is int) {
        return id.toString();
      } else {
        throw Exception('ID must be a String or an int.');
      }
    } catch (_) {
      throw Exception(
        'Model ${item.runtimeType} must have an id field of type String or int.',
      );
    }
  }
}
