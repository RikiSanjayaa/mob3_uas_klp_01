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
  bool isLoadingMore = false;
  DocumentSnapshot? lastDocument;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final int _itemsPerPage = 6;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoadingMore && lastDocument != null) {
        fetchMoreTransactions();
      }
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final transactionQuerySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(_itemsPerPage)
          .get();

      if (transactionQuerySnapshot.docs.isNotEmpty) {
        lastDocument = transactionQuerySnapshot.docs.last;
      }

      List<Map<String, dynamic>> tempTransactions = [];

      for (var transaction in transactionQuerySnapshot.docs) {
        final userId = transaction['user-id'];
        final userData = await fetchUserData(userId);
        tempTransactions.add({
          'transaction': transaction.data(),
          'user': userData,
          'snapshot': transaction,
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

  Future<void> fetchMoreTransactions() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final transactionQuerySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('date', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(_itemsPerPage)
          .get();

      if (transactionQuerySnapshot.docs.isNotEmpty) {
        lastDocument = transactionQuerySnapshot.docs.last;
      }

      List<Map<String, dynamic>> tempTransactions = [];

      for (var transaction in transactionQuerySnapshot.docs) {
        final userId = transaction['user-id'];
        final userData = await fetchUserData(userId);
        tempTransactions.add({
          'transaction': transaction.data(),
          'user': userData,
          'snapshot': transaction,
        });
      }

      setState(() {
        transactions.addAll(tempTransactions);
        filteredTransactions.addAll(tempTransactions);
        isLoadingMore = false;
      });
    } catch (e) {
      print('Failed to fetch more transactions: $e');
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data();
  }

  void filterTransactions(String query) {
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
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredTransactions.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredTransactions.length) {
                            return isLoadingMore
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox();
                          }

                          final transactionData = filteredTransactions[index];
                          final transaction = transactionData['transaction'];
                          final user = transactionData['user'];
                          final type = transaction['type'];
                          final amount =
                              (transaction['amount'] as num).toDouble();
                          final date =
                              (transaction['date'] as Timestamp).toDate();
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
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
