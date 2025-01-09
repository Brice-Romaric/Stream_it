import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class MovieRepository extends FirebaseFirestoreRepository<Movie> {
  MovieRepository() {
    collectionName = Movie.modelName;
    fromFirestore = (data, id) => Movie.fromJson({...data, "id": id});
  }

  Future<List<Category>> getCategories(String movieId) async {
    try {
      CollectionReference movieCategoriesRef =
      FirebaseFirestore.instance.collection('movie_categories');

      QuerySnapshot movieCategoriesSnapshot = await movieCategoriesRef
          .where('movie_id', isEqualTo: movieId)
          .get();

      List<String> categoryIds = movieCategoriesSnapshot.docs.map((doc) {
        return doc['category_id'] as String;
      }).toList();

      CollectionReference categoriesRef =
      FirebaseFirestore.instance.collection('categories');

      List<Category> categories = [];
      for (String categoryId in categoryIds) {
        DocumentSnapshot categoryDoc = await categoriesRef.doc(categoryId).get();
        if (categoryDoc.exists) {
          categories.add(Category.fromJson({...categoryDoc.data() as Map, "id": categoryDoc.id}));
        }
      }

      return categories;
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      return [];
    }
  }
}