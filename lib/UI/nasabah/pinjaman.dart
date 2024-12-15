import 'package:flutter/material.dart';
import '/UI/nasabah/ambil_pinjaman_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/int_to_rupiah.dart';
import '/components/detail_pinjaman.dart';
import '/provider/pinjaman_provider.dart';
import 'package:provider/provider.dart';
import '/components/custom_container.dart';

class PinjamanScreen extends StatefulWidget {
  const PinjamanScreen({super.key});

  @override
  State<PinjamanScreen> createState() => _PinjamanScreenState();
}

class _PinjamanScreenState extends State<PinjamanScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PinjamanProvider>(
        builder: (context, pinjamanProvider, child) {
      DocumentSnapshot<Object?>? pinjaman;
      if (pinjamanProvider.punyaPinjamanAktif) {
        pinjaman = pinjamanProvider.pinjaman;
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
                      color: Colors.deepOrangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pinjamanProvider.punyaPinjamanAktif
                                    ? "Total Pinjaman:"
                                    : "Tidak ada Pinjaman aktif",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                pinjamanProvider.punyaPinjamanAktif
                                    ? intToRP(pinjaman!['besar-pinjaman'])
                                    : "Ambil Pinjaman!",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Limit pinjaman:",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                              const Text(
                                "Rp 10.000.000",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: pinjamanProvider.punyaPinjamanAktif
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
                                  pinjamanProvider.punyaPinjamanAktif
                                      ? "Bayar Angsuran"
                                      : "Ambil Pinjaman",
                                  style: const TextStyle(
                                      color: Colors.deepOrangeAccent),
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
                                  value: pinjamanProvider.punyaPinjamanAktif
                                      ? pinjamanProvider.ratioPinjaman
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
                                    '${pinjamanProvider.persentasePinjaman}%',
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
                    if (pinjamanProvider.punyaPinjamanAktif)
                      const Text(
                        'Progress Pelunasan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (pinjamanProvider.punyaPinjamanAktif)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Angsuran Terbayar',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Target Lunas',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Rp 0',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.orange,
                                      ),
                                      Text(
                                        doubleToRP(pinjaman!['total-angsuran']),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  // const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: 0,
                                    color: Colors.orange,
                                    backgroundColor:
                                        Colors.orange.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // In Progress Section
                    if (pinjamanProvider.punyaPinjamanAktif)
                      const Text(
                        'Detail Pinjaman',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (pinjamanProvider.punyaPinjamanAktif)
                      DetailPinjaman(
                          color: Colors.orange,
                          besarPinjaman: pinjaman!['besar-pinjaman'],
                          lamaPinjaman: pinjaman['lama-angsuran'],
                          bunga: pinjaman['besar-bunga'],
                          totalAngsuran: pinjaman['total-angsuran'],
                          angsuranPerbulan: pinjaman['angsuran-perbulan'],
                          tanggal: pinjaman['tanggal-peminjaman'].toDate())
                  ],
                ),
              ),
            );
    });
  }
}
