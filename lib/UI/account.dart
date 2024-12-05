import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/components/custom_elevated_btn.dart';
import '/components/custom_textform.dart';
import '/provider/user_provider.dart';
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
          content: SizedBox(
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Username",
                      style: TextStyle(fontSize: 24),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                CustomTextFormField(
                  controller: _usernameController,
                  labelText: '',
                ),
                CustomElevatedBtn(
                  onPressed: () async {
                    final newUsername = _usernameController.text;
                    userProvider.setUsername(newUsername);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
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
      body: Consumer<UserProvider>(builder: (context, userProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(children: [
                  CircleAvatar(
                    radius: 80,
                    child: SvgPicture.string(
                      userProvider.profilePict,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          userProvider.updateAvatar();
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
        );
      }),
    );
  }
}
