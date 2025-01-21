import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mob3_uas_klp_01/UI/account.dart';
import 'package:mob3_uas_klp_01/provider/pinjaman_provider.dart';
import 'package:mob3_uas_klp_01/provider/user_provider.dart';
import 'package:provider/provider.dart';

class InactiveAccountScreen extends StatelessWidget {
  const InactiveAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final pinjamanProvider =
        Provider.of<PinjamanProvider>(context, listen: false);

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
                pinjamanProvider.userLogOut();
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/default-user.png', width: 200),
                const SizedBox(height: 20),
                const Text(
                  'Your account is inactive, please contact the administrator for further details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ));
  }
}
