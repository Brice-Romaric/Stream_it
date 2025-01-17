import 'dart:convert';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/favorite.dart';
import 'package:stream_it/models/history.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/models/profile.dart';
import 'package:stream_it/models/user.dart';

class Callable {
  late final String name;
  final dynamic object;

  static final RegExp _mainPattern = RegExp(
      r"(((from: function|from:) ((\w+)|\['_#(\w+)#tearOff'\]))|(from Function '(.+)'))");
  static final RegExp _functionPattern = RegExp(r"from: function (\w+)");
  static final RegExp _methodPattern = RegExp(r"from: (\w+)");
  static final RegExp _constructorPattern =
      RegExp(r"from: \['_#(\w+)#tearOff'\]");

  Callable(this.object) {
    name = getName(object);
  }

  bool get isFunction {
    return _functionPattern.firstMatch(object.toString())?.group(1) != null;
  }

  bool get isMethod {
    return _methodPattern.firstMatch(object.toString())?.group(1) != null;
  }

  bool get isConstructor {
    return _constructorPattern.firstMatch(object.toString())?.group(1) != null;
  }

  static String getName(dynamic object) {
    if (object != null && object.runtimeType.toString().startsWith('(')) {
      final match = _mainPattern.firstMatch(object.toString());
      return match?.group(8) ?? match?.group(5) ?? match?.group(6) ?? 'Unknown';
    } else {
      return object != null ? object.runtimeType.toString() : 'null';
    }
  }
}

class ModelInfo<T extends Model> {
  late String _name;
  late String _collectionName;
  late List<String> _modelFields;
  late Map<String, Callable> _callables;
  late Map<String, String?> _relations;

  ModelInfo(
      {String? name,
      String? collectionName,
      List<String>? modelFields,
      List<dynamic>? callables,
      Map<String, String?>? relations}) {
    this._name = name ?? T.toString();
    this._collectionName = collectionName ?? modelToCollectionName<T>();
    modelFields ??= ["id"];
    if (!modelFields.contains("id")) modelFields.add("id");
    this._modelFields = List<String>.unmodifiable(modelFields);
    Map<String, dynamic> c = {};
    if (callables != null) {
      for (var callable in callables) {
        c[Callable.getName(callable)] = Callable(callable);
      }
    }
    this._callables = Map<String, Callable>.unmodifiable(c);
    this._relations = Map<String, String>.unmodifiable(relations ?? {});
  }

  Type get type => T;

  String get name => _name;

  String get collectionName => _collectionName;

  List<String> get modelFields => _modelFields;

  Map<String, dynamic> get callables => _callables;

  Map<String, String?> get relations => _relations;

  dynamic getCallable(String name) {
    if (name == "new" || name == "$T.new" || name.isEmpty) {
      return callables["$T."]?.object;
    }
    return callables[name.contains(".") ? name : "$T.$name"]?.object;
  }

  static String modelToCollectionName<T>([Type? type]) {
    return (type ?? T)
        .toString()
        .replaceAllMapped(
          RegExp(r'(?<!^)([A-Z])'),
          (Match match) => '_${match.group(1)!}',
        )
        .toLowerCase();
  }

  static String collectionNameToModelName(String name) {
    return name.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (Match m) {
      return '${m[1]}_${m[2]}';
    }).toLowerCase();
  }
}

/// Model ou structure de base faisant office d'interface aux collections
/// presentes dans firebase firestore.
/// Ils emettent aussi des evenements lors de modification des champs.
abstract class Model extends Iterable<MapEntry<String, dynamic>>
    with ChangeNotifier {
  @override
  get iterator => toJson().entries.iterator;

  static final Map<Type, ModelInfo> models = {};

  static void registerModel<T extends Model>(ModelInfo<T> modelInfo) {
    Model.models[T] = modelInfo;
  }

  static ModelInfo<T>? modelInfoOf<T extends Model>([dynamic type]) {
    var t = type ?? T;
    ModelInfo<T>? m;
    if (t is String) {
      m = models[models.keys.firstWhere((key) => key.toString() == t,
          orElse: () => Model)] as ModelInfo<T>?;
    }
    return m ?? models[t] as ModelInfo<T>?;
  }

  static List<String> get modelsNameList =>
      models.keys.map((key) => key.toString()).toList();

  final Map<String, dynamic> _relationData = {};

  String? _id;

  Model({String? id, bool isRegisteredModel = false}) {
    _id = id;
  }

  /// Champ 'id' present dans toutes les collections
  /// firebase firestore et modifiable uniquement si aucune valeur
  /// n'est presente (null)
  String? get id => _id;

  dynamic operator [](String field) {
    var json = toJson();
    if (json.containsKey(field)) {
      return json[field];
    } else {
      return _relationData[field];
    }
  }

  void operator []=(String field, dynamic value) {
    _relationData[field] = value;
  }

  @override
  bool operator ==(Object other) {
    if (other is String) {
      return other == _id;
    } else if (other is Model) {
      return other.id == id;
    }
    return false;
  }

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
  Model copyWith({String? id});

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

loadModels() {
  User.isRegisteredModel;
  Profile.isRegisteredModel;
  Category.isRegisteredModel;
  Movie.isRegisteredModel;
  Avatar.isRegisteredModel;
  History.isRegisteredModel;
  Favorite.isRegisteredModel;
}
