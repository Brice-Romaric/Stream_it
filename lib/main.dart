import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_it/models/model.dart';
import 'package:stream_it/providers/user.dart';
import 'package:stream_it/screens/account/login.dart';
import 'package:stream_it/screens/account/signup.dart';
import 'package:stream_it/screens/super_admin/home.dart';
import 'package:stream_it/screens/user/home.dart';

import 'firebase_options.dart';

Future<void> main() async {
  loadModels();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
      ],
      child: const MyApp(),
    ),
  );
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
        appBarTheme: AppBarTheme(
            color: Colors.purpleAccent,
            titleTextStyle: TextStyle(color: Colors.white)),
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
  var _number = 0;

  setNumber(int number) {
    setState(() {
      _number = number;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null && FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
          appBar: AppBar(
            title: Text("StreamIt"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Un instant...'),
                ),
              ],
            ),
          ));
    } else if (currentUser != null) {
      if (currentUser.role == "super_admin") {
        return SuperAdminPageHome(user: currentUser);
      } else {
        return UserPageHome(idUser: currentUser.id);
      }
    } else {
      return Scaffold(
        appBar: AppBar(
          title: [
            Text("Connexion"),
            Text("Inscription"),
          ][_number],
        ),
        body: [
          Login(),
          Signup(),
        ][_number],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _number,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.brown,
            iconSize: 32,
            backgroundColor: Colors.purple[200],
            onTap: (index) {
              setNumber(index);
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.accessibility_new_sharp),
                  label: 'Connexion'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.accessibility_new_sharp),
                  label: 'Inscription'),
            ]),
      );
    }
  }
}