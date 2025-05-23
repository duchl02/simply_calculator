import 'package:hive_flutter/hive_flutter.dart';
import 'package:simply_calculator/data/data_source/database_utils.dart';

abstract class BaseHiveStorage<T> {
  BaseHiveStorage({required String boxName}) {
    assert(boxName.isNotEmpty);
    _boxName = boxName;
  }

  late String _boxName;

  Future<Box<T>>? get boxInstance => DatabaseUtils.getBox<T>(boxName: _boxName);

  Future<List<T>?> getData();

  Future<T?> get(String key) async {
    final box = await boxInstance;
    return box?.get(key);
  }

  Future<List<T>?> getAll() async {
    final box = await boxInstance;
    return box?.values.toList();
  }

  Future<void> put(String key, T value) async {
    final box = await boxInstance;
    await box?.put(key, value);
  }

  Future<void> putAll(Map<String, T> map) async {
    final box = await boxInstance;
    await box?.putAll(map);
  }

  Future<void> delete(String key) async {
    final box = await boxInstance;
    await box?.delete(key);
  }

  Future<void> deleteAll() async {
    final box = await boxInstance;
    await box?.clear();
  }
}
