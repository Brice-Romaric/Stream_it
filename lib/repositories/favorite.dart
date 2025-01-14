import 'package:stream_it/models/favorite.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/models/profile.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class FavoriteRepository extends FirebaseFirestoreRepository<Favorite> {
  FavoriteRepository() {
    fromFirestoreMap[Favorite] =
        (data, id) => Favorite.fromJson({...data, "id": id});
    fromFirestoreMap[Movie] = (data, id) => Movie.fromJson({...data, "id": id});
    fromFirestoreMap[Profile] =
        (data, id) => Profile.fromJson({...data, "id": id});
  }

  static final FavoriteRepository _instance = FavoriteRepository();

  static get instance => _instance;
}