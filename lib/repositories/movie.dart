import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class MovieRepository extends FirebaseFirestoreRepository<Movie> {
  static final MovieRepository _instance = MovieRepository();

  static MovieRepository get instance => _instance;
}
