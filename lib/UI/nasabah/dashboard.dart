import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/UI/nasabah/ambil_pinjaman_screen.dart';
import '/backend/date_to_string.dart';
import '/backend/int_to_rupiah.dart';
import '/provider/pinjaman_provider.dart';
import 'package:provider/provider.dart';
import '/components/custom_container.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PinjamanProvider>(
        builder: (context, pinjamanProvider, child) {
      DocumentSnapshot<Object?>? pinjaman;
      DocumentSnapshot<Object?>? angsuran;
      bool punyaPinjaman = pinjamanProvider.punyaPinjamanAktif;
      if (punyaPinjaman) {
        pinjaman = pinjamanProvider.pinjaman;
        angsuran = pinjamanProvider.currentAngsuran;
      }

      return pinjamanProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Progress Section
                    CustomContainer(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                punyaPinjaman
                                    ? "Pembayaran Angsuran"
                                    : "Anda tidak memiliki",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                punyaPinjaman
                                    ? doubleToRP(angsuran!['besar-angsuran'])
                                    : "Pinjaman",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (!punyaPinjaman) const SizedBox(height: 30),
                              if (punyaPinjaman)
                                Text(
                                  "Jatuh tempo:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              if (punyaPinjaman)
                                Text(
                                  dateToString(
                                      angsuran!["jatuh-tempo"].toDate()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: punyaPinjaman
                                    ? () {
                                        // ganti ke bayar angsuran
                                      }
                                    : () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const AmbilPinjamanScreen();
                                        }));
                                      },
                                child: Text(
                                  punyaPinjaman
                                      ? "Bayar Angsuran"
                                      : "Ambil Pinjaman",
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  strokeWidth: 12,
                                  strokeCap: StrokeCap.round,
                                  value: punyaPinjaman
                                      ? pinjamanProvider.ratioAngsuran
                                      : 0,
                                  color: Colors.white,
                                  backgroundColor:
                                      const Color.fromARGB(100, 255, 255, 255),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    '${pinjamanProvider.persentaseAngsuran}%',
                                    style: const TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (punyaPinjaman) const SizedBox(height: 20),

                    // In Progress Section
                    if (punyaPinjaman)
                      const Text(
                        'Total Pinjaman & Angsuran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (punyaPinjaman) const SizedBox(height: 16),
                    if (punyaPinjaman)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTaskCard(
                            title: 'Total Pinjaman',
                            subtitle: intToRP(pinjaman!['besar-pinjaman']),
                            color: Colors.blue,
                            progress: pinjamanProvider.ratioPinjaman!,
                          ),
                          _buildTaskCard(
                            title: 'Angsuran Terbayar',
                            subtitle: doubleToRP(angsuran!['besar-angsuran'] *
                                (angsuran['angsuran-ke'] - 1)),
                            color: Colors.orange,
                            progress: pinjamanProvider.ratioAngsuran!,
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Task Groups Section
                    const Text(
                      'History Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _transactionHistory(
                      title: 'Angsuran ke 8',
                      date: '25 November 2024',
                      progressAngsuran: 0.85,
                      color: Colors.purple,
                    ),
                    _transactionHistory(
                      title: 'Angsuran ke 7',
                      date: '23 Oktober 2024',
                      progressAngsuran: 0.70,
                      color: Colors.green,
                    ),
                    _transactionHistory(
                      title: 'Angsuran ke 6',
                      date: '20 September 2024',
                      progressAngsuran: 0.55,
                      color: Colors.orange,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Open Transaction History page from here
                        },
                        child: const Text(
                          "...",
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
    });
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required Color color,
    required double progress,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 10),
            // const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: color.withOpacity(0.3),
            ),
          ],
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
