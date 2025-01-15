import 'package:flutter/material.dart';
import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/repository.dart';

extension StringExtension on String {
  String toCapitalCase() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String snakeToCapitalCase() {
    return split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

abstract class FormScreen<T extends Model> extends StatefulWidget {
  final T? item;
  final String title;
  final Repository<T> repository;
  final Map<String, dynamic> fields = {};

  final Map<Type, dynamic> fromJson = {
    User: User.fromJson,
    Movie: Movie.fromJson,
    Category: Category.fromJson,
    Avatar: Avatar.fromJson
  };

  FormScreen(
      {super.key, this.item, required this.title, required this.repository});

  @override
  State<FormScreen<T>> createState() => _FormScreenState<T>();

  Widget buildFieldsContainer(BuildContext context);

  void onSubmit(BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        if (item == null) {
          await repository.create(fromJson[T]!(fields));
        } else {
          await repository.update({...item!.toJson(), ...fromJson[T]!(fields)});
        }
        Navigator.pop(context, true);
      } catch (e) {
        print('Erreur Impossible de sauvegarder : $e');
      } finally {}
    }
  }
}

class _FormScreenState<T extends Model> extends State<FormScreen<T>> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var lowerTitle = widget.title.toLowerCase();
    var capitalTitle = widget.title.toCapitalCase();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "${capitalTitle}s",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  "${widget.item != null ? 'Modifier' : 'Ajouter'} ${lowerTitle == 'categorie' ? 'une' : 'un'} $lowerTitle",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                    key: _formKey, child: widget.buildFieldsContainer(context)),
                ElevatedButton(
                  onPressed: () => widget.onSubmit(context, _formKey),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent),
                  child: Text(widget.item != null ? 'Modifier' : 'Ajouter'),
                ),
              ],
            )));
  }
}
