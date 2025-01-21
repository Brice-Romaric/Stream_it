import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/repositories/repository.dart';
import 'package:stream_it/utils/filter.dart';

/// Specialisation de la classe abstraite 'Repository' pour qu'elle fonctionne
/// avec firebase firestore
abstract class FirebaseFirestoreRepository<T extends Model>
    implements Repository<T> {
  final String collectionName = ModelInfo.modelToCollectionName<T>();

  S _fromFirestore<S extends Model>(data, String id) {
    Function fromJson =
        Model.modelInfoOf<S>()?.getCallable("fromJson") as Function;
    Map<String, dynamic> d = {...data, "id": id};
    return fromJson(d);
  }

  @override
  Future<T> create(dynamic item) async {
    if (item is T) {
      final docRef = await FirebaseFirestore.instance
          .collection(collectionName)
          .add(item.toFirebaseFirestoreDocument());
      return _fromFirestore<T>(item.toJson(), docRef.id);
    } else {
      item.remove("id");
      final docRef =
          await FirebaseFirestore.instance.collection(collectionName).add(item);
      return _fromFirestore<T>(item, docRef.id);
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
      return _fromFirestore<T>(doc.data()!, doc.id);
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
        .map((doc) => _fromFirestore<T>(doc.data(), doc.id))
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
          .update(item.toFirebaseFirestoreDocument());
      return item;
    } else {
      String id = item["id"];
      item.remove("id");
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(id)
          .update(item);
      return _fromFirestore<T>(item, id);
    }
  }

  @override
  Future<bool> delete(dynamic item, {bool onCascade = true}) async {
    String itemId = item is String ? item : item['id'];
    var modelInfo = Model.modelInfoOf<T>()!;
    for (var entry in modelInfo.relations.entries) {
      if (entry.value == null) {
        removeMany(item, tableName: entry.key, all: true);
      } else {
        removeManyMany(item, entry.value!, tableName: entry.key, all: true);
      }
    }
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(itemId)
        .delete();
    return true;
  }

  @override
  Future<List<T>> search(Map<String, dynamic> filters,
      {Map<String, int>? searchTypes, // Types de recherche par champ
      int defaultType = searchTypeExact,
      int? limit,
      int? offset,
      bool isAnd = true}) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(collectionName);

    Query query = collection;
    var operator = isAnd ? Filter.and : Filter.or;
    List<Filter> f = [];

    // Parcourir les filtres pour construire la requête Firestore
    filters.forEach((field, value) {
      int type = searchTypes?[field] ??
          defaultType; // Type de recherche par défaut : Exact
      List<Filter> f1 = [];
      if (value is String) {
        // Recherche exacte
        if (type & searchTypeExact != 0) {
          f1.add(Filter(field, isEqualTo: value));
        }

        // StartsWith (supporté par Firestore)
        if (type & searchTypeStartsWith != 0) {
          f1.add(Filter.and(Filter(field, isGreaterThanOrEqualTo: value),
              Filter(field, isLessThan: '$value\uf8ff')));
        }

        // Les autres types nécessitent un filtrage côté client
        if ((type & searchTypeEndsWith != 0) ||
            (type & searchTypeContains != 0) ||
            (type & searchTypeIgnoreCase != 0)) {
          f1.add(Filter(field, isNotEqualTo: null));
        }
        switch (f1.length) {
          case 1:
            f.add(f1[0]);
            break;
          case 2:
            f.add(Filter.or(f1[0], f1[1]));
            break;
          case 3:
            f.add(Filter.or(f1[0], f1[1], f1[2]));
            break;
        }
      } else {
        // Pour d'autres types de champs
        f.add(Filter(field, isEqualTo: value));
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

    query = query.where(fromListFilter(f, operator));

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

          return _fromFirestore<T>(doc.exists ? doc.data() : {}, doc.id);
        })
        .whereType<T>()
        .toList();

    return results;
  }

  static get instance => throw UnimplementedError();

  @override
  Future<List<M>> getManyMany<M extends Model>(item, String relationName,
      {String? tableName}) async {
    String itemId = item is String ? item : item['id'];
    var otherName = tableName ?? ModelInfo.modelToCollectionName<M>();
    try {
      CollectionReference relationRef =
          FirebaseFirestore.instance.collection(relationName);

      QuerySnapshot relationSnapshot = await relationRef
          .where('${collectionName}_id', isEqualTo: itemId)
          .get();

      List<String> othersIds = relationSnapshot.docs.map((doc) {
        return doc['${otherName}_id'] as String;
      }).toList();

      CollectionReference otherRef =
          FirebaseFirestore.instance.collection(otherName);

      List<M> others = [];
      for (String otherId in othersIds) {
        DocumentSnapshot otherDoc = await otherRef.doc(otherId).get();
        if (otherDoc.exists) {
          others.add(_fromFirestore<M>(otherDoc.data(), otherDoc.id));
        }
      }
      return others;
    } catch (e) {
      print("Erreur lors de la récupération des '$otherName' : $e");
      return [];
    }
  }

  @override
  Future<void> addManyMany<M extends Model>(item, String relationName,
      {List? others, bool continueOnError = false, String? tableName}) async {
    if (others == null || others.isEmpty) {
      print('Aucun objet à ajouter.');
      return;
    }
    var otherName = tableName ?? ModelInfo.modelToCollectionName<M>();

    CollectionReference relationRef =
        FirebaseFirestore.instance.collection(relationName);
    String itemId = item is String ? item : item['id'];
    for (var other in others) {
      try {
        String otherId = other is String ? other : other['id'];

        QuerySnapshot existingRelation = await relationRef
            .where('${collectionName}_id', isEqualTo: itemId)
            .where('${otherName}_id', isEqualTo: otherId)
            .get();

        if (existingRelation.docs.isNotEmpty) {
          print('$otherId est déjà associée a $itemId.');
          continue; // Passer à la catégorie suivante
        }

        // Ajouter la relation
        await relationRef.add({
          '${collectionName}_id': itemId,
          '${otherName}_id': otherId,
        });

        print('Model $otherId ajouté a $itemId.');
      } catch (e) {
        print('Erreur lors de l\'ajout de $other a $itemId : $e');
        if (!continueOnError) {
          return; // Arrêter si une erreur survient et continueOnError est false
        }
      }
    }
  }

  @override
  Future<void> removeManyMany<M extends Model>(item, String relationName,
      {List? others,
      bool continueOnError = false,
      String? tableName,
      bool all = false}) async {
    var otherName = tableName ?? ModelInfo.modelToCollectionName<M>();
    CollectionReference relationRef =
        FirebaseFirestore.instance.collection(relationName);
    String itemId = item is String ? item : item['id'];

    if ((others == null || others.isEmpty) && !all) {
      print('Aucun objet à supprimer.');
      return;
    } else if ((others == null || others.isEmpty) && all) {
      QuerySnapshot existingRelation = await relationRef
          .where('${collectionName}_id', isEqualTo: itemId)
          .get();
      if (existingRelation.docs.isEmpty) {
        print('Aucune relation trouvée.');
        return; // Passer à la catégorie suivante
      }
      // Supprimer toutes les relations trouvées
      for (QueryDocumentSnapshot doc in existingRelation.docs) {
        await doc.reference.delete();
      }
    } else {
      for (var other in others!) {
        try {
          String otherId = other is String ? other : other['id'];
          QuerySnapshot existingRelation = await relationRef
              .where('${collectionName}_id', isEqualTo: itemId)
              .where('${otherName}_id', isEqualTo: otherId)
              .get();
          if (existingRelation.docs.isEmpty) {
            print('Aucune relation trouvée pour $otherId et $itemId.');
            continue; // Passer à la catégorie suivante
          }
          // Supprimer toutes les relations trouvées
          for (QueryDocumentSnapshot doc in existingRelation.docs) {
            await doc.reference.delete();
          }
          print('$otherId supprimée de $itemId.');
        } catch (e) {
          print('Erreur lors de la suppression de $other dans $itemId : $e');
          if (!continueOnError) {
            return; // Arrêter si une erreur survient et continueOnError est false
          }
        }
      }
    }
  }

  @override
  Future<List<M>> getMany<M extends Model>(item, {String? tableName}) async {
    // Vérifiez si l'item est une chaîne ou un objet avec un ID
    String itemId = item is String ? item : item['id'];
    String otherName = tableName ?? ModelInfo.modelToCollectionName<M>();

    try {
      // Récupérer la référence vers la collection
      CollectionReference otherRef =
          FirebaseFirestore.instance.collection(otherName);

      // Effectuer une requête pour les éléments liés
      QuerySnapshot querySnapshot =
          await otherRef.where('${collectionName}_id', isEqualTo: itemId).get();

      // Construire la liste d'objets à partir des documents retournés
      List<M> others = querySnapshot.docs.map((doc) {
        return _fromFirestore<M>(doc.data(), doc.id);
      }).toList();

      return others;
    } catch (e) {
      print("Erreur lors de la récupération des éléments : $e");
      return [];
    }
  }

  @override
  Future<void> addMany<M extends Model>(item,
      {List? others, bool continueOnError = false, String? tableName}) async {
    if (others == null || others.isEmpty) {
      throw ArgumentError(
          "La liste des items à ajouter ne peut pas être vide.");
    }

    // Vérifiez si l'item est une chaîne ou un objet avec un ID
    String itemId = item is String ? item : item['id'];
    String otherName = tableName ?? ModelInfo.modelToCollectionName<M>();

    try {
      CollectionReference otherRef =
          FirebaseFirestore.instance.collection(otherName);

      for (var other in others) {
        try {
          other["id"] = (await otherRef.add({
            ...other,
            '${collectionName}_id': itemId,
          }))
              .id;
        } catch (e) {
          if (!continueOnError) {
            rethrow; // Relance l'erreur si `continueOnError` est `false`
          }
          print("Erreur lors de l'ajout de l'item : $e");
        }
      }
    } catch (e) {
      print("Erreur globale lors de l'ajout des items : $e");
    }
  }

  @override
  Future<void> removeMany<M extends Model>(item,
      {List? others,
      bool continueOnError = false,
      String? tableName,
      bool all = false}) async {
    String itemId = item is String ? item : item['id'];
    String otherName = tableName ?? ModelInfo.modelToCollectionName<M>();
    CollectionReference otherRef =
        FirebaseFirestore.instance.collection(otherName);

    if ((others == null || others.isEmpty) && !all) {
      print('Aucun objet à supprimer.');
      return;
    } else if ((others == null || others.isEmpty) && all) {
      QuerySnapshot querySnapshot =
          await otherRef.where('${collectionName}_id', isEqualTo: itemId).get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await otherRef.doc(doc.id).delete();
      }
    } else {
      try {
        for (var other in others!) {
          try {
            String otherId = other is String ? other : other['id'];
            QuerySnapshot querySnapshot = await otherRef
                .where('${collectionName}_id', isEqualTo: itemId)
                .get();

            for (QueryDocumentSnapshot doc in querySnapshot.docs) {
              if (doc.id == otherId) {
                await otherRef.doc(doc.id).delete();
              }
            }
          } catch (e) {
            if (!continueOnError) {
              rethrow;
            }
            print("Erreur lors de la suppression de l'item : $e");
          }
        }
      } catch (e) {
        print("Erreur globale lors de la suppression des items : $e");
      }
    }
  }

  @override
  Future<M?> getOne<M extends Model>(item, {String? tableName}) async {
    String otherName = tableName ?? ModelInfo.modelToCollectionName<M>();
    String itemId = item is String ? item : item['id'];
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(itemId)
          .get();
      if (doc.exists) {
        String otherId = doc.get("${otherName}_id");
        if (otherId == "") {
          return null;
        }
        DocumentSnapshot os = await FirebaseFirestore.instance
            .collection(otherName)
            .doc(otherId)
            .get();
        return _fromFirestore<M>(os.data(), os.id);
      } else {
        throw Exception(
            "L'item avec l'ID $itemId n'existe pas dans la collection $collectionName.");
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'item (... a un) : $e");
      rethrow;
    }
  }

  @override
  Future<T?> setOne<M extends Model>(item, other, {String? tableName}) async {
    String otherName = tableName ?? ModelInfo.modelToCollectionName<M>();
    String itemId = item is String ? item : item['id'];
    if (other == null) {
      return removeOne<T>(item, tableName: tableName);
    } else {
      String otherId = other is String ? other : other['id'];
      try {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(itemId)
            .update({"${otherName}_id": otherId});
        var data = item is T ? item.toJson() : item;
        data["${otherName}_id"] = otherId;
        return _fromFirestore<T>(data, data["id"]);
      } catch (e) {
        print("Erreur lors de l'ajout (... a un) : $e");
        return null;
      }
    }
  }

  @override
  Future<T?> removeOne<M extends Model>(item, {String? tableName}) async {
    String otherName = tableName ?? ModelInfo.modelToCollectionName<M>();
    String itemId = item is String ? item : item['id'];
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(itemId)
          .update({"${otherName}_id": null});
      var data = item is T ? item.toJson() : item;
      data["${otherName}_id"] = null;
      return _fromFirestore<T>(data, data["id"]);
    } catch (e) {
      print("Erreur lors de la suppression (... a un) : $e");
      return null;
    }
  }
}
