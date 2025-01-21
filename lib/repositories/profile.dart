import 'package:stream_it/models/profile.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class ProfileRepository extends FirebaseFirestoreRepository<Profile> {
  static final ProfileRepository _instance = ProfileRepository();

  static ProfileRepository get instance => _instance;
}