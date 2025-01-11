import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Avatar extends Model {
  static get modelName {
    return "avatar";
  }

  static get modelFields {
    return ["id", "url"];
  }

  String _url;

  Avatar({
    super.id,
    required String url,
  }) : _url = url;

  String get url => _url;

  set url(String value) {
    if (_url != value) {
      _url = value;
      notifyListeners();
    }
  }

  @override
  Avatar copyWith({
    String? id,
    String? url,
  }) =>
      Avatar(
        id: id ?? this.id,
        url: url ?? _url,
      );

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet ("quelconque")
  factory Avatar.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return Avatar.fromJson(data);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory Avatar.fromFirebaseDocument(DocumentSnapshot document) {
    return Avatar.fromData(document.data()!);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document JSON au format texte
  factory Avatar.fromRawJson(String str) => Avatar.fromJson(json.decode(str));

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet JSON (Map\<String, dynamic\>)
  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        id: json["id"],
        url: json["url"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "url": _url,
      };
}
