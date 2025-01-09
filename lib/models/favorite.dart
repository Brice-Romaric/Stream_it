import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Favorite extends Model {
  static get modelName {
    return "favorite";
  }

  static get modelFields {
    return [
      "id",
      "movie_id",
      "profile_id"
    ];
  }

  String _profileId;
  String _movieId;

  Favorite({
    super.id,
    required String profileId,
    required String movieId,
  }) : _movieId = movieId, _profileId = profileId;

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

  @override
  Favorite copyWith({
    String? id,
    String? profileId,
    String? movieId,
  }) =>
      Favorite(
        id: id ?? this.id,
        profileId: profileId ?? this._profileId,
        movieId: movieId ?? this._movieId,
      );

  factory Favorite.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return Favorite.fromJson(data);
  }

  factory Favorite.fromFirebaseDocument(DocumentSnapshot document) {
    return Favorite.fromData(document.data()!);
  }

  factory Favorite.fromRawJson(String str) => Favorite.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json["id"],
    profileId: json["profile_id"],
    movieId: json["movie_id"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "profile_id": _profileId,
    "movie_id": _movieId,
  };
}
