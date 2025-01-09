import 'package:stream_it/models/favorite.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class FavoriteRepository extends FirebaseFirestoreRepository<Favorite> {
  FavoriteRepository() {
    collectionName = Favorite.modelName;
    fromFirestore = (data, id) => Favorite.fromJson({...data, "id": id});
  }
}