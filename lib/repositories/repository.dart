import 'package:stream_it/models/model.dart';

abstract class Repository<T extends Model> {
  Future<T> create(T item);

  Future<T?> getById(String id);

  Future<List<T>> getAll();

  Future<T> update(T item);

  Future<void> delete(String id);

  Future<List<T>> search(Map<String, dynamic> filters);
}
