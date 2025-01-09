import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Avatar extends Model {
  static get modelName {
    return "avatar";
  }

  static get modelFields {
    return [
      "id",
      "url"
    ];
  }

  String _url;

  Avatar({
    super.id,
    required String url,
  }) : _url = url;

  String get url => _url;

  set url(String value) {
    var temp = _url;
    _url = value;
    if (temp != value) {
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
        url: url ?? this._url,
      );

  factory Avatar.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return Avatar.fromJson(data);
  }

  factory Avatar.fromFirebaseDocument(DocumentSnapshot document) {
    return Avatar.fromData(document.data()!);
  }

  factory Avatar.fromRawJson(String str) => Avatar.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

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
