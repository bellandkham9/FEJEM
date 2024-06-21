
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LinkProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getLink() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore.collection('Links').snapshots();
    } else {
      return Stream.empty();
    }
  }

  Future<void> addLink(String linkId, Map<String, dynamic> linkInfo) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('Links').doc(linkId).set({
        'leaderId': currentUser.uid,
        'imgLink': linkInfo['imgLink'],
        'titre': linkInfo['titre'],
        'description': linkInfo['description'],
        'lien': linkInfo['lien'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteLink(String linkId) async {
    await _firestore.collection('Links').doc(linkId).delete();
  }
}