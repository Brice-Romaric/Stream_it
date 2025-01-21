import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class History extends Model {
  static final bool isRegisteredModel = (() {
    Model.registerModel<History>(ModelInfo(modelFields: [
      "id",
      "movie_id",
      "profile_id",
      "datetime",
    ], callables: [
      History.new,
      History.fromFirebaseDocument,
      History.fromJson,
      History.fromRawJson
    ], relations: {
      "movie": null,
      "profile": null,
    }));
    return true;
  })();

  String _movieId;
  String _profileId;
  DateTime _datetime;

  History({
    super.id,
    required String movieId,
    required String profileId,
    required DateTime datetime,
  })  : _datetime = datetime,
        _profileId = profileId,
        _movieId = movieId,
        super(isRegisteredModel: History.isRegisteredModel);

  String get movieId => _movieId;

  set movieId(String value) {
    if (_movieId != value) {
      _movieId = value;
      notifyListeners();
    }
  }

  String get profileId => _profileId;

  set profileId(String value) {
    if (_profileId != value) {
      _profileId = value;
      notifyListeners();
    }
  }

  DateTime get datetime => _datetime;

  set datetime(DateTime value) {
    if (_datetime != value) {
      _datetime = value;
      notifyListeners();
    }
  }

  @override
  History copyWith({
    String? id,
    String? movieId,
    String? profileId,
    DateTime? datetime,
  }) =>
      History(
        id: id ?? this.id,
        movieId: movieId ?? _movieId,
        profileId: profileId ?? _profileId,
        datetime: datetime ?? _datetime,
      );

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory History.fromFirebaseDocument(DocumentSnapshot document) {
    return History.fromJson(document.data()! as Map<String, dynamic>);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document JSON au format texte
  factory History.fromRawJson(String str) => History.fromJson(json.decode(str));

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet JSON (Map\<String, dynamic\>)
  factory History.fromJson(Map<String, dynamic> json) => History(
        id: json["id"],
        movieId: json["movie_id"],
        profileId: json["profile_id"],
        datetime: DateTime.parse(json["datetime"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "movie_id": _movieId,
        "profile_id": _profileId,
        "datetime": _datetime.toIso8601String(),
      };
}
