import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class MovieRepository extends FirebaseFirestoreRepository<Movie> {
  MovieRepository() {
    fromFirestoreMap[Movie] = (data, id) => Movie.fromJson({...data, "id": id});
  }

  static final MovieRepository _instance = MovieRepository();

  static get instance => _instance;
}
