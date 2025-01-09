import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class UserRepository extends FirebaseFirestoreRepository<User> {
  UserRepository() {
    collectionName = User.modelName;
    fromFirestore = (data, id) => User.fromJson({...data, "id": id});
  }
}