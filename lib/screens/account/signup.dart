import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final lastnameController = TextEditingController();
  final firstnameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    mailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
        child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Mail",
                  hintText: "entrez votre mail",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "saisissez le mail";
                  }
                  if (!isEmail(value)) {
                    return "entrez un mail valide";
                  }
                  return null;
                },
                controller: mailController,
              ),
              const SizedBox(height: 5),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Mot De Passe",
                  hintText: "entrez votre mot de passe",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "saisissez le mot de passe";
                  }
                  if (value.length < 6) {
                    return "le mot de passe doit comporter plus de 6 caractères";
                  }
                  return null;
                },
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 5),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nom de Famille",
                  hintText: "entrez votre nom de famille",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "saisissez le nom de famille";
                  }
                  return null;
                },
                controller: lastnameController,
              ),
              const SizedBox(height: 5),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  hintText: "entrez votre prénom",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "saisissez le prénom";
                  }
                  return null;
                },
                controller: firstnameController,
              ),
              const SizedBox(height: 5),
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
                      final mail = mailController.text;
                      final mdp = passwordController.text;
                      final lastname = lastnameController.text;
                      final firstname = firstnameController.text;

                      try {
                        final userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: mail, password: mdp);
                        //authentifier le user avant de créer
                        if (userCredential.user != null) {
                          CollectionReference userRef =
                              FirebaseFirestore.instance.collection("user");
                          await userRef.doc(userCredential.user!.uid).set({
                            'id': userCredential.user!.uid,
                            'role': 'user',
                            'email': mail,
                            'last_name': lastname,
                            'first_name': firstname,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Inscription réussie")));
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      } on FirebaseAuthException catch (e) {
                        String errorMessage;
                        // Gestion spécifique des erreurs d'authentification
                        switch (e.code) {
                          case 'email-already-in-use':
                            errorMessage = "Cet email est déjà utilisé.";
                            break;
                          case 'weak-password':
                            errorMessage = "Le mot de passe est trop faible.";
                            break;
                          case 'invalid-email':
                            errorMessage = "L'email fourni est invalide.";
                            break;
                          case 'operation-not-allowed':
                            errorMessage = "L'opération n'est pas autorisée.";
                            break;
                          case 'too-many-requests':
                            errorMessage =
                                "Trop de demandes d'inscription. Réessayez plus tard.";
                            break;
                          default:
                            errorMessage = "Erreur lors de l'inscription!";
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                      } catch (e) {
                        // Gestion des autres types d'erreurs
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Une erreur inattendue s'est produite!")),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "S'inscrire",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              )
            ])));
  }
}
