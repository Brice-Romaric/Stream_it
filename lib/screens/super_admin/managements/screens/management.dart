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
  Future<List<Model>>? filteredItems;

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
    filteredItems =
        widget.repository.search(fields, limit: widget.maxItems, isAnd: false);
    setState(() {});
  }

  void getItems() {
    filteredItems = widget.repository.getAll(limit: widget.maxItems);
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
              child: FutureBuilder(
                  future: filteredItems,
                  builder: (context, snapshot) {
                    List<Widget> children;

                    if (snapshot.hasData) {
                      return ListView.separated(
                        itemCount: snapshot
                            .data!.length, // Replace with the number of users
                        itemBuilder: (context, index) {
                          var item = snapshot.data![index];
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
                                    .map((field) => Text("${item[field]}"))
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
                                            widget.title.substring(
                                                0, widget.title.length - 1),
                                            item); // <- item
                                      }));
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      widget.repository
                                          .delete(item)
                                          .then((data) {
                                        getItems();
                                      });
                                    },
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(
                          height: 16,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      children = <Widget>[
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      ];
                    } else {
                      children = const <Widget>[
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('En attente de resultat...'),
                        ),
                      ];
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: children,
                      ),
                    );
                  }),
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
