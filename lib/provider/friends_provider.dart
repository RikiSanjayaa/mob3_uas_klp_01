import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsProvider with ChangeNotifier {
  List<DocumentSnapshot> _friendRequests = [];
  List<DocumentSnapshot> _requestUsers = [];
  List<DocumentSnapshot> _friends = [];
  List<DocumentSnapshot> _otherUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<DocumentSnapshot> get friendRequests => _friendRequests;
  List<DocumentSnapshot> get requestUsers => _requestUsers;
  List<DocumentSnapshot> get friends => _friends;
  List<DocumentSnapshot> get otherUsers => _otherUsers;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  FriendsProvider() {
    _fetchUsers();
    _fetchFriendRequests();
  }

  Future<void> _fetchUsers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch all users
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isNotEqualTo: user.email)
            .get();
        final allUsers = userQuerySnapshot.docs;

        // Fetch friends
        final friendsSnapshot = await FirebaseFirestore.instance
            .collection('friends')
            .where('user1', isEqualTo: user.uid)
            .get();
        final friendIds =
            friendsSnapshot.docs.map((doc) => doc['user2']).toList();

        // Filter friends and other users
        _friends =
            allUsers.where((user) => friendIds.contains(user.id)).toList();
        _otherUsers =
            allUsers.where((user) => !friendIds.contains(user.id)).toList();

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch users: $e';
      _isLoading = false;
      notifyListeners();
    }
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
        _friendRequests = friendRequestsSnapshot.docs;

        final requester = _friendRequests.map((doc) => doc['from']).toList();
        if (requester.isNotEmpty) {
          final userQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: requester)
              .get();
          _requestUsers = userQuerySnapshot.docs;
        }

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch friend requests: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendFriendRequest(String friendId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'from': user.uid,
        'to': friendId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _otherUsers.removeWhere((user) => user.id == friendId);
      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest(String requestId, String fromUserId) async {
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
        _friendRequests.removeWhere((doc) => doc.id == requestId);
        _requestUsers.removeWhere((doc) => doc.id == fromUserId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to accept friend request: $e';
      notifyListeners();
    }
  }

  Future<void> rejectFriendRequest(String requestId, String fromUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({'status': 'rejected'});

      // Remove the request from the list
      _friendRequests.removeWhere((doc) => doc.id == requestId);
      _requestUsers.removeWhere((doc) => doc.id == fromUserId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reject friend request: $e';
      notifyListeners();
    }
  }
}
