import 'package:flutter/material.dart';
import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/repositories/avatar.dart';
import 'package:stream_it/repositories/repository.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';
import 'package:stream_it/screens/super_admin/managements/screens/management.dart';
import 'package:stream_it/widgets/field.dart';

class AvatarFormScreen extends FormScreen<Avatar> {
  AvatarFormScreen(
      {super.key, super.item, required super.title, required super.repository});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return Column(
      children: [
        Field<String>(
          placeholder: "URL",
          required: true,
          initialValue: item?['url'],
          fields: fields,
          name: "url",
        ),
      ],
    );
  }
}

class AvatarManagementScreen extends ManagementScreen<Avatar> {
  AvatarManagementScreen({super.key}) {
    title = "Avatars";
    cardTitleFields = ["url"];
    cardSubtitleFields = [];
    onSearchFields = ["url"];
    repository = AvatarRepository.instance;
    maxItems = 50;
  }

  @override
  buildFormScreen(BuildContext context, Repository<Avatar> repository,
      String title, dynamic item) {
    return AvatarFormScreen(title: title, repository: repository, item: item);
  }
}
