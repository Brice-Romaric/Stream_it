import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Profile extends Model {
  static final bool isRegisteredModel = (() {
    Model.registerModel<Profile>(ModelInfo(modelFields: [
      "id",
      "user_id",
      "avatar_id",
      "name",
    ], callables: [
      Profile.new,
      Profile.fromFirebaseDocument,
      Profile.fromJson,
      Profile.fromRawJson
    ], relations: {
      "user": null,
      "avatar": null,
      "favorite": null,
      "history": null,
    }));
    return true;
  })();

  String _userId;
  String _avatarId;
  String _name;

  Profile({
    super.id,
    required String userId,
    required String avatarId,
    required String name,
  })  : _name = name,
        _avatarId = avatarId,
        _userId = userId,
        super(isRegisteredModel: Profile.isRegisteredModel);

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
    if (_userId != value) {
      _userId = value;
      notifyListeners();
    }
  }

  String get avatarId => _avatarId;

  set avatarId(String value) {
    if (_avatarId != value) {
      _avatarId = value;
      notifyListeners();
    }
  }

  String get name => _name;

  set name(String value) {
    if (_name != value) {
      _name = value;
      notifyListeners();
    }
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory Profile.fromFirebaseDocument(DocumentSnapshot document) {
    return Profile.fromJson(document.data()! as Map<String, dynamic>);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document JSON au format texte
  factory Profile.fromRawJson(String str) => Profile.fromJson(json.decode(str));

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet JSON (Map\<String, dynamic\>)
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
