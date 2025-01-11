import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class MovieRepository extends FirebaseFirestoreRepository<Movie> {
  MovieRepository() {
    collectionName = Movie.modelName;
    fromFirestore = (data, id) => Movie.fromJson({...data, "id": id});
  }

  /// Methode pour la lecture de toutes les categories d'un film [(ID ou objet)]
  Future<List<Category>> getCategories(dynamic movie) async {
    String movieId = movie is String ? movie : movie['id'];
    try {
      CollectionReference movieCategoriesRef =
          FirebaseFirestore.instance.collection('movie_categories');

      QuerySnapshot movieCategoriesSnapshot =
          await movieCategoriesRef.where('movie_id', isEqualTo: movieId).get();

      List<String> categoryIds = movieCategoriesSnapshot.docs.map((doc) {
        return doc['category_id'] as String;
      }).toList();

      CollectionReference categoriesRef =
          FirebaseFirestore.instance.collection('categories');

      List<Category> categories = [];
      for (String categoryId in categoryIds) {
        DocumentSnapshot categoryDoc =
            await categoriesRef.doc(categoryId).get();
        if (categoryDoc.exists) {
          categories.add(Category.fromJson(
              {...categoryDoc.data() as Map, "id": categoryDoc.id}));
        }
      }

      return categories;
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      return [];
    }
  }

  /// Méthode pour l'ajout de catégories [(liste d'ID et/ou d'objets)]
  /// à un film [(ID ou objet)]
  Future<void> addCategories(dynamic movie,
      {List<dynamic>? categories, bool continueOnError = false}) async {
    if (categories == null || categories.isEmpty) {
      print('Aucune catégorie à ajouter.');
      return;
    }

    CollectionReference movieCategoriesRef =
    FirebaseFirestore.instance.collection('movie_categories');
    String movieId = movie is String ? movie : movie['id'];
    for (var category in categories) {
      try {
        // Récupérer l'ID de la catégorie (soit directement soit via un champ 'id')
        String categoryId = category is String ? category : category['id'];

        // Vérifier si la relation existe déjà
        QuerySnapshot existingRelation = await movieCategoriesRef
            .where('movie_id', isEqualTo: movieId)
            .where('category_id', isEqualTo: categoryId)
            .get();

        if (existingRelation.docs.isNotEmpty) {
          print('La catégorie $categoryId est déjà associée au film $movieId.');
          continue; // Passer à la catégorie suivante
        }

        // Ajouter la relation
        await movieCategoriesRef.add({
          'movie_id': movieId,
          'category_id': categoryId,
        });

        print('Catégorie $categoryId ajoutée au film $movieId.');
      } catch (e) {
        print(
            'Erreur lors de l\'ajout de la catégorie $category au film $movieId : $e');
        if (!continueOnError) {
          return; // Arrêter si une erreur survient et continueOnError est false
        }
      }
    }
  }

  /// Méthode pour la suppression de catégories [(liste d'ID et/ou d'objets)]
  /// d'un film [(ID ou objet)]
  Future<void> removeCategories(dynamic movie,
      {List<dynamic>? categories, bool continueOnError = false}) async {
    if (categories == null || categories.isEmpty) {
      print('Aucune catégorie à supprimer.');
      return;
    }

    CollectionReference movieCategoriesRef =
    FirebaseFirestore.instance.collection('movie_categories');
    String movieId = movie is String ? movie : movie['id'];

    for (var category in categories) {
      try {
        // Récupérer l'ID de la catégorie (soit directement soit via un champ 'id')
        String categoryId = category is String ? category : category['id'];

        // Rechercher les relations à supprimer
        QuerySnapshot existingRelation = await movieCategoriesRef
            .where('movie_id', isEqualTo: movieId)
            .where('category_id', isEqualTo: categoryId)
            .get();

        if (existingRelation.docs.isEmpty) {
          print(
              'Aucune relation trouvée pour la catégorie $categoryId et le film $movieId.');
          continue; // Passer à la catégorie suivante
        }

        // Supprimer toutes les relations trouvées
        for (QueryDocumentSnapshot doc in existingRelation.docs) {
          await doc.reference.delete();
        }

        print('Catégorie $categoryId supprimée du film $movieId.');
      } catch (e) {
        print(
            'Erreur lors de la suppression de la catégorie $category du film $movieId : $e');
        if (!continueOnError) {
          return; // Arrêter si une erreur survient et continueOnError est false
        }
      }
    }
  }
}
