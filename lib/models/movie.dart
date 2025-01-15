import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_it/models/model.dart';

class Movie extends Model {
  static get modelName {
    return "movie";
  }

  static get modelFields {
    return [
      "id",
      "title",
      "description",
      "duration",
      "url",
      "cover_url",
      "views",
    ];
  }

  String _title;
  String _description;
  int _duration;
  String _url;
  String _coverUrl;
  int _views;

  Movie({
    super.id,
    required String title,
    required String description,
    required int duration,
    required String url,
    required String coverUrl,
    int views = 0,
  })  : _views = views,
        _coverUrl = coverUrl,
        _url = url,
        _duration = duration,
        _description = description,
        _title = title;

  String get title => _title;

  set title(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  String get description => _description;

  set description(String value) {
    if (_description != value) {
      _description = value;
      notifyListeners();
    }
  }

  int get duration => _duration;

  set duration(int value) {
    if (_duration != value) {
      _duration = value;
      notifyListeners();
    }
  }

  String get url => _url;

  set url(String value) {
    if (_url != value) {
      _url = value;
      notifyListeners();
    }
  }

  String get coverUrl => _coverUrl;

  set coverUrl(String value) {
    if (_coverUrl != value) {
      _coverUrl = value;
      notifyListeners();
    }
  }

  int get views => _views;

  set views(int value) {
    if (_views != value) {
      _views = value;
      notifyListeners();
    }
  }

  @override
  Movie copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    String? url,
    String? coverUrl,
    int? views,
  }) =>
      Movie(
        id: id ?? this.id,
        title: title ?? _title,
        description: description ?? _description,
        duration: duration ?? _duration,
        url: url ?? _url,
        coverUrl: coverUrl ?? _coverUrl,
        views: views ?? _views,
      );

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document de type DocumentSnapshot de firebase
  factory Movie.fromFirebaseDocument(DocumentSnapshot document) {
    return Movie.fromJson(document.data()! as Map<String, dynamic>);
  }

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un document JSON au format texte
  factory Movie.fromRawJson(String str) => Movie.fromJson(json.decode(str));

  /// Contructeur permettant de creer une instance de ce model a
  /// partir d'un objet JSON (Map\<String, dynamic\>)
  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        duration: json["duration"],
        url: json["url"],
        coverUrl: json["cover_url"],
        views: json["views"] ?? 0,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": _title,
        "description": _description,
        "duration": _duration,
        "url": _url,
        "cover_url": _coverUrl,
        "views": _views,
      };
}
