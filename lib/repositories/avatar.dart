import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class AvatarRepository extends FirebaseFirestoreRepository<Avatar> {
  static final AvatarRepository _instance = AvatarRepository();

  static AvatarRepository get instance => _instance;
}