import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/pinjaman_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinjamanProvider = Provider.of<PinjamanProvider>(context);
    final transactions = pinjamanProvider.transactions;
    final DateFormat dateFormat = DateFormat('d MMMM yyyy');
    final List<Color> colors = [Colors.purple, Colors.orange, Colors.green];
    final Random random = Random();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: pinjamanProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final color = colors[random.nextInt(colors.length)];
                  return _transactionHistory(
                    title: transaction.type == 'pinjaman'
                        ? 'Pinjaman'
                        : 'Angsuran',
                    date: dateFormat.format(transaction.date),
                    progressAngsuran:
                        transaction.type == 'angsuran' ? transaction.ratio : 0,
                    color: color,
                  );
                },
              ),
            ),
    );
  }

  Widget _transactionHistory({
    required String title,
    required String date,
    required double progressAngsuran,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    '${(progressAngsuran * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircularProgressIndicator(
                value: progressAngsuran,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: color.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
