import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<DocumentSnapshot> _friendRequests = [];
  List<DocumentSnapshot> _requestUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final friendRequestsSnapshot = await FirebaseFirestore.instance
            .collection('friend_requests')
            .where('to', isEqualTo: user.uid)
            .where('status', isEqualTo: 'pending')
            .get();
        setState(() {
          _friendRequests = friendRequestsSnapshot.docs;
        });
        await _fetchRequestUser();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch friend requests: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRequestUser() async {
    try {
      final requester = _friendRequests.map((doc) => doc['from']).toList();
      if (requester.isNotEmpty) {
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: requester)
            .get();
        setState(() {
          _requestUsers = userQuerySnapshot.docs;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch request users: $e';
      });
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String fromUserId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('friend_requests')
            .doc(requestId)
            .update({'status': 'accepted'});

        // Add to friends list
        await FirebaseFirestore.instance.collection('friends').add({
          'user1': user.uid,
          'user2': fromUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Remove the request from the list
        setState(() {
          _friendRequests.removeWhere((doc) => doc.id == requestId);
          _requestUsers.removeWhere((doc) => doc.id == fromUserId);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to accept friend request: $e';
      });
    }
  }

  Future<void> _rejectFriendRequest(String requestId, String fromUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({'status': 'rejected'});

      // Remove the request from the list
      setState(() {
        _friendRequests.removeWhere((doc) => doc.id == requestId);
        _requestUsers.removeWhere((doc) => doc.id == fromUserId);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to reject friend request: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _requestUsers.isEmpty
                  ? const Center(child: Text("No friend requests"))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _requestUsers.length,
                            itemBuilder: (context, index) {
                              final request = _friendRequests[index];
                              final fromUserId = request['from'];
                              final user = _requestUsers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: SvgPicture.string(
                                    user['profile-pict'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(user['username']),
                                subtitle: Text(user['email']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _rejectFriendRequest(
                                            request.id, fromUserId);
                                      },
                                      child: const Text(
                                        "Reject",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _acceptFriendRequest(
                                            request.id, fromUserId);
                                      },
                                      child: const Text(
                                        "Accept",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
