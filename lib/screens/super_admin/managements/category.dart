import 'package:flutter/material.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/repositories/category.dart';
import 'package:stream_it/screens/super_admin/managements/screens/details.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';
import 'package:stream_it/screens/super_admin/managements/screens/management.dart';
import 'package:stream_it/widgets/field.dart';

class CategoryFormScreen extends FormScreen<Category> {
  CategoryFormScreen(
      {super.key, super.item, required super.title, required super.repository});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return Column(
      children: [
        Field<String>(
          placeholder: "Nom",
          required: true,
          initialValue: item?['name'],
          onSave: onSave,
          name: "name",
        ),
      ],
    );
  }
}

class CategoryDetailsScreen extends DetailsScreen<Category> {
  const CategoryDetailsScreen(
      {super.key, required super.title, required super.item});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Nom : ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(item.name)
        ],
      ),
    ]);
  }
}

class CategoryManagementScreen extends ManagementScreen<Category> {
  CategoryManagementScreen({super.key}) {
    title = "Catégories";
    cardTitleFields = ["name"];
    cardSubtitleFields = [];
    onSearchFields = ["name"];
    repository = CategoryRepository.instance;
    maxItems = 50;
    leading = Icons.category;
    image = null;
  }

  @override
  buildFormScreen(BuildContext context, String title, dynamic item) {
    return CategoryFormScreen(title: title, repository: repository, item: item);
  }

  @override
  DetailsScreen<Model> buildDetailsScreen(
      BuildContext context, String title, item) {
    return CategoryDetailsScreen(title: title, item: item);
  }
}
