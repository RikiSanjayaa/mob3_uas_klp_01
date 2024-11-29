import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _username = '';
  String _email = '';

  String get username => _username;
  String get email => _email;

  UserProvider() {
    setUser();
  }

  void setUser() async {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    if (authenticatedUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authenticatedUser.uid)
          .get();
      _username = userDoc['username'];
      _email = authenticatedUser.email!;
      notifyListeners();
    }
  }

  void setUsername(String newUsername) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'username': newUsername});
      _username = newUsername;
      notifyListeners();
    }
  }
}
