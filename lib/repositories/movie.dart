import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/favorite.dart';
import 'package:stream_it/models/history.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class MovieRepository extends FirebaseFirestoreRepository<Movie> {
  MovieRepository() {
    fromFirestoreMap[Movie] = (data, id) => Movie.fromJson({...data, "id": id});
    fromFirestoreMap[History] =
        (data, id) => History.fromJson({...data, "id": id});
    fromFirestoreMap[Favorite] =
        (data, id) => Favorite.fromJson({...data, "id": id});
    fromFirestoreMap[Category] =
        (data, id) => Category.fromJson({...data, "id": id});
  }

  static final MovieRepository _instance = MovieRepository();

  static get instance => _instance;
}
