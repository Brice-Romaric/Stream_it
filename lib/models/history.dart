import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class History extends Model {
  static get modelName {
    return "history";
  }

  static get modelFields {
    return [
      "id",
      "movie_id",
      "profile_id",
      "datetime",
    ];
  }

  String _movieId;
  String _profileId;
  DateTime _datetime;

  History({
    super.id,
    required String movieId,
    required String profileId,
    required DateTime datetime,
  }) : _datetime = datetime, _profileId = profileId, _movieId = movieId;

  String get movieId => _movieId;

  set movieId(String value) {
    var temp = _movieId;
    _movieId = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get profileId => _profileId;

  set profileId(String value) {
    var temp = _profileId;
    _profileId = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  DateTime get datetime => _datetime;

  set datetime(DateTime value) {
    var temp = _datetime;
    _datetime = value;
    if (temp != value) {
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
        movieId: movieId ?? this._movieId,
        profileId: profileId ?? this._profileId,
        datetime: datetime ?? this._datetime,
      );

  factory History.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return History.fromJson(data);
  }

  factory History.fromFirebaseDocument(DocumentSnapshot document) {
    return History.fromData(document.data()!);
  }

  factory History.fromRawJson(String str) => History.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

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
