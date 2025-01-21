import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_it/models/user.dart' as models;
import 'package:stream_it/repositories/user.dart';

class UserProvider with ChangeNotifier {
  models.User? _currentUser;

  models.User? get currentUser => _currentUser;

  Future<void> loadUser() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _currentUser = await UserRepository.instance.getById(userId);
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
