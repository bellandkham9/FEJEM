/*

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants.dart';
import '../../theme_Provider.dart';
import 'chat/Chat_provider.dart';
import 'chat/chat_screen.dart';

class DetailsNews extends StatelessWidget {
  final String postId;

  DetailsNews({super.key, required this.postId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  final ChatProvider _chatProvider = ChatProvider();

  Future<Map<String, dynamic>?> getPostById(String postId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Posts').doc(postId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print('Post not found');
        return null;
      }
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }

  Future<String?> getUserEmailById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('User').doc(userId).get();
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

  Future<String?> getUserIdByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('User').where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCommentsForPost(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _firestore.collection('Posts').doc(postId).get();
      if (postSnapshot.exists) {
        List<dynamic> comments = postSnapshot['comments'];
        List<Map<String, dynamic>> formattedComments = [];

        for (var comment in comments) {
          String userId = comment['userId'];
          String userEmail = await getUserEmailById(userId) ?? 'Unknown';
          Map<String, dynamic> formattedComment = {
            'userId': userId,
            'userEmail': userEmail,
            'commentText': comment['commentText'],
            'timestamp': comment['timestamp'],
          };
          formattedComments.add(formattedComment);
        }

        return formattedComments;
      } else {
        print('Post not found');
        return null;
      }
    } catch (e) {
      print('Error getting comments: $e');
      return null;
    }
  }

  Future<void> addComment(BuildContext context, String postId, String commentText) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      Timestamp timestamp = Timestamp.now();

      final comment = {
        'userId': currentUser.uid,
        'commentText': commentText,
        'timestamp': timestamp,
      };

      final DocumentReference postRef = _firestore.collection('Posts').doc(postId);

      try {
        await postRef.update({
          'comments': FieldValue.arrayUnion([comment]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final ScrollController controller = ScrollController();

    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
      appBar: AppBar(
        title: const Text(
          'News Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getPostById(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Error fetching post data"));
          }

          final postData = snapshot.data!;
          final String titre = postData['titre'] ?? 'No title';
          final String sousTitre = postData['sousTitre'] ?? 'No subtitle';
          final String description = postData['description'] ?? 'No description';
          final String imgPost = postData['imgPost'] ?? 'https://via.placeholder.com/150';

          return Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.40,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imgPost),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 65,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              titre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sousTitre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("assets/images/logo.png"),
                          ),
                      ListTile(
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite,
                            color: secondaryColor,
                          ),
                        ),
                        title: Text("100K"),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Scrollbar(
                  controller: controller,
                  child: ListView.builder(
                    controller: controller,
                    itemCount: 1, // Only one item with the full description
                    itemBuilder: (BuildContext context, int index) {
                      final uiProvider = Provider.of<UiProvider>(context);
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              description,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: uiProvider.isDark ? Colors.grey : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: uiProvider.isDark ? Colors.grey : Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 2,
                child: Scrollbar(
                  controller: controller,
                  child: FutureBuilder<List<Map<String, dynamic>>?>(
                    future: getCommentsForPost(postId),
                    builder: (context, commentsSnapshot) {
                      if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!commentsSnapshot.hasData || commentsSnapshot.data == null) {
                        return const Center(child: Text("No comments"));
                      }

                      return ListView.builder(
                        controller: controller,
                        itemCount: commentsSnapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic>? comment = commentsSnapshot.data![index];
                          String emailComment = comment['userEmail'];
                          String commentText = comment['commentText'];
                          String userId = comment['userId'];
                          String initialLetter = emailComment.isNotEmpty ? emailComment[0].toUpperCase() : "";

                          return GestureDetector(
                            onTap: () async {
                              final chatId = await _chatProvider.getChatRoom(userId) ?? await _chatProvider.createChatRoom(userId);
                              if (chatId != null && chatId.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      chatId: chatId,
                                      receiverId: userId,
                                    ),
                                  ),
                                );
                              } else {
                                print('Failed to create or retrieve chat room');
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                child: Text(initialLetter),
                              ),
                              title: Text(
                                emailComment,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: uiProvider.isDark ? Colors.grey : Colors.grey,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    commentText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: uiProvider.isDark ? Colors.grey : Colors.grey),
                                  ),
                                  if (commentText.length > 100)
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Comment'),
                                            content: Text(commentText),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text('Show more'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Write a comment...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        if (_auth.currentUser != null) {
                          await addComment(context, postId, _commentController.text);
                          _commentController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to comment.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants.dart';
import '../../theme_Provider.dart';
import 'chat/Chat_provider.dart';
import 'chat/chat_screen.dart';

class DetailsNews extends StatefulWidget {
  final String postId;

  DetailsNews({Key? key, required this.postId}) : super(key: key);

  @override
  _DetailsNewsState createState() => _DetailsNewsState();
}

class _DetailsNewsState extends State<DetailsNews> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  final ChatProvider _chatProvider = ChatProvider();
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getPostById(String postId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('Posts').doc(postId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print('Post not found');
        return null;
      }
    } catch (e) {
      print('Error getting post: $e');
      return null;
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

  Future<List<Map<String, dynamic>>?> getCommentsForPost(String postId) async {
    try {
      DocumentSnapshot postSnapshot =
          await _firestore.collection('Posts').doc(postId).get();
      if (postSnapshot.exists) {
        List<dynamic> comments = postSnapshot['comments'];
        List<Map<String, dynamic>> formattedComments = [];

        for (var comment in comments) {
          String userId = comment['userId'];
          String userEmail = await getUserEmailById(userId) ?? 'Unknown';
          Map<String, dynamic> formattedComment = {
            'userId': userId,
            'userEmail': userEmail,
            'commentText': comment['commentText'],
            'timestamp': comment['timestamp'],
          };
          formattedComments.add(formattedComment);
        }

        return formattedComments;
      } else {
        print('Post not found');
        return null;
      }
    } catch (e) {
      print('Error getting comments: $e');
      return null;
    }
  }

  Future<void> addComment(
      BuildContext context, String postId, String commentText) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      Timestamp timestamp = Timestamp.now();

      final comment = {
        'userId': currentUser.uid,
        'commentText': commentText,
        'timestamp': timestamp,
      };

      final DocumentReference postRef =
          _firestore.collection('Posts').doc(postId);

      try {
        await postRef.update({
          'comments': FieldValue.arrayUnion([comment]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in.'),
        ),
      );
    }
  }

  Future<void> toggleLikePost(
      BuildContext context, String postId, bool isLiked) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final DocumentReference postRef =
          _firestore.collection('Posts').doc(postId);

      try {
        if (isLiked) {
          await postRef.update({
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([currentUser.uid]),
          });
        } else {
          await postRef.update({
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([currentUser.uid]),
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);


    return Scaffold(
      backgroundColor: uiProvider.isDark
          ? uiProvider.darkTheme.primaryColorDark
          : Colors.white,
      appBar: AppBar(
        title: const Text(
          'News Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getPostById(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Error fetching post data"));
          }

          final postData = snapshot.data!;

          //c'est juste un test
          final QuillController _descriptionController = QuillController(
            document: Document.fromDelta(Delta.fromJson(postData['description'])),
            selection: const TextSelection.collapsed(offset: 0),
          );;
          //fin du test


          final String titre = postData['titre'] ?? 'No title';
          final String sousTitre = postData['sousTitre'] ?? 'No subtitle';
          /*final String description =
              postData['description'] ?? 'No description';*/
          final String imgPost =
              postData['imgPost'] ?? 'https://via.placeholder.com/150';
          final int likes = postData['likes'] ?? 0;
          final List likedBy = postData['likedBy'] ?? [];
          final bool isLiked = likedBy.contains(_auth.currentUser?.uid);

          return Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.40,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imgPost),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 65,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              titre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sousTitre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/logo.png"),
                      ),
                     Padding(
                       padding: const EdgeInsets.all(12.0),
                       child: Row(
                         children: [
                           IconButton(
                             onPressed: () async {
                               await toggleLikePost(
                                   context, widget.postId, isLiked);
                               setState(() {});
                             },
                             icon: Icon(
                               isLiked ? Icons.favorite : Icons.favorite_border,
                               color: secondaryColor,
                             ),
                           ),
                           Text("$likes"),
                         ],
                       ),
                     )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Scrollbar(
                  controller: _controller,
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: 1, // Only one item with the full description
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            /*QuillEditor.basic(
                              controller: _descriptionController,
                              readOnly: true, // Make it read-only
                            ),*/

                            QuillEditor.basic(
                                configurations: QuillEditorConfigurations(
                                    controller: _descriptionController,
                                    checkBoxReadOnly: false,
                                    sharedConfigurations:
                                    const QuillSharedConfigurations(locale: Locale('de')))),
                           /* Text(
                              description,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: uiProvider.isDark
                                    ? Colors.grey
                                    : Colors.grey,
                              ),
                            ),*/
                            SizedBox(height: 20.0),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: uiProvider.isDark ? Colors.grey : Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 2,
                child: Scrollbar(
                  controller: _controller,
                  child: FutureBuilder<List<Map<String, dynamic>>?>(
                    future: getCommentsForPost(widget.postId),
                    builder: (context, commentsSnapshot) {
                      if (commentsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!commentsSnapshot.hasData ||
                          commentsSnapshot.data == null) {
                        return const Center(child: Text("No comments"));
                      }

                      return ListView.builder(
                        controller: _controller,
                        itemCount: commentsSnapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic>? comment =
                              commentsSnapshot.data![index];
                          String emailComment = comment['userEmail'];
                          String commentText = comment['commentText'];
                          String userId = comment['userId'];
                          String initialLetter = emailComment.isNotEmpty
                              ? emailComment[0].toUpperCase()
                              : "";

                          return GestureDetector(
                            onTap: () async {
                              final chatId = await _chatProvider
                                      .getChatRoom(userId) ??
                                  await _chatProvider.createChatRoom(userId);
                              if (chatId != null && chatId.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      chatId: chatId,
                                      receiverId: userId,
                                    ),
                                  ),
                                );
                              } else {
                                print('Failed to create or retrieve chat room');
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                child: Text(initialLetter),
                              ),
                              title: Text(
                                emailComment,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: uiProvider.isDark
                                      ? Colors.grey
                                      : Colors.grey,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    commentText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: uiProvider.isDark
                                            ? Colors.grey
                                            : Colors.grey),
                                  ),
                                  if (commentText.length > 100)
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Comment'),
                                            content: Text(commentText),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text('Show more'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Write a comment...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        if (_auth.currentUser != null) {
                          await addComment(
                              context, widget.postId, _commentController.text);
                          _commentController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to comment.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
