import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/provider/user_provider.dart';
import 'package:provider/provider.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final filteredUsers = userProvider.otherUsers.where((user) {
      final email = user['email'] as String;
      return email.contains(_searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search User by Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                }),
          ),
          Expanded(
            child: userProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: SvgPicture.string(
                            user['profile-pict'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email']),
                        trailing: userProvider.role == 'administrator'
                            ? IconButton(
                                onPressed: () {
                                  // TODO: navigator push view user detail here
                                },
                                icon: const Icon(Icons.search))
                            : null,
                      );
                    }),
          ),
        ],
      ),
    );
  }
}
