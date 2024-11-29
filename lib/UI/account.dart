import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late TextEditingController _usernameController;
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _usernameController = TextEditingController(text: username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
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

  void _editUsername() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // TODO: user Provider for User data across screens
                final newUsername = _usernameController.text;
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({'username': newUsername});
                  setState(() {
                    username = newUsername;
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage(
                      'assets/images/letter-p.png'), // Replace with your image asset
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: implement change profile-image
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 25,
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ))
              ]),
              const SizedBox(height: 60),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                leading: const Icon(
                  Icons.account_circle_rounded,
                  size: 35,
                ),
                title: const Text(
                  "Username",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                subtitle: Text(
                  username ?? "username",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                  onPressed: _editUsername,
                ),
                onTap: _editUsername,
              ),
              const Divider(
                height: 0,
                endIndent: 20,
                indent: 80,
              ),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                leading: const Icon(
                  Icons.email,
                  size: 35,
                ),
                title: const Text(
                  "Email",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                subtitle: Text(
                  email ?? "email",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(
                height: 0,
                endIndent: 20,
                indent: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
