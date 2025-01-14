import 'package:flutter/material.dart';
import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/user.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';
import 'package:stream_it/screens/super_admin/managements/screens/management.dart';
import 'package:stream_it/widgets/fields/field.dart';

import '../../../repositories/repository.dart';

class UserFormScreen extends FormScreen<User> {
  UserFormScreen(
      {super.key, super.item, required super.title, required super.repository});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return Column(
      children: [
        Field(
          placeholder: "Nom",
          required: true,
          initialValue: item?['last_name'],
          fields: fields,
          name: "last_name",
        ),
        Field(
          placeholder: "Prénom",
          required: true,
          initialValue: item?['first_name'],
          fields: fields,
          name: "first_name",
        ),
        Field(
          placeholder: "Email",
          type: "email",
          required: true,
          initialValue: item?['email'],
          fields: fields,
          name: "email",
        ),
        Field(
          type: "select",
          placeholder: "Rôle",
          required: true,
          initialValue: item?['role'],
          fields: fields,
          name: "role",
          selectOptions: ["user", "super_admin"],
        ),
      ],
    );
  }
}

class UserManagementScreen extends ManagementScreen<User> {
  UserManagementScreen({super.key}) {
    title = "Utilisateurs";
    cardTitleFields = ["first_name", "last_name"];
    cardSubtitleFields = ["email"];
    onSearchFields = User.modelFields;
    repository = UserRepository.instance;
    maxItems = 50;
  }

  @override
  buildFormScreen(BuildContext context, Repository<User> repository,
      String title, dynamic item) {
    return UserFormScreen(title: title, repository: repository, item: item);
  }
}
