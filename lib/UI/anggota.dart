import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mob3_uas_klp_01/provider/friends_provider.dart';
import 'package:provider/provider.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  bool _showFriends = false;

  @override
  Widget build(BuildContext context) {
    final friendsProvider = Provider.of<FriendsProvider>(context);

    return friendsProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showFriends = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: _showFriends
                                ? Theme.of(context).colorScheme.secondary
                                : const Color.fromARGB(255, 150, 11, 242)),
                        child: const Text(
                          "Anggota Lain",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showFriends = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: _showFriends
                                ? const Color.fromARGB(255, 150, 11, 242)
                                : Theme.of(context).colorScheme.secondary),
                        child: const Text(
                          "Teman",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _showFriends
                      ? friendsProvider.friends.length
                      : friendsProvider.otherUsers.length,
                  itemBuilder: (context, index) {
                    final user = _showFriends
                        ? friendsProvider.friends[index]
                        : friendsProvider.otherUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: SvgPicture.string(
                          user['profile-pict'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(user['username']),
                      subtitle: Text(user['email']),
                      trailing: _showFriends
                          ? null
                          : IconButton(
                              onPressed: () {
                                friendsProvider.sendFriendRequest(user.id);
                              },
                              icon: const Icon(Icons.add),
                            ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
