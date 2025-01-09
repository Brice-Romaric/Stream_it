import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class User extends Model {
  static get modelName {
    return "user";
  }

  static get modelFields {
    return [
      "id",
      "first_name",
      "last_name",
      "email",
      "role"
    ];
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
  }) : _firstName = firstName, _lastName = lastName, _email = email, _role = role;

  String get firstName => _firstName;

  set firstName(String value) {
    var temp = _firstName;
    _firstName = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get lastName => _lastName;

  set lastName(String value) {
    var temp = _lastName;
    _lastName = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get email => _email;

  set email(String value) {
    var temp = _email;
    _email = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get role => _role;

  set role(String value) {
    var temp = _role;
    _role = value;
    if (temp != value) {
      notifyListeners();
    }
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

  factory User.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return User.fromJson(data);
  }

  factory User.fromFirebaseDocument(DocumentSnapshot document) {
    return User.fromData(document.data()!);
  }

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

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
