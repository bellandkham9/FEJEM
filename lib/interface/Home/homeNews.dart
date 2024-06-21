
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants.dart';
import '../../theme_Provider.dart';
import '../admin/AllNews/table.dart';
import '../admin/Post/post_provider.dart';
import '../admin/Post/updatePost.dart';
import 'DetailsNews.dart';

class HomeNews extends StatelessWidget {
  final bool isLeader;

   HomeNews({Key? key, required this.isLeader}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getPostData(String postId) async {
    final snapshot = await PostProvider().getPostById(postId).first;
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Future<String?> getUserEmailById(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('User').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['email'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  Future<bool> savePost(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('User not logged in');
      return false;
    }

    final DocumentReference postRef =
    _firestore.collection('Posts').doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(postRef);

        if (!snapshot.exists) {
          throw Exception("Post does not exist!");
        }

        int newLikes = (snapshot['save'] ?? 0);
        List<String> likedBy =
        List<String>.from(snapshot['saveBy'] ?? []);

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
      print('Error saving post: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        backgroundColor: uiProvider.isDark
            ? uiProvider.darkTheme.primaryColorDark
            : Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 10.0),
            Expanded(
              flex: 2,
              child: StreamBuilder<QuerySnapshot>(
                stream: PostProvider().getPost(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final postDocs = snapshot.data!.docs;

                  return CarouselSlider(
                    items: postDocs.map((doc) {
                      final postData =
                      doc.data() as Map<String, dynamic>;
                      return FutureBuilder<String?>(
                        future: getUserEmailById(postData['leaderId']),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return ImageTextBox(
                            postId: doc.id,
                            imagePath: postData['imgPost'] ??
                                'assets/images/placeholder.png',
                            title: postData['title'] ?? 'No title',
                            subtitle: postData['subtitle'] ??
                                'No subtitle',
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 230.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration:
                      const Duration(milliseconds: 800),
                      viewportFraction: 0.8,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5.0),
            const Padding(
              padding: EdgeInsetsDirectional.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Latest News",
                    style: TextStyle(
                      fontSize: 18,
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: TableAlNews(isAdmim: isLeader),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageTextBox extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String postId;

  const ImageTextBox({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsNews(
                postId: postId),
          ),
        );
      },
      child: Container(
        width: 320.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          image: DecorationImage(
            image: imagePath.startsWith('http')
                ? NetworkImage(imagePath)
                : AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            Positioned(
              bottom: 8.0,
              left: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
