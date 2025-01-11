import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class CategoryRepository extends FirebaseFirestoreRepository<Category> {
  CategoryRepository() {
    collectionName = Category.modelName;
    fromFirestore = (data, id) => Category.fromJson({...data, "id": id});
  }

  /// Methode pour la lecture de tous les films d'une categorie par son id
  Future<List<Movie>> getMovies(dynamic category) async {
    String categoryId = category is String ? category : category['id'];
    try {
      CollectionReference movieCategoriesRef =
          FirebaseFirestore.instance.collection('movie_categories');

      QuerySnapshot movieCategoriesSnapshot = await movieCategoriesRef
          .where('category_id', isEqualTo: categoryId)
          .get();

      List<String> movieIds = movieCategoriesSnapshot.docs.map((doc) {
        return doc['movie_id'] as String;
      }).toList();

      CollectionReference moviesRef =
          FirebaseFirestore.instance.collection('movies');

      List<Movie> movies = [];
      for (String movieId in movieIds) {
        DocumentSnapshot movieDoc = await moviesRef.doc(movieId).get();
        if (movieDoc.exists) {
          movies.add(
              Movie.fromJson({...movieDoc.data() as Map, 'id': movieDoc.id}));
        }
      }

      return movies;
    } catch (e) {
      print("Erreur lors de la récupération des films : $e");
      return [];
    }
  }

  /// Méthode pour ajouter des films à une catégorie (via ID ou objet direct)
  Future<void> addMovies(dynamic category,
      {List<dynamic>? movies, bool continueOnError = false}) async {
    if (movies == null || movies.isEmpty) return;

    // Obtenir l'ID de la catégorie
    String? categoryId = category is String ? category : category['id'];

    if (categoryId == null) {
      throw Exception("L'ID de la catégorie est requis.");
    }

    // Référence à la collection de liaison `movie_categories`
    CollectionReference movieCategoriesRef =
    FirebaseFirestore.instance.collection('movie_categories');

    for (var movie in movies) {
      try {
        // Obtenir l'ID du film (soit directement, soit via l'objet)
        String? movieId = movie is String ? movie : movie['id'];

        if (movieId == null) {
          throw Exception("Un ID de film est requis pour chaque élément.");
        }

        // Vérifier si la relation existe déjà
        QuerySnapshot existingRelation = await movieCategoriesRef
            .where('category_id', isEqualTo: categoryId)
            .where('movie_id', isEqualTo: movieId)
            .get();

        if (existingRelation.docs.isNotEmpty) {
          print('Ce film est déjà associé à cette catégorie.');
          continue;
        }

        // Ajouter la relation
        await movieCategoriesRef.add({
          'category_id': categoryId,
          'movie_id': movieId,
        });
      } catch (e) {
        print('Erreur lors de l\'ajout du film : $e');
        if (!continueOnError) {
          break;
        }
      }
    }
  }

  /// Méthode pour supprimer des films d'une catégorie (via ID ou objet direct)
  Future<void> removeMovies(dynamic category,
      {List<dynamic>? movies, bool continueOnError = false}) async {
    if (movies == null || movies.isEmpty) return;

    // Obtenir l'ID de la catégorie
    String? categoryId = category is String ? category : category['id'];

    if (categoryId == null) {
      throw Exception("L'ID de la catégorie est requis.");
    }

    // Référence à la collection de liaison `movie_categories`
    CollectionReference movieCategoriesRef =
    FirebaseFirestore.instance.collection('movie_categories');

    for (var movie in movies) {
      try {
        // Obtenir l'ID du film (soit directement, soit via l'objet)
        String? movieId = movie is String ? movie : movie['id'];

        if (movieId == null) {
          throw Exception("Un ID de film est requis pour chaque élément.");
        }

        // Vérifier si la relation existe
        QuerySnapshot existingRelation = await movieCategoriesRef
            .where('category_id', isEqualTo: categoryId)
            .where('movie_id', isEqualTo: movieId)
            .get();

        if (existingRelation.docs.isEmpty) {
          print('Ce film n\'est pas associé à cette catégorie.');
          continue;
        }

        // Supprimer toutes les relations correspondantes
        for (var doc in existingRelation.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Erreur lors de la suppression du film : $e');
        if (!continueOnError) {
          break;
        }
      }
    }
  }
}
