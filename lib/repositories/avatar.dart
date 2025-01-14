import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class AvatarRepository extends FirebaseFirestoreRepository<Avatar> {
  AvatarRepository() {
    fromFirestoreMap[Avatar] =
        (data, id) => Avatar.fromJson({...data, "id": id});
  }

  static final AvatarRepository _instance = AvatarRepository();

  static get instance => _instance;
}