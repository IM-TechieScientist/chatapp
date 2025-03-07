import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/reaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data()['email'] != _auth.currentUser!.email)
          .map((doc) => doc.data())
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('blocked_users')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUsersIds = snapshot.docs.map((doc) => doc.id).toList();

      final usersSnapshot = await _firestore.collection('users').get();

      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != _auth.currentUser!.email &&
              !blockedUsersIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message, {String? quotedMessageId, String? quotedMessageText}) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      quotedMessageId: quotedMessageId,
      quotedMessageText: quotedMessageText,
    );

    String chatRoomID = _generateChatRoomId(currentUserID, receiverID);

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    String chatRoomID = _generateChatRoomId(userID, otherUserID);

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('reports').add(report);
  }

  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('blocked_users')
        .doc(userId)
        .set({});
    notifyListeners();
  }

  Future<void> unblockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('blocked_users')
        .doc(userId)
        .delete();
    notifyListeners();
  }

  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('blocked_users')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUsersIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(blockedUsersIds
          .map((id) => _firestore.collection('users').doc(id).get()));

      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> addReaction(String userId1, String userId2, String messageId, String emoji) async {
    final currentUser = _auth.currentUser;
    final reaction = Reaction(emoji: emoji, userId: currentUser!.uid);

    String chatRoomID = _generateChatRoomId(userId1, userId2);

    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .doc(messageId);

    // Log the document path
    print('Document path: chat_rooms/$chatRoomID/messages/$messageId');

    // Check if the document exists
    final docSnapshot = await messageRef.get();
    if (!docSnapshot.exists) {
      print('Message does not exist!');
      return;
    }

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(messageRef);

      if (!snapshot.exists) {
        throw Exception("Message does not exist!");
      }

      List<dynamic> reactions = snapshot.data()!['reactions'] ?? [];
      reactions.add(reaction.toMap());

      transaction.update(messageRef, {'reactions': reactions});
    });
  }
}