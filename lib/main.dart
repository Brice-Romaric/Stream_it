import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stream_it/Connexion.dart';
import 'package:stream_it/Inscription.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
          appBarTheme: AppBarTheme(color: Colors.purpleAccent,
            titleTextStyle: TextStyle(color: Colors.white)
          ),
      ),
      home: MonScaffold(),
    );
  }
}

class MonScaffold extends StatefulWidget {
  const MonScaffold({super.key});

  @override
  State<MonScaffold> createState() => _MonScaffoldState();
}

class _MonScaffoldState extends State<MonScaffold> {

  var _number=0;

  setNumber(int number){
    setState(() {
      _number=number;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: [
          Text("Connexion"),
          Text("Inscription"),
          ][_number],
      ),
      body: [
        Connexion(),
        Inscription(),
      ][_number] ,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _number ,
         selectedItemColor: Colors.red,
          unselectedItemColor: Colors.brown,
          iconSize: 32,
          backgroundColor: Colors.purple[200],
          onTap: (index){
            setNumber(index);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.accessibility_new_sharp),
                label: 'Connexion'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.accessibility_new_sharp),
                label: 'Inscription'
            ),
          ]

      ),
    );
  }
}

