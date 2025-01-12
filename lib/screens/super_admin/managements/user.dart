import 'package:flutter/material.dart';
import 'package:stream_it/models/user.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';

class UserFormScreen extends FormScreen<User> {
  UserFormScreen({super.key, required super.title, required super.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

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

