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
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserProvider>(context, listen: false).fetchOtherUsers());
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.deepPurple,
              ),
              child: const Center(
                child: Text(
                  "Cari Anggota Lainnya",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
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
                        // TODO: implement a view user detail trailing button only for administrator
                      );
                    }),
          ),
        ],
      ),
    );
  }
}
