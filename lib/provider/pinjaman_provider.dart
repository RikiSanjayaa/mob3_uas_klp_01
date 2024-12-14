import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PinjamanProvider with ChangeNotifier {
  List<DocumentSnapshot> _pinjaman = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<DocumentSnapshot> get pinjaman => _pinjaman;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  PinjamanProvider() {
    fetchPinjaman();
  }

  Future<void> fetchPinjaman() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final pinjamanQuerySnapshot = await FirebaseFirestore.instance
            .collection('pinjaman')
            .where('user-id', isEqualTo: user.uid)
            .where('status', isEqualTo: 'active')
            .get();
        _pinjaman = pinjamanQuerySnapshot.docs;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch pinjaman: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPinjaman(Map<String, dynamic> pinjamanData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        pinjamanData['user-id'] = user.uid;
        await FirebaseFirestore.instance
            .collection('pinjaman')
            .add(pinjamanData);
        fetchPinjaman(); // Refresh the pinjaman list
      }
    } catch (e) {
      _errorMessage = 'Failed to add pinjaman: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }
}
