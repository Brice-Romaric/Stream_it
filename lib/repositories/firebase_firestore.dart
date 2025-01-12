import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/repositories/repository.dart';

import '../models/model.dart';

/// Specialisation de la classe abstraite 'Repository' pour qu'elle fonctionne
/// avec firebase firestore
class FirebaseFirestoreRepository<T extends Model> implements Repository<T> {
  late final String collectionName;
  late final T Function(Map<String, dynamic> data, String id) fromFirestore;

  @override
  Future<T> create(T item) async {
    final docRef = await FirebaseFirestore.instance
        .collection(collectionName)
        .add(collectionName == "user" ? item.toJson() : item.toFirebaseFirestoreDocument());
    return fromFirestore(item.toJson(), docRef.id);
  }

  @override
  Future<T?> getById(dynamic item) async {
    String itemId = item is String ? item : item['id'];
    final doc = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(itemId)
        .get();

    if (doc.exists) {
      return fromFirestore(doc.data()!, doc.id);
    } else {
      return null;
    }
  }

  @override
  Future<List<T>> getAll({int? limit, int? offset}) async {
    var query = FirebaseFirestore.instance.collection(collectionName).limit(limit ?? 20);
    if (offset != null) {
      // Firebase doesn't support offsets directly, handle this with a different approach if needed.
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<T> update(T item) async {
    if (item.id == null) {
      throw Exception("Item must have an ID for update.");
    }
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(item.id)
        .update(item.toJson());
    return item;
  }

  @override
  Future<bool> delete(dynamic item) async {
    String itemId = item is String ? item : item['id'];
    await FirebaseFirestore.instance.collection(collectionName).doc(itemId).delete();
    return true;
  }

  @override
  Future<List<T>> search(Map<String, dynamic> filters,
      {int? limit, int? offset, SearchType type = SearchType.exact}) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(collectionName);

    filters.forEach((key, value) {
      if (value is String && type == SearchType.ignoreCase) {
        value = "$value\uf8ff";
      }
      query = query.where(key, isEqualTo: value);
    });

    if (limit != null) query = query.limit(limit);

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
