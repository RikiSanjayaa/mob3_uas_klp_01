import 'package:flutter/material.dart';
import '/components/custom_container.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double progressAngsuran = 0.85;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Progress Section
            CustomContainer(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pembayaran Angsuran",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        // TODO: variable angsuran disini, pake Provider
                        "Rp 500.000",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Jatuh tempo:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        "25 Desember 2024",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // navigate to bayar angsuran
                        },
                        child: const Text("Bayar Angsuran"),
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
                          value: progressAngsuran,
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
                            '${(progressAngsuran * 100).toInt()}%',
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
            const SizedBox(height: 20),

            // In Progress Section
            const Text(
              'Total Pinjaman & Angsuran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTaskCard(
                  title: 'Total Pinjaman',
                  subtitle: 'Rp 3.000.000',
                  color: Colors.blue,
                  progress: 0.3,
                ),
                _buildTaskCard(
                  title: 'Angsuran Terbayar',
                  subtitle: 'Rp 2.550.000',
                  color: Colors.orange,
                  progress: progressAngsuran,
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
