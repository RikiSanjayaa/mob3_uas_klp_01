import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/provider/user_provider.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late TextEditingController _usernameController;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _usernameController = TextEditingController(text: userProvider.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
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
                final newUsername = _usernameController.text;
                userProvider.setUsername(newUsername);
                Navigator.of(context).pop();
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
                      'assets/images/default-user.png'), // Replace with your image asset
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
              Consumer<UserProvider>(builder: (context, userProvider, child) {
                return ListTile(
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
                    userProvider.username,
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
                );
              }),
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
                  userProvider.email,
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
