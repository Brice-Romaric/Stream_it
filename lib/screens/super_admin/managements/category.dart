import 'package:flutter/material.dart';
import 'package:stream_it/models/category.dart';
import 'package:stream_it/repositories/category.dart';
import 'package:stream_it/repositories/repository.dart';
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

class CategoryManagementScreen extends ManagementScreen<Category> {
  CategoryManagementScreen({super.key}) {
    title = "Catégories";
    cardTitleFields = ["name"];
    cardSubtitleFields = [];
    onSearchFields = ["name"];
    repository = CategoryRepository.instance;
    maxItems = 50;
  }

  @override
  buildFormScreen(BuildContext context, Repository<Category> repository,
      String title, dynamic item) {
    return CategoryFormScreen(title: title, repository: repository, item: item);
  }
}
