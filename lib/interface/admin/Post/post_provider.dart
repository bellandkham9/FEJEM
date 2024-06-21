import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class PostProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPost() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore.collection('Posts').snapshots();
    } else {
      return Stream.empty();
    }
  }

  Stream<DocumentSnapshot> getPostById(String postId) {
    return _firestore.collection('Posts').doc(postId).snapshots();
  }

  // Method to create a new post
  Future<void> createPost(String postId, Map<String, dynamic> postInfo) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('Posts').doc(postId).set({
        'leaderId': currentUser.uid,
        'imgPost': postInfo['imgUrl'],
        'title': postInfo['title'],
        'subtitle': postInfo['subtitle'],
        'description': postInfo['description'],
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'likes': 0,
        'save': 0,  // Initial like count
        'saveBy': [],
        'comments': [],// Initial like count
         // Initial list of users who liked the post
      });
    }
  }

  // Method to update an existing post
  Future<void> updatePost(String postId, Map<String, dynamic> updatedInfo) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('Posts').doc(postId).update({
        'imgPost': updatedInfo['imgPost'],
        'title': updatedInfo['title'],
        'subtitle': updatedInfo['subtitle'],
        'description': updatedInfo['description'],
        'timestamp': FieldValue.serverTimestamp(), // Optional: Update timestamp
      });
    }
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('Posts').doc(postId).delete();
  }
}
