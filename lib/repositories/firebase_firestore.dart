import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/repositories/repository.dart';

import '../models/model.dart';

/// Specialisation de la classe abstraite 'Repository' pour qu'elle fonctionne
/// avec firebase firestore
class FirebaseFirestoreRepository<T extends Model> implements Repository<T> {
  late final String collectionName;
  late final T Function(Map<String, dynamic> data, String id) fromFirestore;

  @override
  Future<T> create(dynamic item) async {
    if (item is T) {
      final docRef = await FirebaseFirestore.instance
          .collection(collectionName)
          .add(collectionName == "user"
              ? item.toJson()
              : item.toFirebaseFirestoreDocument());
      return fromFirestore(item.toJson(), docRef.id);
    } else {
      collectionName == "user" ? null : item.remove("id");
      final docRef =
          await FirebaseFirestore.instance.collection(collectionName).add(item);
      return fromFirestore(item, docRef.id);
    }
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
    var query = FirebaseFirestore.instance
        .collection(collectionName)
        .limit(limit ?? 20);
    if (offset != null) {
      throw UnimplementedError(
          "Pagination avec offset n'est pas directement supportée par Firestore.");
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => fromFirestore(doc.data(), doc.id)).toList();
  }

  @override
  Future<T> update(dynamic item) async {
    if (item["id"] == null) {
      throw Exception("L'objet doit avoir in ID pour une modification.");
    }
    if (item is T) {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(item.id)
          .update(item.toJson());
      return item;
    } else {
      String id = item["id"];
      item.remove("id");
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(id)
          .update(item);
      return fromFirestore(item, id);
    }
  }

  @override
  Future<bool> delete(dynamic item) async {
    String itemId = item is String ? item : item['id'];
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(itemId)
        .delete();
    return true;
  }

  @override
  Future<List<T>> search(Map<String, dynamic> filters, {
    Map<String, int>? searchTypes, // Types de recherche par champ
    int defaultType = searchTypeExact,
    int? limit,
    int? offset,
  }) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(collectionName);

    Query query = collection;

    // Parcourir les filtres pour construire la requête Firestore
    filters.forEach((field, value) {
      int type = searchTypes?[field] ??
          defaultType; // Type de recherche par défaut : Exact

      if (value is String) {
        // Recherche exacte
        if (type & searchTypeExact != 0) {
          query = query.where(field, isEqualTo: value);
        }

        // StartsWith (supporté par Firestore)
        if (type & searchTypeStartsWith != 0) {
          query = query
              .where(field, isGreaterThanOrEqualTo: value)
              .where(field, isLessThan: '$value\uf8ff');
        }

        // Les autres types nécessitent un filtrage côté client
        if ((type & searchTypeEndsWith != 0) ||
            (type & searchTypeContains != 0) ||
            (type & searchTypeIgnoreCase != 0)) {
          query = query.where(field,
              isNotEqualTo: null); // Préparation pour le filtrage côté client
        }
      } else {
        // Pour d'autres types de champs
        query = query.where(field, isEqualTo: value);
      }
    });

    // Appliquer les limites et l'offset
    if (limit != null) {
      query = query.limit(limit);
    }
    if (offset != null) {
      throw UnimplementedError(
          "Pagination avec offset n'est pas directement supportée par Firestore.");
    }

    // Exécuter la requête Firestore
    QuerySnapshot snapshot = await query.get();

    // Appliquer le filtrage côté client pour les types non supportés par Firestore
    List<T> results = snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Filtrer les résultats côté client
      for (var field in filters.keys) {
        if (filters[field] is String && data[field] is String) {
          String filterValue = filters[field];
          String documentValue = data[field];
          int type = searchTypes?[field] ?? searchTypeExact;

              // Ignore case
              if (type & searchTypeIgnoreCase != 0) {
                filterValue = filterValue.toLowerCase();
                documentValue = documentValue.toLowerCase();
              }

              // Contains
          if (type & searchTypeContains != 0 &&
              !documentValue.contains(filterValue)) {
            return null;
          }

              // EndsWith
              if (type & searchTypeEndsWith != 0 &&
              !documentValue.endsWith(filterValue)) {
            return null;
          }
        }
      }

      return fromFirestore(
          doc.exists ? doc.data() as Map<String, dynamic> : {}, doc.id);
    })
        .whereType<T>()
        .toList();

    return results;
  }
}
