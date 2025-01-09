import 'package:stream_it/models/profile.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class ProfileRepository extends FirebaseFirestoreRepository<Profile> {
  ProfileRepository() {
    collectionName = Profile.modelName;
    fromFirestore = (data, id) => Profile.fromJson({...data, "id": id});
  }
}