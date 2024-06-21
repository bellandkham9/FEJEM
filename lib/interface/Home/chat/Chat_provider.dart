import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


class ChatProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChats(String userId) {
    return _firestore
        .collection("chats")
        .where('users', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> searchUsers(String query) {
    return _firestore
        .collection("User")
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
  }
  Future<void> sendMessage(
      String chatId, String message, String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'isRead': false,
        'receiver': receiverId,
        'messageBody': message,
        'timestamp': FieldValue.serverTimestamp()
      });

      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'users': [currentUser.uid, receiverId],
        'lastMessage': message,
        'isRead': false, // Assurez-vous que isRead est initialisé
        'timestamp': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));

    }
  }


  Future<bool> markMessagesAsRead(String chatId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiver', isEqualTo: currentUser.uid) // Ensure only the receiver can mark as read
          .where('isRead', isEqualTo: false)
          .get();


      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({'isRead': true});
        }
        // Also mark the last message in the chat document itself as read
        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
          'isRead': true,
        });
        return true;
      }
    }
    return false;
  }



  Future<String?> getChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatQuery = await _firestore
          .collection("chats")
          .where('users', arrayContains: currentUser.uid)
          .get();
      final chats = chatQuery.docs
          .where((chat) => chat['users'].contains(receiverId))
          .toList();

      if (chats.isNotEmpty) {
        return chats.first.id;
      }
    }
    return null;
  }

  Future<String?> createChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chaRoom = await _firestore.collection("chats").add({
        'users': [currentUser.uid, receiverId],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp()
      });
      return chaRoom.id;
    }
    return null;
  }
}
