import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mob3_uas_klp_01/backend/int_to_rupiah.dart';
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

  void showUserDetailsDialog(BuildContext context, String userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder(
              future: userProvider.fetchUserDetails(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching user details'));
                } else if (!snapshot.hasData ||
                    snapshot.data!['user'] == null) {
                  return const Center(child: Text('No user details found'));
                } else {
                  final userDetails = snapshot.data!;
                  final user = userDetails['user'];
                  final pinjaman = userDetails['pinjaman'];
                  final angsuran = userDetails['angsuran'];
                  final DateFormat dateFormat = DateFormat('d MMMM yyyy');

                  return AlertDialog(
                    title: Row(children: [
                      CircleAvatar(
                        child: SvgPicture.string(
                          user['profile-pict'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(user['username']),
                    ]),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: [
                          Text('Email: ${user['email']}'),
                          Text(
                              'Account Status: ${user['isActive'] ? 'Active' : 'Inactive'}'),
                          const SizedBox(height: 16),
                          if (pinjaman != null) ...[
                            const Text('Active Pinjaman:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                'Besar Pinjaman: ${formatToRP(pinjaman['besar-pinjaman'])}'),
                            Text(
                                'Lama pinjaman: ${pinjaman['lama-angsuran']} bulan'),
                            Text('Besar bunga: ${pinjaman['besar-bunga']}%'),
                            Text(
                                'Lunas: ${formatToRP(pinjaman['total-angsuran'])}'),
                            Text(
                                'Angsuran perbulan: ${formatToRP(pinjaman['angsuran-perbulan'])}'),
                            Text(
                                'Tanggal meminjam: ${dateFormat.format((pinjaman['tanggal-peminjaman'] as Timestamp).toDate())}'),
                            const SizedBox(height: 16),
                          ],
                          if (angsuran != null) ...[
                            const Text('Active Angsuran:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                'Besar angsuran: ${formatToRP(angsuran['besar-angsuran'])}'),
                            Text('Angsuran ke: ${angsuran['angsuran-ke']}'),
                            Text(
                                'Jatuh tempo tanggal: ${dateFormat.format((angsuran['jatuh-tempo'] as Timestamp).toDate())}'),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await userProvider.toggleAccountStatus(
                              userId, user['isActive']);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(user['isActive']
                            ? 'Deactivate Account'
                            : 'Activate Account'),
                      ),
                    ],
                  );
                }
              });
        });
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
                                  showUserDetailsDialog(context, user.id);
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
