import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/provider/user_provider.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Ceritanya Home Screen"),
          const SizedBox(height: 20),
          Text("Authenticated User Email: ${userProvider.email}"),
          Text("Username: ${userProvider.username}")
        ],
      ),
    );
  }
}
