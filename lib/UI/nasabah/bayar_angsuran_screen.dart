import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/backend/date_to_string.dart';
import 'package:mob3_uas_klp_01/backend/int_to_rupiah.dart';
import '/components/custom_snackbar.dart';
import '/provider/pinjaman_provider.dart';
import 'package:provider/provider.dart';
import '/components/custom_elevated_btn.dart';

class BayarAngsuranScreen extends StatefulWidget {
  const BayarAngsuranScreen({super.key});

  @override
  State<BayarAngsuranScreen> createState() => _BayarAngsuranScreenState();
}

class _BayarAngsuranScreenState extends State<BayarAngsuranScreen> {
  bool isLoading = false;
  void _bayarAngsuran(pinjamanProvider, scaffoldMessenger, angsuran) async {
    setState(() {
      isLoading = true;
    });
    await pinjamanProvider.bayarAngsuran(angsuran.id);
    scaffoldMessenger.clearSnackBars();
    if (mounted) {
      Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        const CustomSnackBar(
            content: Text('Berhasil bayar Angsuran!.'), color: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final pinjamanProvider =
        Provider.of<PinjamanProvider>(context, listen: false);
    final angsuran = pinjamanProvider.currentAngsuran;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.subdirectory_arrow_left))
        ],
        leadingWidth: double.infinity,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Image.asset(
                'assets/images/letter-p.png',
                height: 30,
              ),
              const SizedBox(width: 10),
              const Text(
                "PinjamDulu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bayar Angsuran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 30),
              const Text("Besar Angsuran:"),
              const SizedBox(height: 10),
              Text(
                doubleToRP(angsuran!['besar-angsuran']),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 10),
              const Text("Tanggal Jatuh tempo:"),
              const SizedBox(height: 10),
              Text(
                dateToString(angsuran['jatuh-tempo'].toDate()),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Text("Angsuran ke:"),
              const SizedBox(height: 10),
              Text(
                "${angsuran['angsuran-ke']} dari ${angsuran['lama-angsuran']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomElevatedBtn(
                      onPressed: () {
                        _bayarAngsuran(
                            pinjamanProvider, scaffoldMessenger, angsuran);
                      },
                      child: const Text(
                        "Bayar Angsuran",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
