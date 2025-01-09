import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class CategoryRepository extends FirebaseFirestoreRepository<Category> {
  CategoryRepository() {
    collectionName = Category.modelName;
    fromFirestore = (data, id) => Category.fromJson({...data, "id": id});
  }

  Future<List<Movie>> getMovies(String categoryId) async {
    try {
      CollectionReference movieCategoriesRef =
      FirebaseFirestore.instance.collection('movie_categories');

      QuerySnapshot movieCategoriesSnapshot = await movieCategoriesRef
          .where('category_id', isEqualTo: categoryId)
          .get();

      List<String> movieIds = movieCategoriesSnapshot.docs.map((doc) {
        return doc['movie_id'] as String;
      }).toList();

      CollectionReference moviesRef = FirebaseFirestore.instance.collection('movies');

      List<Movie> movies = [];
      for (String movieId in movieIds) {
        DocumentSnapshot movieDoc = await moviesRef.doc(movieId).get();
        if (movieDoc.exists) {
          movies.add(Movie.fromJson({
            ...movieDoc.data() as Map,
            'id': movieDoc.id
          }));
        }
      }

      return movies;
    } catch (e) {
      print("Erreur lors de la récupération des films : $e");
      return [];
    }
  }

}