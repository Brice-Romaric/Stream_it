import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class Model extends ChangeNotifier {
  static String get modelName {
    throw UnimplementedError();
  }

  static List<String> get modelFields {
    throw UnimplementedError();
  }

  String get itemModelName {
    return runtimeType.toString().toLowerCase();
  }

  String? _id;

  Model({String? id}): _id = id;

  String? get id => _id;

  set id(String? id) {
    if (_id != null) {
      throw Exception("ID is already set and cannot be modified.");
    }
    _id = id;
    notifyListeners();
  }

  Model copyWith({
    String? id
  });

  factory Model.fromData(dynamic data) => throw UnimplementedError();

  factory Model.fromFirebaseDocument(DocumentSnapshot document) =>
      throw UnimplementedError();

  factory Model.fromRawJson(String str) => throw UnimplementedError();

  String toRawJson() => json.encode(toJson());

  factory Model.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson();

  Map<String, dynamic> toFirebaseDocument() {
    var data = toJson();
    data.remove("id");
    return data;
  }

  @override
  String toString() {
    return toRawJson();
  }
}
