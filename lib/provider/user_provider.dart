import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/backend/random_avatar.dart';

class UserProvider extends ChangeNotifier {
  String _username = '';
  String _email = '';
  String _profilePict = '';

  String get username => _username;
  String get email => _email;
  String get profilePict => _profilePict;

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
      _profilePict = userDoc['profile-pict'];
      _email = authenticatedUser.email!;
      notifyListeners();
    }
  }

  void logUserOut() {
    _username = '';
    _email = '';
    _profilePict = '';
    notifyListeners();
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

  void updateAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    String newProfilePict = getRandomAvatar();
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profile-pict': newProfilePict});
      _profilePict = newProfilePict;
      notifyListeners();
    }
  }
}
