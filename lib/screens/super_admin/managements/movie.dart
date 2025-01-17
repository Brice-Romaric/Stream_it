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
          var all = snapshot.data;

          if (snapshot.hasData) {
            return Column(
              children: [
                Field<String>(
                  placeholder: "Titre",
                  required: true,
                  initialValue: item?['title'],
                  onSave: onSave,
                  name: "title",
                ),
                Field<String>(
                  placeholder: "Description",
                  required: true,
                  initialValue: item?['description'],
                  onSave: onSave,
                  name: "description",
                ),
                Field<int>(
                  placeholder: "Durée",
                  type: "number",
                  required: true,
                  initialValue: item?['duration'],
                  onSave: onSave,
                  name: "duration",
                ),
                Field<String>(
                  placeholder: "URL",
                  required: true,
                  initialValue: item?['url'],
                  onSave: onSave,
                  name: "url",
                ),
                Field<String>(
                  placeholder: "Image de l'affiche",
                  required: true,
                  initialValue: item?['cover_url'],
                  onSave: onSave,
                  name: "cover_url",
                ),
                FutureBuilder<List<Category>>(
                    future: item != null
                        ? MovieRepository.instance
                            .getManyMany<Category>(item, "movie_categories")
                        : Future<List<Category>>.value([]),
                    builder: (context, snapshot) {
                      List<Widget> children;
                      if (snapshot.hasData) {
                        return Field<Category>(
                          onSave: onSave,
                          selectMultiple: true,
                          initialValue: snapshot.data,
                          type: "select",
                          placeholder: "Catégorie",
                          required: true,
                          name: "category",
                          selectOptions: all,
                          selectLabelField: "name",
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
                            child: Text(
                                'Error: ${(snapshot.error as Error).stackTrace}'),
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
                    }),
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
