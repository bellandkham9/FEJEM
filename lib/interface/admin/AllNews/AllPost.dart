import 'package:adminfejem/interface/admin/Post/updatePost.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus library
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../constants.dart';
import '../../Home/DetailsNews.dart';
import '../Post/post_provider.dart';
import '../../../theme_Provider.dart';

class AllPost extends StatefulWidget {
  final bool isLeader;
  const AllPost({Key? key, required this.isLeader}) : super(key: key);

  @override
  _AllPostState createState() => _AllPostState();
}

class _AllPostState extends State<AllPost> {
  final auth = FirebaseAuth.instance;
  User? loggedInUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  Future<Map<String, dynamic>> getPostData(String postId) async {
    final snapshot = await PostProvider().getPostById(postId).first;
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      return {};
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
      print('Error saving post: $e');
      return false;
    }
  }

  Future<void> sharePost(
      String title, String? imageUrl, BuildContext context) async {
    try {
      // Create a list of files to share (including text and image if available)
      List<XFile> filesToShare = [
        XFile('dummy')
      ]; // Initialize with a dummy XFile

      if (imageUrl != null) {
        // Get the temporary directory
        Directory tempDir = await getTemporaryDirectory();
        String tempImagePath = '${tempDir.path}/temp_image.jpg';

        // Download the image from the URL
        final response = await http.get(Uri.parse(imageUrl));
        File imageFile = File(tempImagePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        // Create an XFile object for the image file
        XFile xImageFile = XFile(tempImagePath);

        // Replace the dummy entry with the actual image file
        filesToShare[0] = xImageFile;
      }

      // Share the files using Share.shareXFiles
      await Share.shareXFiles(
        filesToShare,
        text: title,
      );
    } catch (e) {
      print('Error sharing post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share the post. Please try again.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    return Center(
      child: FutureBuilder(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (loggedInUser == null) {
            return const Center(child: Text("No user logged in"));
          }
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: PostProvider().getPost(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final postDocs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: postDocs.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<Map<String, dynamic>>(
                          future: getPostData(postDocs[index].id),
                          builder: (context, postDataSnapshot) {
                            if (postDataSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!postDataSnapshot.hasData) {
                              return const Center(
                                  child: Text("Error fetching post data"));
                            }
                            final postData = postDataSnapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsNews(
                                          postId: postDocs[index].id),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: uiProvider.isDark
                                        ? Colors.grey.withOpacity(0.3)
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      postData['imgPost'] != null
                                          ? Image.network(postData['imgPost'],
                                              height: 65, width: 65)
                                          :  Image.network('https://via.placeholder.com/150',
                                          height: 65, width: 65),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 25),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                postData['title'] ?? "No title",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                postData['subtitle'] ??
                                                    "No subtitle",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          widget.isLeader ?
                                          IconButton(
                                            onPressed: ()  {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>  UpdatePostScreen(postId: postDocs[index].id,initialData: postData),
                                                ),
                                              );
                                              postProvider.updatePost(postDocs[index].id, postData);
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                            ),
                                          ):IconButton(
                                            onPressed: () async {
                                              if (auth.currentUser != null) {
                                                bool success = await savePost(
                                                    postDocs[index].id);
                                                if (success) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Post saved successfully!'),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Failed to save the post. Please try again.'),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Please log in to save posts.'),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: Icon(
                                              Icons.save,
                                              color: postData['save'] == 1
                                                  ? secondaryColor
                                                  : uiProvider.isDark
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                          widget.isLeader
                                              ? IconButton(
                                                  onPressed: () {
                                                    postProvider.deletePost(
                                                        postDocs[index].id);
                                                 },
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.grey),
                                                )
                                              : IconButton(
                                                  onPressed: () {
                                                    if (postData['imgPost'] !=
                                                        null) {
                                                      sharePost(
                                                          postData['titre'] ??
                                                              "Check out this post",
                                                          postData['imgPost'],
                                                          context);
                                                    } else {
                                                      Share.share(postData[
                                                              'titre'] ??
                                                          "Check out this post");
                                                    }
                                                  },
                                                  icon: const Icon(Icons.share,
                                                      color: Colors.grey),
                                                ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
