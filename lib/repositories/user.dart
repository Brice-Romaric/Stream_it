import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class UserRepository extends FirebaseFirestoreRepository<User> {
  UserRepository() {
    fromFirestoreMap[User] = (data, id) => User.fromJson({...data, "id": id});
  }

  static final UserRepository _instance = UserRepository();

  static get instance => _instance;
}