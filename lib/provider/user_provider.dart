import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/backend/random_avatar.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
  String _email = '';
  String _profilePict = '';
  String _role = '';
  bool _isActive = true;
  List<DocumentSnapshot> _otherUsers = [];
  bool _isLoading = false;

  String get username => _username;
  String get email => _email;
  String get profilePict => _profilePict;
  String get role => _role;
  bool get isActive => _isActive;
  List<DocumentSnapshot> get otherUsers => _otherUsers;
  bool get isLoading => _isLoading;

  UserProvider() {
    setUser();
    fetchOtherUsers();
    addIsActiveFieldToUsers();
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
      _isActive = userDoc['isActive'] ?? true;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final pinjamanQuerySnapshot = await FirebaseFirestore.instance
        .collection('pinjaman')
        .where('user-id', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();
    final angsuranQuerySnapshot = await FirebaseFirestore.instance
        .collection('angsuran')
        .where('user-id', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return {
      'user': userDoc.data(),
      'pinjaman': pinjamanQuerySnapshot.docs.isNotEmpty
          ? pinjamanQuerySnapshot.docs.first.data()
          : null,
      'angsuran': angsuranQuerySnapshot.docs.isNotEmpty
          ? angsuranQuerySnapshot.docs.first.data()
          : null,
    };
  }

  Future<void> toggleAccountStatus(String userId, bool isActive) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isActive': !isActive,
    });
  }

  Future<void> addIsActiveFieldToUsers() async {
    try {
      // Fetch all users
      final userQuerySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Batch write to update users without 'isActive' field
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in userQuerySnapshot.docs) {
        if (!doc.data().containsKey('isActive')) {
          batch.update(doc.reference, {'isActive': true});
        }
      }

      // Commit the batch write
      await batch.commit();
      print('All users without isActive field have been updated.');
    } catch (e) {
      print('Failed to update users: $e');
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
