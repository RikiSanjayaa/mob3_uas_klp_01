import 'package:flutter/material.dart';
import '/backend/date_to_string.dart';
import '/backend/int_to_rupiah.dart';

class DetailPinjaman extends StatelessWidget {
  const DetailPinjaman({
    super.key,
    this.color = Colors.purple,
    required this.besarPinjaman,
    required this.lamaPinjaman,
    required this.bunga,
    required this.totalAngsuran,
    required this.angsuranPerbulan,
    required this.tanggal,
  });

  final Color color;
  final int besarPinjaman;
  final int lamaPinjaman;
  final int bunga;
  final double totalAngsuran;
  final double angsuranPerbulan;
  final DateTime tanggal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(
                              'Besar Pinjaman', intToRP(besarPinjaman)),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                              'Lama Angsuran', "$lamaPinjaman bulan"),
                          const SizedBox(height: 16),
                          _buildDetailItem('Besar Bunga', '$bunga%'),
                          // first Column
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(
                              'Total Angsuran', doubleToRP(totalAngsuran)),
                          const SizedBox(height: 16),
                          _buildDetailItem('Angsuran perbulan',
                              doubleToRP(angsuranPerbulan)),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                              'Tanggal Peminjaman', dateToString(tanggal)),
                          // first Column
                        ],
                      ),
                    ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
