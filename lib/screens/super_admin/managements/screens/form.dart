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
  final dynamic item;
  final String title;
  final Repository<T> repository;
  final Map<String, dynamic> fields = {};

  FormScreen(
      {super.key, this.item, required this.title, required this.repository});

  @override
  State<FormScreen<T>> createState() => _FormScreenState<T>();

  Widget buildFieldsContainer(BuildContext context);
}

class _FormScreenState<T extends Model> extends State<FormScreen<T>> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    var lowerTitle = widget.title.toLowerCase();
    var capitalTitle = widget.title.toCapitalCase();

    return Stack(children: [
      Scaffold(
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
                      key: _formKey,
                      child: widget.buildFieldsContainer(context)),
                  ElevatedButton(
                    onPressed: () => onSubmit(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent),
                    child: Text(widget.item != null ? 'Modifier' : 'Ajouter'),
                  ),
                ],
              ))),
      if (isLoading)
        const Center(
          child: CircularProgressIndicator(),
        ),
    ]);
  }

  void onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true); // Démarrer le chargement
      try {
        if (widget.item == null) {
          await widget.repository.create(widget.fields);
        } else {
          await widget.repository.update(widget.item.copyWith(widget.fields));
        }
        Navigator.pop(context);
      } catch (e) {
        print('Erreur Impossible de sauvegarder : $e');
      } finally {
        setState(() => isLoading = false); // Arrêter le chargement
      }
    }
  }
}
