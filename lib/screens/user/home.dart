import 'package:flutter/material.dart';
import 'package:stream_it/models/profile.dart';
import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/profile.dart';
import 'package:stream_it/repositories/user.dart';


class UserPageHome extends StatefulWidget {
  const UserPageHome({super.key});

  @override
  State<UserPageHome> createState() => _UserPageHomeState();
}

class _UserPageHomeState extends State<UserPageHome> {
  List<User> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text("Vos profils") ,
         backgroundColor: Colors.purple,
       ),
      body:  Column(
        children: [
          ElevatedButton(onPressed: () => getUsers(), child: Text("Load users")),
          Text(users.isNotEmpty ? users[0].id! : ""),
        ]
      )
      );
  }

  getUsers() {
    UserRepository().getAll().then((data) {
      users = data;
    });
    // ProfileRepository().delete("C2lasKNTZaL0hKPXH05v");
  }
}
