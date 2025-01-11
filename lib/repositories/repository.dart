import 'package:stream_it/models/model.dart';

/// Classe de base pour tous les repository,
/// definissant ainsi les differentes operations de base (CRUD).
abstract class Repository<T extends Model> {
  /// Methode pour l'ajout ou la creation d'un
  /// objet a la base de donnees pour ce model
  Future<T> create(T item);

  /// Methode pour la lecture d'un objet de la base de
  /// donnees par [(ID ou objet)] pour ce model
  Future<T?> getById(dynamic item);

  /// Methode pour la lecture de tous les objets de la base de
  /// donnees pour ce model
  Future<List<T>> getAll();

  /// Methode pour la modification d'un objet existant dans
  /// a la base de donnees pour ce model
  Future<T> update(T item);

  /// Methode pour la suppression d'un objet de la base de
  /// donnees par [(ID ou objet)] pour ce model
  Future<void> delete(dynamic item);

  /// Methode pour la recherche par filtre des objets de la base de
  /// donnees pour ce model
  Future<List<T>> search(Map<String, dynamic> filters);
}
