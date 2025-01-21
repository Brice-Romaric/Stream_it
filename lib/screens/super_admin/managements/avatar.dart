import 'package:flutter/material.dart';
import 'package:stream_it/models/avatar.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/repositories/avatar.dart';
import 'package:stream_it/screens/super_admin/managements/screens/details.dart';
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
          onSave: onSave,
          name: "url",
        ),
      ],
    );
  }
}

class AvatarDetailsScreen extends DetailsScreen<Avatar> {
  const AvatarDetailsScreen(
      {super.key, required super.title, required super.item});

  @override
  Widget buildFieldsContainer(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          item.url,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class AvatarManagementScreen extends ManagementScreen<Avatar> {
  AvatarManagementScreen({super.key}) {
    title = "Avatars";
    cardTitleFields = [];
    cardSubtitleFields = [];
    onSearchFields = ["url"];
    repository = AvatarRepository.instance;
    maxItems = 50;
    leading = Icons.image;
    image = "url";
  }

  @override
  buildFormScreen(BuildContext context, String title, dynamic item) {
    return AvatarFormScreen(title: title, repository: repository, item: item);
  }

  @override
  DetailsScreen<Model> buildDetailsScreen(
      BuildContext context, String title, item) {
    return AvatarDetailsScreen(title: title, item: item);
  }
}
