import 'package:flutter/material.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/user.dart';
import 'package:stream_it/screens/super_admin/managements/screens/details.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';
import 'package:stream_it/screens/super_admin/managements/screens/management.dart';
import 'package:stream_it/widgets/field.dart';

class UserFormScreen extends FormScreen<User> {
  UserFormScreen(
      {super.key, super.item, required super.title, required super.repository});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return Column(
      children: [
        Field<String>(
          placeholder: "Nom",
          required: true,
          initialValue: item?['last_name'],
          name: "last_name",
          onSave: onSave,
        ),
        Field<String>(
          placeholder: "Prénom",
          required: true,
          initialValue: item?['first_name'],
          name: "first_name",
          onSave: onSave,
        ),
        Field<String>(
          placeholder: "Email",
          type: "email",
          required: true,
          initialValue: item?['email'],
          name: "email",
          onSave: onSave,
        ),
        Field<String>(
          type: "select",
          placeholder: "Rôle",
          required: true,
          initialValue: item?['role'],
          name: "role",
          selectOptions: ["user", "super_admin"],
          onSave: onSave,
        ),
      ],
    );
  }
}

class UserDetailsScreen extends DetailsScreen<User> {
  const UserDetailsScreen(
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
          Text(item.lastName)
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Prénom : ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(item.firstName)
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Email : ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(item.email)
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Rôle : ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(item.role)
        ],
      ),
    ]);
  }
}

class UserManagementScreen extends ManagementScreen<User> {
  UserManagementScreen({super.key}) {
    title = "Utilisateurs";
    cardTitleFields = ["first_name", "last_name"];
    cardSubtitleFields = ["email"];
    onSearchFields = Model.modelInfoOf<User>()?.fields ?? [];
    repository = UserRepository.instance;
    maxItems = 50;
    leading = Icons.person;
    image = null;
  }

  @override
  buildFormScreen(BuildContext context, String title, dynamic item) {
    return UserFormScreen(title: title, repository: repository, item: item);
  }

  @override
  DetailsScreen<Model> buildDetailsScreen(
      BuildContext context, String title, item) {
    return UserDetailsScreen(title: title, item: item);
  }
}
