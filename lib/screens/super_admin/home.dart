import 'package:flutter/material.dart';

class SuperAdminPageHome extends StatefulWidget {
  const SuperAdminPageHome({super.key});

  @override
  State<SuperAdminPageHome> createState() => _SuperAdminPageHomeState();
}

class _SuperAdminPageHomeState extends State<SuperAdminPageHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vos profils") ,
        backgroundColor: Colors.purple,
      ),
    );
  }
}
