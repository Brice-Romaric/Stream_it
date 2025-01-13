import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/repositories/repository.dart';

import '../models/model.dart';

/// Specialisation de la classe abstraite 'Repository' pour qu'elle fonctionne
/// avec firebase firestore
abstract class FirebaseFirestoreRepository<T extends Model>
    implements Repository<T> {
  final String collectionName = T.toString().toLowerCase();
  final Map<Type, Function(Map<String, dynamic>, String)> fromFirestoreMap = {};

  @override
  Future<T> create(dynamic item) async {
    if (item is T) {
      final docRef = await FirebaseFirestore.instance
          .collection(collectionName)
          .add(item.toFirebaseFirestoreDocument());
      return fromFirestoreMap[T]!(item.toJson(), docRef.id);
    } else {
      item.remove("id");
      final docRef =
          await FirebaseFirestore.instance.collection(collectionName).add(item);
      return fromFirestoreMap[T]!(item, docRef.id);
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
      return fromFirestoreMap[T]!(doc.data()!, doc.id);
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
        .map((doc) => fromFirestoreMap[T]!(doc.data(), doc.id) as T)
        .toList();
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
      return fromFirestoreMap[T]!(item, id);
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
  Future<List<T>> search(
    Map<String, dynamic> filters, {
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

          return fromFirestoreMap[T]!(
              doc.exists ? doc.data() as Map<String, dynamic> : {}, doc.id);
        })
        .whereType<T>()
        .toList();

    return results;
  }

  static get instance => throw UnimplementedError();

  @override
  Future<List<M>> getManyMany<M extends Model>(
      item, String relationName) async {
    String itemId = item is String ? item : item['id'];
    var itemsName = M.toString().toLowerCase();
    try {
      CollectionReference itemItemsRef =
          FirebaseFirestore.instance.collection(relationName);

      QuerySnapshot itemItemsSnapshot = await itemItemsRef
          .where('${collectionName}_id', isEqualTo: itemId)
          .get();

      List<String> itemsIds = itemItemsSnapshot.docs.map((doc) {
        return doc['${itemsName}_id'] as String;
      }).toList();

      CollectionReference itemsRef =
          FirebaseFirestore.instance.collection(itemsName);

      List<M> items = [];
      for (String itemsId in itemsIds) {
        DocumentSnapshot itemsDoc = await itemsRef.doc(itemsId).get();
        if (itemsDoc.exists) {
          items.add(fromFirestoreMap[M]!(
              itemsDoc.data() as Map<String, dynamic>, itemsDoc.id));
        }
      }
      return items;
    } catch (e) {
      print("Erreur lors de la récupération des '$itemsName' : $e");
      return [];
    }
  }

  @override
  Future<void> addManyMany<M extends Model>(item, String relationName,
      {List? items, bool continueOnError = false}) async {
    if (items == null || items.isEmpty) {
      print('Aucune catégorie à ajouter.');
      return;
    }
    var itemsName = M.toString().toLowerCase();

    CollectionReference itemItemsRef =
        FirebaseFirestore.instance.collection(relationName);
    String itemId = item is String ? item : item['id'];
    for (var item_ in items) {
      try {
        String itemId_ = item_ is String ? item_ : item_['id'];

        QuerySnapshot existingRelation = await itemItemsRef
            .where('${collectionName}_id', isEqualTo: itemId)
            .where('${itemsName}_id', isEqualTo: itemId_)
            .get();

        if (existingRelation.docs.isNotEmpty) {
          print('$itemId_ est déjà associée a $itemId.');
          continue; // Passer à la catégorie suivante
        }

        // Ajouter la relation
        await itemItemsRef.add({
          '${collectionName}_id': itemId,
          '${itemsName}_id': itemId_,
        });

        print('Model $itemId_ ajouté a $itemId.');
      } catch (e) {
        print('Erreur lors de l\'ajout de $item_ a $itemId : $e');
        if (!continueOnError) {
          return; // Arrêter si une erreur survient et continueOnError est false
        }
      }
    }
  }

  @override
  Future<void> removeManyMany<M extends Model>(item, String relationName,
      {List? items, bool continueOnError = false}) async {
    if (items == null || items.isEmpty) {
      print('Aucune catégorie à supprimer.');
      return;
    }

    var itemsName = M.toString().toLowerCase();
    CollectionReference itemItemsRef =
        FirebaseFirestore.instance.collection(relationName);
    String itemId = item is String ? item : item['id'];

    for (var item_ in items) {
      try {
        String itemId_ = item_ is String ? item_ : item_['id'];

        QuerySnapshot existingRelation = await itemItemsRef
            .where('${collectionName}_id', isEqualTo: itemId)
            .where('${itemsName}_id', isEqualTo: itemId_)
            .get();

        if (existingRelation.docs.isEmpty) {
          print('Aucune relation trouvée pour $itemId_ et $itemId.');
          continue; // Passer à la catégorie suivante
        }

        // Supprimer toutes les relations trouvées
        for (QueryDocumentSnapshot doc in existingRelation.docs) {
          await doc.reference.delete();
        }

        print('$itemId_ supprimée de $itemId.');
      } catch (e) {
        print('Erreur lors de la suppression de $item_ dans $itemId : $e');
        if (!continueOnError) {
          return; // Arrêter si une erreur survient et continueOnError est false
        }
      }
    }
  }

  @override
  Future<List<M>> getMany<M extends Model>(item) {
    // TODO: implement getMany
    throw UnimplementedError();
  }

  @override
  Future<void> addMany<M extends Model>(item,
      {List? items, bool continueOnError = false}) {
    // TODO: implement addMany
    throw UnimplementedError();
  }

  @override
  Future<void> removeMany<M extends Model>(item,
      {List? items, bool continueOnError = false}) {
    // TODO: implement removeMany
    throw UnimplementedError();
  }

  @override
  Future<M> getOne<M extends Model>(item) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<void> addOne<M extends Model>(item,
      {List? items, bool continueOnError = false}) {
    // TODO: implement addOne
    throw UnimplementedError();
  }

  @override
  Future<void> removeOne<M extends Model>(item,
      {List? items, bool continueOnError = false}) {
    // TODO: implement removeOne
    throw UnimplementedError();
  }
}
