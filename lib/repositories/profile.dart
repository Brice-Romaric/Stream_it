import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/models/favorite.dart';
import 'package:stream_it/models/history.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/models/profile.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class ProfileRepository extends FirebaseFirestoreRepository<Profile> {
  ProfileRepository() {
    fromFirestoreMap[Profile] =
        (data, id) => Profile.fromJson({...data, "id": id});
    fromFirestoreMap[History] =
        (data, id) => History.fromJson({...data, "id": id});
    fromFirestoreMap[Favorite] =
        (data, id) => Favorite.fromJson({...data, "id": id});
    fromFirestoreMap[Avatar] =
        (data, id) => Avatar.fromJson({...data, "id": id});
    fromFirestoreMap[Movie] =
        (data, id) => Movie.fromJson({...data, "id": id});
  }

  static final ProfileRepository _instance = ProfileRepository();

  static get instance => _instance;
}