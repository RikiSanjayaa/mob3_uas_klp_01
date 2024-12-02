import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  List<DocumentSnapshot> _allUsers = [];
  List<DocumentSnapshot> _friends = [];
  List<DocumentSnapshot> _otherUsers = [];
  bool _isLoading = true;
  bool _showFriends = false;

  @override
  void initState() {
    super.initState();
    _fetchAnggota();
  }

  Future<void> _fetchAnggota() async {
    try {
      // fetch all users
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isNotEqualTo: user.email)
            .get();
        _allUsers = userQuerySnapshot.docs;

        //fetch friends
        final friendsSnapshot = await FirebaseFirestore.instance
            .collection('friends')
            .where('user1', isEqualTo: user.uid)
            .get();
        final friendIds =
            friendsSnapshot.docs.map((doc) => doc['user2']).toList();

        // filter friends and other users
        _friends =
            _allUsers.where((user) => friendIds.contains(user.id)).toList();
        _otherUsers =
            _allUsers.where((user) => !friendIds.contains(user.id)).toList();

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to fetch users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String friendId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'from': user.uid,
        'to': friendId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _otherUsers.removeWhere((user) => user.id == friendId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
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
                  itemCount:
                      _showFriends ? _friends.length : _otherUsers.length,
                  itemBuilder: (context, index) {
                    final user =
                        _showFriends ? _friends[index] : _otherUsers[index];
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
                                _sendFriendRequest(user.id);
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
