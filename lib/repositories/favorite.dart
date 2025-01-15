import 'package:stream_it/models/favorite.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class FavoriteRepository extends FirebaseFirestoreRepository<Favorite> {
  static final FavoriteRepository _instance = FavoriteRepository();

  static get instance => _instance;
}