import 'package:stream_it/models/history.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class HistoryRepository extends FirebaseFirestoreRepository<History> {
  static final HistoryRepository _instance = HistoryRepository();

  static HistoryRepository get instance => _instance;
}