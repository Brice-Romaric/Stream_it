import 'package:stream_it/models/history.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class HistoryRepository extends FirebaseFirestoreRepository<History> {
  HistoryRepository() {
    collectionName = History.modelName;
    fromFirestore = (data, id) => History.fromJson({...data, "id": id});
  }
}