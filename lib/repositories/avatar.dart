import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class AvatarRepository extends FirebaseFirestoreRepository<Avatar> {
  AvatarRepository() {
    collectionName = Avatar.modelName;
    fromFirestore = (data, id) => Avatar.fromJson({...data, "id": id});
  }
}