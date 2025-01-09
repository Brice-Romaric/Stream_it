import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Category extends Model {
  static get modelName {
    return "category";
  }

  static get modelFields {
    return [
      "id",
      "name"
    ];
  }

  String _name;

  Category({
    super.id,
    required String name,
  }) : _name = name;

  String get name => _name;

  set name(String value) {
    var temp = _name;
    _name = value;
    if (temp != value) {
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
        name: name ?? this._name,
      );

  factory Category.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return Category.fromJson(data);
  }

  factory Category.fromFirebaseDocument(DocumentSnapshot document) {
    return Category.fromData(document.data()!);
  }

  factory Category.fromRawJson(String str) => Category.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

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
