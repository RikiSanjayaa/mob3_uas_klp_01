import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/backend/int_to_rupiah.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  double totalPinjaman = 0.0;
  double totalAngsuran = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch total users
      final userQuerySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      totalUsers = userQuerySnapshot.size;

      // Fetch total pinjaman
      final pinjamanQuerySnapshot =
          await FirebaseFirestore.instance.collection('pinjaman').get();
      totalPinjaman = pinjamanQuerySnapshot.docs.fold(0.0,
          (total, doc) => total + (doc['besar-pinjaman'] as num).toDouble());

      // Fetch total angsuran
      final angsuranQuerySnapshot = await FirebaseFirestore.instance
          .collection('angsuran')
          .where('status', isEqualTo: 'completed')
          .get();
      totalAngsuran = angsuranQuerySnapshot.docs.fold(0.0,
          (total, doc) => total + (doc['besar-angsuran'] as num).toDouble());
    } catch (e) {
      print('Failed to fetch data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildStatisticCard('Total Users', totalUsers),
                  const SizedBox(height: 20),
                  _buildStatisticCard(
                      'Total Pinjaman Taken', formatToRP(totalPinjaman)),
                  const SizedBox(height: 20),
                  _buildStatisticCard(
                      'Total Angsuran Paid', formatToRP(totalAngsuran)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticCard(String title, dynamic value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
