import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Category extends Model {
  static final bool isRegisteredModel = (() {
    Model.registerModel<Category>(ModelInfo(modelFields: [
      "id",
      "name"
    ], callables: [
      Category.new,
      Category.fromFirebaseDocument,
      Category.fromJson,
      Category.fromRawJson
    ], relations: {
      "movie": "movie_categories"
    }));
    return true;
  })();

  String _name;

  Category({
    super.id,
    required String name,
  })  : _name = name,
        super(isRegisteredModel: Category.isRegisteredModel);

  String get name => _name;

  set name(String value) {
    if (_name != value) {
      _name = value;
      notifyListeners();
    }
  }

  @override
  Category copyWith({
    String? id,
    String? name,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? _name,
      );

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory Category.fromFirebaseDocument(DocumentSnapshot document) {
    return Category.fromJson(document.data()! as Map<String, dynamic>);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document JSON au format texte
  factory Category.fromRawJson(String str) =>
      Category.fromJson(json.decode(str));

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet JSON (Map\<String, dynamic\>)
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": _name,
      };
}
