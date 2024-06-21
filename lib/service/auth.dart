import 'dart:io';

import 'package:adminfejem/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Home.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: "gs://fejemproject.appspot.com");


  getCurrentUser() async {
    return await auth.currentUser;
  }

  Future<Map<String, dynamic>> getUserInfo(String? email) async {
    final userCollection = FirebaseFirestore.instance.collection('User');
    try {
      final userDoc = await userCollection.where('email', isEqualTo: email).get();
      final userData = userDoc.docs.first.data() as Map<String, dynamic>;
      return userData;
    } catch (error) {
      print("Error fetching user info: $error");
      // Handle the error appropriately (e.g., show a snackbar to the user)
      throw error; // Or return a default Map with null values
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();
      if (googleSignInAccount == null) {
        throw Exception('Google sign-in aborted or failed.');
      }

      final GoogleSignInAuthentication? googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      UserCredential result = await firebaseAuth.signInWithCredential(
          credential);
      User? userDetails = result.user;

      // Get additional user info from Firestore based on email
      final userInfo = await getUserInfo(userDetails!.email);

      // Update userInfoMap with isLeader value from Firestore
      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
        "isLeader": userInfo['isLeader'],
        // Assuming 'isLeader' is a field in your Firestore document
        "id": userDetails.uid,
      };
      await DatabaseMethods()
          .addUser(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.push(
            context, MaterialPageRoute(
            builder: (context) => NewsScreen(userInfo: userInfoMap)));
      });
      return userInfoMap;
    } catch (e) {
      print('Error signing in with Google: $e');
      // Handle the error appropriately (e.g., show a snackbar to the user)
      throw e;
    }
  }

  Future<String> uploadImageToStorage(String userId, File imageFile) async {
    try {
      Reference ref = storage.ref().child('userImages').child(userId);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userInfo) async {
    if (userInfo['imgUrl'] != null && userInfo['imgUrl'] is File) {
      File imageFile = userInfo['imgUrl'];
      print('show me please: $imageFile');
      String imageUrl = await uploadImageToStorage(userId, imageFile);
      userInfo['imgUrl'] = imageUrl;
    }
    try {
      await FirebaseFirestore.instance.collection('User').doc(userId).update(userInfo);
      print('User information updated successfully');
    } catch (e) {
      print('Error updating user information: $e');
    }
  }

}
