import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/components/custom_snackbar.dart';
import '/components/detail_pinjaman.dart';
import '/provider/pinjaman_provider.dart';
import 'package:provider/provider.dart';
import '/components/custom_elevated_btn.dart';

class AmbilPinjamanScreen extends StatefulWidget {
  const AmbilPinjamanScreen({super.key});

  @override
  State<AmbilPinjamanScreen> createState() => _AmbilPinjamanScreenState();
}

class _AmbilPinjamanScreenState extends State<AmbilPinjamanScreen> {
  int? _selectedPinjaman;
  int? _lamaPinjaman;
  int? _interestRate;

  double? totalAngsuran;
  double? angsuranPerbulan;

  void calculateAngsuran() {
    if (_selectedPinjaman != null && _interestRate != null) {
      totalAngsuran =
          _selectedPinjaman! + (_selectedPinjaman! * _interestRate! / 100);
      angsuranPerbulan = totalAngsuran! / _lamaPinjaman!;
    } else {
      totalAngsuran = null;
      angsuranPerbulan = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final List<int> loanAmounts =
        List.generate(10, (index) => (index + 1) * 1000000);
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final Map<int, int> interestRates = {3: 10, 6: 20, 12: 30};

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
                "Ambil Pinjaman",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 30),
              const Text("Pilih besar pinjaman"),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Besar Pinjaman',
                ),
                value: _selectedPinjaman,
                items: loanAmounts.map((amount) {
                  return DropdownMenuItem<int>(
                    value: amount,
                    child: Text(currencyFormat.format(amount)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPinjaman = value;
                    calculateAngsuran();
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text("Pilih lama pinjaman"),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Lama Pinjaman',
                ),
                value: _lamaPinjaman,
                items: interestRates.keys.map((periode) {
                  return DropdownMenuItem<int>(
                    value: periode,
                    child: Text("$periode bulan"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _lamaPinjaman = value;
                    _interestRate = interestRates[value];
                    calculateAngsuran();
                  });
                },
              ),
              const SizedBox(height: 30),
              // In Progress Section
              const Text(
                'Detail Pinjaman:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedPinjaman != null && _interestRate != null)
                DetailPinjaman(
                  besarPinjaman: _selectedPinjaman!,
                  lamaPinjaman: _lamaPinjaman!,
                  bunga: _interestRate!,
                  totalAngsuran: totalAngsuran!,
                  angsuranPerbulan: angsuranPerbulan!,
                  tanggal: DateTime.now(),
                ),

              const SizedBox(height: 20),
              CustomElevatedBtn(
                onPressed: () {
                  if (_selectedPinjaman != null && _lamaPinjaman != null) {
                    Provider.of<PinjamanProvider>(context, listen: false)
                        .addPinjaman({
                      'besar-pinjaman': _selectedPinjaman,
                      'lama-angsuran': _lamaPinjaman,
                      'besar-bunga': _interestRate,
                      'total-angsuran': totalAngsuran,
                      'angsuran-perbulan': angsuranPerbulan,
                      'tanggal-peminjaman': DateTime.now(),
                      'status': 'active'
                    });
                    Navigator.of(context).pop();
                  } else {
                    // Show an error message or handle the case where no amount or period is selected
                    scaffoldMessenger.clearSnackBars();
                    scaffoldMessenger.showSnackBar(
                      const CustomSnackBar(
                          content:
                              Text('Tolong pilih besar dan lama pinjaman.'),
                          color: Colors.red),
                    );
                  }
                },
                child: const Text(
                  "Ambil Pinjaman",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
