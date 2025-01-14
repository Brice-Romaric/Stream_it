import 'package:flutter/material.dart';

class History extends StatefulWidget {
  final profile_id;
  final profile_name;

  const History({super.key,this.profile_name,this.profile_id});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VOTRE HISTORIQUE ",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),) ,
        //backgroundColor: Colors.purple,
      ),
    );
  }
}
