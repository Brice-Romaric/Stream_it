import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Category extends Model {
  static get modelName {
    return "category";
  }

  static get modelFields {
    return ["id", "name"];
  }

  String _name;

  Category({
    super.id,
    required String name,
  }) : _name = name;

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
  /// partir d'un objet ("quelconque")
  factory Category.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return Category.fromJson(data);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory Category.fromFirebaseDocument(DocumentSnapshot document) {
    return Category.fromData(document.data()!);
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
