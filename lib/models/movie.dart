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
      "category",
      "duration",
      "url",
      "cover_url",
      "views",
    ];
  }

  String _title;
  String _description;
  String _category;
  int _duration;
  String _url;
  String _coverUrl;
  int _views;

  Movie({
    super.id,
    required String title,
    required String description,
    required String category,
    required int duration,
    required String url,
    required String coverUrl,
    int views = 0,
  })  : _views = views,
        _coverUrl = coverUrl,
        _url = url,
        _duration = duration,
        _category = category,
        _description = description,
        _title = title;

  String get title => _title;

  set title(String value) {
    var temp = _title;
    _title = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get description => _description;

  set description(String value) {
    var temp = _description;
    _description = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get category => _category;

  set category(String value) {
    var temp = _category;
    _category = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  int get duration => _duration;

  set duration(int value) {
    var temp = _duration;
    _duration = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get url => _url;

  set url(String value) {
    var temp = _url;
    _url = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  String get coverUrl => _coverUrl;

  set coverUrl(String value) {
    var temp = _coverUrl;
    _coverUrl = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  int get views => _views;

  set views(int value) {
    var temp = _views;
    _views = value;
    if (temp != value) {
      notifyListeners();
    }
  }

  @override
  Movie copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? duration,
    String? url,
    String? coverUrl,
    int? views,
  }) =>
      Movie(
        id: id ?? this.id,
        title: title ?? this._title,
        description: description ?? this._description,
        category: category ?? this._category,
        duration: duration ?? this._duration,
        url: url ?? this._url,
        coverUrl: coverUrl ?? this._coverUrl,
        views: views ?? this._views,
      );

  factory Movie.fromData(dynamic data) {
    Map<String, dynamic> d = {};
    for (var field in modelFields) {
      d[field] = data[field];
    }
    return Movie.fromJson(data);
  }

  factory Movie.fromFirebaseDocument(DocumentSnapshot document) {
    return Movie.fromData(document.data()!);
  }

  factory Movie.fromRawJson(String str) => Movie.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        category: json["category"],
        duration: json["duration"],
        url: json["url"],
        coverUrl: json["cover_url"],
        views: json["views"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": _title,
        "description": _description,
        "category": _category,
        "duration": _duration,
        "url": _url,
        "cover_url": _coverUrl,
        "views": _views,
      };
}
