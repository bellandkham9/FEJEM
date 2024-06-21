/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../admin/Post/post_provider.dart';
import '../../theme_Provider.dart';
import 'DetailsNews.dart';

class SavedNews extends StatelessWidget {
  SavedNews({Key? key}) : super(key: key);
  final ScrollController controller = ScrollController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> savePost(String postId) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      print('User not logged in');
      return false;
    }

    final DocumentReference postRef = _firestore.collection('Posts').doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(postRef);

        if (!snapshot.exists) {
          throw Exception("Post does not exist!");
        }

        int newLikes = (snapshot['save'] ?? 0);
        List<String> likedBy = List<String>.from(snapshot['saveBy'] ?? []);

        if (!likedBy.contains(currentUser.uid)) {
          likedBy.add(currentUser.uid);
          newLikes++;
        } else {
          likedBy.remove(currentUser.uid);
          newLikes--;
        }

        transaction.update(postRef, {'save': newLikes, 'saveBy': likedBy});
      });
      return true;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  Future<List<DocumentSnapshot>> getLikedPostsByUser(String userId) async {
    final QuerySnapshot snapshot = await _firestore.collection('Posts').where('saveBy', arrayContains: userId).get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final User? currentUser = auth.currentUser;


    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to see saved news.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: getLikedPostsByUser(currentUser.uid),
                builder: (context, likedPostsSnapshot) {
                  if (likedPostsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!likedPostsSnapshot.hasData || likedPostsSnapshot.data!.isEmpty) {
                    return const Center(child: Text("No liked posts found"));
                  }

                  final likedPosts = likedPostsSnapshot.data!;

                  return ListView.builder(
                    itemCount: likedPosts.length,
                    itemBuilder: (context, index) {
                      final postData = likedPosts[index].data() as Map<String, dynamic>;
                      final postId = likedPosts[index].id;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsNews(postId:postId),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                postData['imgPost'] != null
                                    ? Image.network(postData['imgPost'], height: 65, width: 65)
                                    : const Image(image: AssetImage("assets/images/house.jpg"), width: 90, height: 90),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    height: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          postData['titre'] ?? "No title",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          postData['sousTitre'] ?? "No subtitle",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    bool success = await savePost(postId);
                                    String message = success
                                        ? 'Post saved successfully!'
                                        : 'Failed to like the post. Please try again.';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                      ),
                                    );
                                  },
                                  icon:  Icon(Icons.save, color: postData['save']==1? secondaryColor:Colors.black,),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants.dart';
import '../../theme_Provider.dart';
import '../admin/Post/post_provider.dart';
import 'DetailsNews.dart';

class SavedNews extends StatelessWidget {
  SavedNews({Key? key}) : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> savePost(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('User not logged in');
      return false;
    }

    final DocumentReference postRef = _firestore.collection('Posts').doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(postRef);

        if (!snapshot.exists) {
          throw Exception("Post does not exist!");
        }

        int newSaveCount = (snapshot['save'] ?? 0);
        List<String> savedBy = List<String>.from(snapshot['saveBy'] ?? []);

        if (!savedBy.contains(currentUser.uid)) {
          savedBy.add(currentUser.uid);
          newSaveCount++;
        } else {
          savedBy.remove(currentUser.uid);
          newSaveCount--;
        }

        transaction.update(postRef, {'save': newSaveCount, 'saveBy': savedBy});
      });
      return true;
    } catch (e) {
      print('Error saving post: $e');
      return false;
    }
  }

  Future<List<DocumentSnapshot>> getLikedPostsByUser(String userId) async {
    final QuerySnapshot snapshot = await _firestore.collection('Posts').where('saveBy', arrayContains: userId).get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('Please log in to see saved news.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: getLikedPostsByUser(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No liked posts found"));
                  }

                  final likedPosts = snapshot.data!;

                  return ListView.builder(
                    itemCount: likedPosts.length,
                    itemBuilder: (context, index) {
                      final postData = likedPosts[index].data() as Map<String, dynamic>;
                      final postId = likedPosts[index].id;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsNews(postId: postId),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                postData['imgPost'] != null
                                    ? Image.network(postData['imgPost'], height: 65, width: 65)
                                    : Image.asset("assets/images/house.jpg", width: 90, height: 90),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        postData['titre'] ?? "No title",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        postData['sousTitre'] ?? "No subtitle",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    bool success = await savePost(postId);
                                    String message = success
                                        ? 'Post saved successfully!'
                                        : 'Failed to save the post. Please try again.';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.save,
                                    color: postData['save'] == 1 ? secondaryColor : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
