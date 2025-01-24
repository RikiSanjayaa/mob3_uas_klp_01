import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mob3_uas_klp_01/backend/int_to_rupiah.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchTransactions() async {
    try {
      final transactionQuerySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> tempTransactions = [];

      for (var transaction in transactionQuerySnapshot.docs) {
        final userId = transaction['user-id'];
        final userData = await fetchUserData(userId);
        tempTransactions.add({
          'transaction': transaction.data(),
          'user': userData,
        });
      }

      setState(() {
        transactions = tempTransactions;
        filteredTransactions = transactions;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch transactions: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()!;
  }

  void filterTransactions(String query) async {
    setState(() {
      searchQuery = query;
      filteredTransactions = transactions.where((transaction) {
        final email = transaction['user']['email'].toLowerCase();
        final searchLower = query.toLowerCase();
        return email.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search User by Email',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterTransactions,
                    controller: _searchController,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transactionData = filteredTransactions[index];
                      final transaction = transactionData['transaction'];
                      final user = transactionData['user'];
                      final type = transaction['type'];
                      final amount = (transaction['amount'] as num).toDouble();
                      final date = (transaction['date'] as Timestamp).toDate();
                      final contextText = type == 'angsuran'
                          ? 'Pembayaran Angsuran'
                          : 'Pengambilan Pinjaman';
                      final color =
                          type == 'angsuran' ? Colors.green : Colors.blue;

                      return ListTile(
                        leading: CircleAvatar(
                          child: SvgPicture.string(user['profile-pict']),
                        ),
                        title: Text(user['username']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email']),
                            Text(contextText),
                            Text(formatToRP(amount)),
                            Text(DateFormat('d MMMM yyyy').format(date)),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward, color: color),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
