import 'package:flutter/material.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/repositories/repository.dart';
import 'package:stream_it/screens/super_admin/managements/screens/form.dart';

abstract class ManagementScreen<T extends Model> extends StatefulWidget {
  late final String title;
  late final Repository<T> repository;
  late final List<String> cardTitleFields;
  late final List<String> cardSubtitleFields;
  late final List<String> onSearchFields;
  late final int maxItems;

  ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();

  FormScreen buildFormScreen(BuildContext context, Repository<T> repository,
      String title, dynamic item);
}

class _ManagementScreenState extends State<ManagementScreen> {
  List<Model> filteredItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getItems();
  }

  void performSearchQuery(String query) {
    Map<String, String> fields = {};
    for (var field in widget.onSearchFields) {
      fields[field] = query;
    }
    widget.repository
        .search(fields, limit: widget.maxItems)
        .then((value) => setState(() {
              filteredItems = value;
            }));
  }

  void getItems() {
    widget.repository.getAll(limit: widget.maxItems).then((value) {
      if (mounted) {
        setState(() {
          filteredItems = value;
          isLoading = false;
          print("=========================================================");
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          print("=========================================================");
        });
      }
      showErrorDialog('Erreur lors de la récupération des données : $error');
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
                                return widget.buildFormScreen(
                                    context,
                                    widget.repository,
                                    widget.title
                                        .substring(0, widget.title.length - 1),
                                    item); // <- item
                              }));
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () {
                              widget.repository.delete(item).then((data) {
                                getItems();
                              });
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
            return widget.buildFormScreen(
                context,
                widget.repository,
                widget.title.substring(0, widget.title.length - 1),
                null); // <- null
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
