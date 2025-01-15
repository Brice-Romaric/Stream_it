import 'package:stream_it/models/category.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class CategoryRepository extends FirebaseFirestoreRepository<Category> {
  static final CategoryRepository _instance = CategoryRepository();

  static get instance => _instance;
}
