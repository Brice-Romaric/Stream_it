import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class User extends Model {
  static get modelName {
    return "user";
  }

  static get modelFields {
    return ["id", "first_name", "last_name", "email", "role"];
  }

  String _firstName;
  String _lastName;
  String _email;
  String _role;

  User({
    super.id,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  })  : _firstName = firstName,
        _lastName = lastName,
        _email = email,
        _role = role;

  String get firstName => _firstName;

  set firstName(String value) {
    if (_firstName != value) {
      _firstName = value;
      notifyListeners();
    }
  }

  String get lastName => _lastName;

  set lastName(String value) {
    if (_lastName != value) {
      _lastName = value;
      notifyListeners();
    }
  }

  String get email => _email;

  set email(String value) {
    if (_email != value) {
      _email = value;
      notifyListeners();
    }
  }

  String get role => _role;

  set role(String value) {
    if (_role != value) {
      _role = value;
      notifyListeners();
    }
  }

  get fullName {
    return "$firstName $lastName";
  }

  @override
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
  }) =>
      User(
        id: id ?? this.id,
        firstName: firstName ?? _firstName,
        lastName: lastName ?? _lastName,
        email: email ?? _email,
        role: role ?? _role,
      );

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory User.fromFirebaseDocument(DocumentSnapshot document) {
    return User.fromJson(document.data()! as Map<String, dynamic>);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document JSON au format texte
  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet JSON (Map\<String, dynamic\>)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      email: json["email"],
      role: json["role"],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": _firstName,
        "last_name": _lastName,
        "email": _email,
        "role": _role,
      };
}
