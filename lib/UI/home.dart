import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/UI/anggota.dart';
import 'package:mob3_uas_klp_01/UI/angsuran.dart';
import 'package:mob3_uas_klp_01/UI/dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _fetchUsername() async {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    if (authenticatedUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authenticatedUser.uid)
          .get();
      setState(() {
        username = userDoc['username'];
        email = authenticatedUser.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Pinjol'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Anggota",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: "Angsuran",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 39, 22, 170),
        selectedIconTheme: const IconThemeData(size: 35),
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          // page anggota
          const AnggotaScreen(),

          // home page/dashboard
          Dashboard(email: email, username: username),

          //  page angsuran
          const AngsuranScreen(),
        ],
      ),
    );
  }
}
