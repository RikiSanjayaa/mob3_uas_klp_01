import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/backend/random_avatar.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
  String _email = '';
  String _profilePict = '';
  String _role = '';
  List<DocumentSnapshot> _otherUsers = [];
  bool _isLoading = false;

  String get username => _username;
  String get email => _email;
  String get profilePict => _profilePict;
  String get role => _role;
  List<DocumentSnapshot> get otherUsers => _otherUsers;
  bool get isLoading => _isLoading;

  UserProvider() {
    setUser();
    fetchOtherUsers();
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
      _role = userDoc['role'];
      notifyListeners();
    }
  }

  void logUserOut() {
    _username = '';
    _email = '';
    _profilePict = '';
    _role = '';
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

  Future<void> fetchOtherUsers() async {
    _isLoading = true;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isNotEqualTo: user.email)
          .get();
      _otherUsers = userQuerySnapshot.docs;
    }

    _isLoading = false;
    notifyListeners();
  }
}
