import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class UserRepository extends FirebaseFirestoreRepository<User> {
  static final UserRepository _instance = UserRepository();

  static UserRepository get instance => _instance;
}