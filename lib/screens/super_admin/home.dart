import 'package:flutter/material.dart';

class SuperAdminPageHome extends StatefulWidget {
  const SuperAdminPageHome({super.key});

  @override
  State<SuperAdminPageHome> createState() => _SuperAdminPageHomeState();
}

class Wid extends StatefulWidget {
  const Wid({super.key});

  @override
  State<Wid> createState() => _WidState();
}

class _WidState extends State<Wid> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class _SuperAdminPageHomeState extends State<SuperAdminPageHome> {
  static Map<String, void Function(BuildContext)> managers = {
    "Gestion des utilisateurs": (context) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Wid();
      }));
    }
  };

  @override
  Widget build(BuildContext context) {
    var keys = managers.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Super Admin"),
        backgroundColor: Colors.purple,
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          child: ListView.builder(
              itemCount: managers.length,
              itemBuilder: (context, index) {
                var key = keys[index];
                return ElevatedButton(
                    onPressed: () {
                      managers[key]!(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white),
                    child: Text(key));
              })),
    );
  }
}
