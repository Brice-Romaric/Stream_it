import 'package:stream_it/models/history.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class HistoryRepository extends FirebaseFirestoreRepository<History> {
  HistoryRepository() {
    fromFirestoreMap[History] =
        (data, id) => History.fromJson({...data, "id": id});
  }

  static final HistoryRepository _instance = HistoryRepository();

  static get instance => _instance;
}