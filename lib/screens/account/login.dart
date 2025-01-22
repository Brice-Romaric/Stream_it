import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_it/main.dart';
import 'package:stream_it/providers/user.dart';
import 'package:stream_it/repositories/user.dart';
import 'package:stream_it/screens/super_admin/home.dart';
import 'package:stream_it/screens/user/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50, right: 20, bottom: 20, left: 20),
      child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Mail",
                  hintText: "entrez votre adresse mail",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez saisir le mail";
                  }
                  return null;
                },
                controller: emailController,
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mot De Passe',
                  hintText: 'entrez votre Mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mot de passe vide";
                  }
                  if (value.length < 6) {
                    return "le mot de passe doit comporter plus de 6 caractères";
                  }
                  return null;
                },
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Colors.purpleAccent),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final mail = emailController.text;
                      final mdp = passwordController.text;
                      try {
                        final userCredential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: mail, password: mdp);
                        if (userCredential.user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("connexion en cours...")));
                          FocusScope.of(context).requestFocus(FocusNode());

                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);

                          final currentUser = await UserRepository.instance
                              .getById(userCredential.user!.uid);
                          if (currentUser != null) {
                            switch (currentUser.role) {
                              case 'super_admin':
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SuperAdminPageHome(
                                    user: currentUser,
                                    onLogout: (context) {
                                      userProvider.logout();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MonScaffold()),
                                          (route) => false);
                                    },
                                  );
                                }));
                                break;
                              case 'user':
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return UserPageHome(
                                    idUser: currentUser.id,
                                    onLogout: (context) {
                                      userProvider.logout();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MonScaffold()),
                                          (route) => false);
                                    },
                                  );
                                }));
                                break;
                            }
                          }
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found' ||
                            e.code == 'wrong-password') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "mauvais utilisateur ou mauvais mot de passe")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("erreur dans l'authentification")));
                        }
                      }
                    }
                  },
                  child: const Text("Se connecter avec mail",
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          )),
    );
  }
}
