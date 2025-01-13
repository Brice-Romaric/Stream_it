import 'package:flutter/material.dart';
import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/user.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';
import 'package:stream_it/screens/super_admin/managements/screens/management.dart';

import '../../../repositories/repository.dart';

class UserFormScreen extends FormScreen<User> {
  UserFormScreen(
      {super.key, super.item, required super.title, required super.repository});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: item?['email'],
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email est requis';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Entrez un email valide';
            }
            return null;
          },
          onSaved: (value) {
            fields['email'] = value;
          },
        )
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
