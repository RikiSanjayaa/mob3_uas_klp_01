import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard(
      {super.key, this.email = "email", this.username = "username"});

  final String? email;
  final String? username;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Ceritanya Home Screen"),
          const SizedBox(height: 20),
          Text("Authenticated User Email: $email"),
          Text("Username: $username")
        ],
      ),
    );
  }
}
