import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/UI/admin/admin_statistics.dart';
import 'admin/admin_dashboard.dart';
import '/UI/account.dart';
import '/UI/anggota.dart';
import 'user/pinjaman.dart';
import 'user/dashboard.dart';
import '/provider/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    // add listener to page controller
    _pageController.addListener(() {
      int nextPage = _pageController.page!.round();
      if (nextPage != _selectedIndex) {
        setState(() {
          _selectedIndex = nextPage;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 55,
          leadingWidth: double.infinity,
          leading: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AccountScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    child: SvgPicture.string(
                      userProvider.profilePict,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Hello!"),
                      Flexible(
                        child: Text(
                          userProvider.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                userProvider.logUserOut();
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: false,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          backgroundColor: Theme.of(context).colorScheme.surface,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: "Anggota",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.leaderboard),
              label: userProvider.role == 'administrator'
                  ? "Statistics"
                  : "Pinjaman",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple,
          selectedIconTheme: const IconThemeData(size: 35),
          unselectedItemColor: Theme.of(context).colorScheme.secondary,
        ),
        body: PageView(
          controller: _pageController,
          children: [
            // page anggota
            const AnggotaScreen(),

            // home page/dashboard
            userProvider.role == 'administrator'
                ? const AdminDashboard()
                : const Dashboard(),

            //  page pinjaman
            userProvider.role == 'administrator'
                ? const AdminStatistics()
                : const PinjamanScreen(),
          ],
        ),
      );
    });
  }
}
