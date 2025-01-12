import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Model ou structure de base faisant office d'interface aux collections
/// presentes dans firebase firestore.
/// Ils emettent aussi des evenements lors de modification des champs.
abstract class Model extends Iterable<MapEntry<String, dynamic>> with ChangeNotifier {
  @override
  get iterator => toJson().entries.iterator;

  /// Attribut static pour acceder au nom de la collection
  /// firebase firestore correspondant a ce model
  static String get modelName {
    throw UnimplementedError();
  }

  /// Attribut static pour acceder aux champs de la collection
  /// firebase firestore correspondant a ce model
  static List<String> get modelFields {
    throw UnimplementedError();
  }

  String? _id;

  Model({String? id}): _id = id;

  /// Champ 'id' present dans toutes les collections
  /// firebase firestore et modifiable uniquement si aucune valeur
  /// n'est presente (null)
  String? get id => _id;

  operator [](String field) => toJson()[field];

  /// Champ 'id' present dans toutes les collections
  /// firebase firestore et modifiable uniquement si aucune valeur
  /// n'est presente (null)
  set id(String? id) {
    if (_id != null) {
      throw Exception("L'ID est déjà défini et ne peut pas être modifié.");
    }
    _id = id;
    notifyListeners();
  }

  /// Methode permettant de creer une nouvelle instance de ce model a partir
  /// des informations de l'objet appelant tout en ayant la possiblite de
  /// modifier les champs de notre choix
  Model copyWith({
    String? id
  });

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory Model.fromFirebaseDocument(DocumentSnapshot document) =>
      throw UnimplementedError();

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document JSON au format texte
  factory Model.fromRawJson(String str) => throw UnimplementedError();

  /// Conversion de cette instance en texte JSON
  String toRawJson() => json.encode(toJson());

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet JSON (Map\<String, dynamic\>)
  factory Model.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  /// Conversion de cette instance en objet JSON (Map\<String, dynamic\>)
  Map<String, dynamic> toJson();

  /// Conversion de cette instance en objet JSON (Map\<String, dynamic\>)
  /// comme 'toJson()' mais sans le champ 'id'
  Map<String, dynamic> toFirebaseFirestoreDocument() {
    var data = toJson();
    data.remove("id");
    return data;
  }

  @override
  String toString() {
    return toRawJson();
  }
}
