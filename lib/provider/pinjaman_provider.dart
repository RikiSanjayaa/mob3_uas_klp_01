import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PinjamanProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // pinjaman
  List<DocumentSnapshot> _listPinjaman = [];
  bool punyaPinjamanAktif = false;
  late DocumentSnapshot<Object?>? _pinjaman;
  int _persentasePinjaman = 0;
  double? _ratioPinjaman;

  List<DocumentSnapshot> get listPinjaman => _listPinjaman;
  DocumentSnapshot? get pinjaman => _pinjaman;
  int get persentasePinjaman => _persentasePinjaman;
  double? get ratioPinjaman => _ratioPinjaman;

  // angsuran
  List<DocumentSnapshot> _listAngsuran = [];
  bool punyaAngsuranAktif = false;
  late DocumentSnapshot<Object?>? _currentAngsuran;
  int _persentaseAngsuran = 0;
  double? _ratioAngsuran;

  List<DocumentSnapshot> get listAngsuran => _listAngsuran;
  DocumentSnapshot? get currentAngsuran => _currentAngsuran;
  int get persentaseAngsuran => _persentaseAngsuran;
  double? get ratioAngsuran => _ratioAngsuran;

  PinjamanProvider() {
    fetchAllData();
  }

  void fetchAllData() {
    fetchPinjaman();
    fetchAngsuran();
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
        _listPinjaman = pinjamanQuerySnapshot.docs;
        punyaPinjamanAktif = _listPinjaman.any((pinjaman) {
          return pinjaman['status'] == 'active';
        });

        if (punyaPinjamanAktif) {
          _pinjaman = _listPinjaman[0];
          _ratioPinjaman = _pinjaman!['besar-pinjaman'] / 10000000;
          _persentasePinjaman = (ratioPinjaman! * 100).toInt();
        } else {
          _pinjaman = null;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch pinjaman: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAngsuran() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final angsuranQuerySnapshot = await FirebaseFirestore.instance
            .collection('angsuran')
            .where('user-id', isEqualTo: user.uid)
            .where('status', isEqualTo: 'pending')
            .get();
        _listAngsuran = angsuranQuerySnapshot.docs;
        punyaAngsuranAktif = _listAngsuran.any((angsuran) {
          return angsuran['status'] == 'pending';
        });

        if (punyaAngsuranAktif) {
          _currentAngsuran = _listAngsuran[0];
          _ratioAngsuran = (_currentAngsuran!['angsuran-ke'] - 1) /
              _currentAngsuran!['lama-angsuran'];
          _persentaseAngsuran = (_ratioAngsuran! * 100).toInt();
        } else {
          _currentAngsuran = null;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch angsuran: $e';
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
        final pinjaman = await FirebaseFirestore.instance
            .collection('pinjaman')
            .add(pinjamanData);
        // Calculate the first installment details
        final double besarAngsuran = pinjamanData['angsuran-perbulan'];
        final DateTime jatuhTempo =
            DateTime.now().add(const Duration(days: 30));
        int angsuranKe = 1;

        // Add the first installment
        await addAngsuran({
          'pinjaman-id': pinjaman.id,
          'besar-angsuran': besarAngsuran,
          'jatuh-tempo': jatuhTempo,
          'angsuran-ke': angsuranKe,
          'lama-angsuran': pinjamanData['lama-angsuran'],
          'status': 'pending',
        });

        fetchPinjaman(); // Refresh the pinjaman list
        fetchAngsuran();
      }
    } catch (e) {
      _errorMessage = 'Failed to add pinjaman: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAngsuran(Map<String, dynamic> dataAngsuran) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        dataAngsuran['user-id'] = user.uid;
        await FirebaseFirestore.instance
            .collection('angsuran')
            .add(dataAngsuran);
      }
    } catch (e) {
      _errorMessage = 'Failed to add angsuran: $e';
      print(_errorMessage);
    }
  }

  void userLogOut() {
    _isLoading = false;
    _errorMessage = '';
    _listPinjaman = [];
    punyaPinjamanAktif = false;
    _pinjaman = null;
    _persentasePinjaman = 0;
    _ratioPinjaman = null;
    _listAngsuran = [];
    punyaAngsuranAktif = false;
    _currentAngsuran = null;
    _ratioAngsuran = null;
    notifyListeners();
  }
}
