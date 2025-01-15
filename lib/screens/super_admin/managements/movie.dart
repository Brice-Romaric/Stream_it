import 'package:flutter/material.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/movie.dart';
import 'package:stream_it/repositories/category.dart';
import 'package:stream_it/repositories/movie.dart';
import 'package:stream_it/repositories/repository.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';
import 'package:stream_it/screens/super_admin/managements/screens/management.dart';
import 'package:stream_it/widgets/field.dart';

class MovieFormScreen extends FormScreen<Movie> {
  MovieFormScreen(
      {super.key, super.item, required super.title, required super.repository});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return FutureBuilder<List<Category>>(
        future: CategoryRepository.instance.getAll(),
        builder: (context, snapshot) {
          List<Widget> children;

          if (snapshot.hasData) {
            return Column(
              children: [
                Field<String>(
                  placeholder: "Titre",
                  required: true,
                  initialValue: item?['title'],
                  fields: fields,
                  name: "title",
                ),
                Field<String>(
                  placeholder: "Description",
                  required: true,
                  initialValue: item?['description'],
                  fields: fields,
                  name: "description",
                ),
                Field<int>(
                  placeholder: "Durée",
                  type: "number",
                  required: true,
                  initialValue: item?['duration'],
                  fields: fields,
                  name: "duration",
                ),
                Field<String>(
                  placeholder: "URL",
                  required: true,
                  initialValue: item?['url'],
                  fields: fields,
                  name: "url",
                ),
                Field<String>(
                  placeholder: "Image de l'affiche",
                  required: true,
                  initialValue: item?['cover_url'],
                  fields: fields,
                  name: "cover_url",
                ), /*
                Field<List<String>>(
                  selectMultiple: true,
                  type: "select",
                  placeholder: "Catégorie",
                  required: true,
                  initialValue: item?['category'],
                  fields: fields,
                  name: "category",
                  selectOptions: snapshot.data,
                  selectLabelField: "name",
                ),*/
              ],
            );
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${(snapshot.error as Error).stackTrace}'),
              ),
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('En attente de resultat...'),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        });
  }
}

class MovieManagementScreen extends ManagementScreen<Movie> {
  MovieManagementScreen({super.key}) {
    title = "Films";
    cardTitleFields = ["title"];
    cardSubtitleFields = ["description"];
    onSearchFields = ["title", "description"];
    repository = MovieRepository.instance;
    maxItems = 50;
  }

  @override
  buildFormScreen(BuildContext context, Repository<Movie> repository,
      String title, dynamic item) {
    return MovieFormScreen(title: title, repository: repository, item: item);
  }
}
