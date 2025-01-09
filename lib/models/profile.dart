import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Profile extends Model {
  static get modelName {
    return "profile";
  }

  static get modelFields {
    return [
      "id",
      "user_id",
      "avatar_id",
      "name",
    ];
  }

  String _userId;
  String _avatarId;
  String _name;

  Profile({
    super.id,
    required String userId,
    required String avatarId,
    required String name,
  }) : _name = name, _avatarId = avatarId, _userId = userId;

  @override
  Profile copyWith({
    String? id,
    String? userId,
    String? avatarId,
    String? name,
  }) =>
      Profile(
        id: id ?? this.id,
        userId: userId ?? _userId,
        avatarId: avatarId ?? _avatarId,
        name: name ?? _name,
      );

  String get userId => _userId;

  set userId(String value) {
    var temp = _userId;
    _userId = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get avatarId => _avatarId;

  set avatarId(String value) {
    var temp = _avatarId;
    _avatarId = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get name => _name;

  set name(String value) {
    var temp = _name;
    _name = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  factory Profile.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return Profile.fromJson(data);
  }

  factory Profile.fromFirebaseDocument(DocumentSnapshot document) {
    return Profile.fromData(document.data()!);
  }

  factory Profile.fromRawJson(String str) => Profile.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json["id"],
    userId: json["user_id"],
    avatarId: json["avatar_id"],
    name: json["name"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": _userId,
    "avatar_id": _avatarId,
    "name": _name,
  };
}
