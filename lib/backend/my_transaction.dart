import 'package:cloud_firestore/cloud_firestore.dart';

class MyTransaction {
  final String id;
  final String type; // pinjaman atau angsuran
  final double amount;
  final double ratio;
  final DateTime date;

  MyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.ratio,
    required this.date,
  });

  factory MyTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MyTransaction(
      id: doc.id,
      type: data['type'],
      amount: (data['amount'] as num).toDouble(),
      ratio: (data['ratio'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
