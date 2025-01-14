import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/firebase_firestore.dart';

class CategoryRepository extends FirebaseFirestoreRepository<Category> {
  CategoryRepository() {
    fromFirestoreMap[Category] =
        (data, id) => Category.fromJson({...data, "id": id});
    fromFirestoreMap[Movie] = (data, id) => Movie.fromJson({...data, "id": id});
  }

  static final CategoryRepository _instance = CategoryRepository();

  static get instance => _instance;
}
