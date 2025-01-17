import 'package:flutter/material.dart';
import 'package:stream_it/models/model.dart';
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
  final List controllers = [];

  FormScreen(
      {super.key, this.item, required this.title, required this.repository});

  @override
  State<FormScreen<T>> createState() => _FormScreenState<T>();

  Widget buildFieldsContainer(BuildContext context);

  void onSave(String? name, dynamic value) {
    if (name != null) {
      fields[name] = value;
    }
  }

  void onSubmit(BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        var modelInfo = Model.modelInfoOf<T>()!;
        Function fromJson = modelInfo.getCallable("fromJson");
        if (item == null) {
          T i = await repository.create(fromJson(fields));
          for (var entry in fields.entries) {
            if (!modelInfo.modelFields.contains(entry.key)) {
              var tableName = ModelInfo.collectionNameToModelName(entry.key);
              if (entry.value is List) {
                var relationName = modelInfo.relations[tableName];
                if (relationName != null) {
                  await repository.addManyMany(i, relationName,
                      tableName: tableName, others: entry.value);
                } else {
                  await repository.addMany(i,
                      tableName: tableName, others: entry.value);
                }
              } else {
                await repository.setOne(i, entry.value, tableName: tableName);
              }
            }
          }
        } else {
          T i = await repository.update(fromJson({...fields, "id": item!.id}));
          for (var entry in fields.entries) {
            if (!modelInfo.modelFields.contains(entry.key)) {
              var tableName = ModelInfo.collectionNameToModelName(entry.key);
              if (entry.value is List) {
                var relationName = modelInfo.relations[tableName];
                if (relationName != null) {
                  await repository.removeManyMany(i, relationName,
                      tableName: tableName, all: true);
                  await repository.addManyMany(i, relationName,
                      tableName: tableName, others: entry.value);
                } else {
                  await repository.removeMany(i,
                      tableName: tableName, all: true);
                  await repository.addMany(i,
                      tableName: tableName, others: entry.value);
                }
              } else {
                await repository.setOne(i, entry.value, tableName: tableName);
              }
            }
          }
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
