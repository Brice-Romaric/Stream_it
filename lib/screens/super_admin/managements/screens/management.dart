import 'package:flutter/material.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/repositories/repository.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';

class ManagementScreen<T extends Model> extends StatefulWidget {
  final String title;
  final Repository<T> repository;
  final List<String> cardTitleFields;
  final List<String> cardSubtitleFields;
  final List<String> onSearchFields;
  final int maxItems;
  final FormScreen<T> form;

  const ManagementScreen(
      {super.key,
      required this.title,
      required this.repository,
      required this.cardTitleFields,
      required this.cardSubtitleFields,
      required this.onSearchFields,
      required this.maxItems,
      required this.form});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  List<Model> filteredItems = [];

  @override
  void initState() {
    super.initState();
    widget.repository
        .getAll(limit: widget.maxItems)
        .then((value) => filteredItems = value);
  }

  void performSearchQuery(String query) {
    Map<String, String> fields = {};
    for (var field in widget.onSearchFields) {
      fields[field] = query;
    }
    widget.repository
        .search(fields, limit: widget.maxItems)
        .then((value) => filteredItems = value);
  }

  @override
  Widget build(BuildContext context) {
    var lowerTitle = widget.title.toLowerCase();
    var capitalTitle = widget.title.toCapitalCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          capitalTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des $lowerTitle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onSubmitted: (value) {
                performSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Chercher des $lowerTitle...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount:
                    filteredItems.length, // Replace with the number of users
                itemBuilder: (context, index) {
                  var item = filteredItems[index];
                  var title = "";
                  for (var field in widget.cardTitleFields) {
                    title = "$title${item[field] ?? ''}";
                  }
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purpleAccent,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(title),
                      subtitle: Column(
                        children: widget.cardSubtitleFields
                            .map((field) => Row(
                                  children: [
                                    Text("${field.snakeToCapitalCase()} : "),
                                    Text("${item[field]}")
                                  ],
                                ))
                            .toList(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return widget.form; // <- item
                              }));
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () {
                              // Handle delete user
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                  height: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return widget.form; // <- null
          }));
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
