/*
import 'package:adminfejem/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../theme_Provider.dart';
import 'Chat_provider.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _searchStream;

  User? loggedInUser;
  String searchQuery = '';

  Stream<QuerySnapshot> searchUsers(String query) {
    if(query==''){
      return _firestore
          .collection("User")
          .where('isLeader',isEqualTo: true)
          .snapshots();
    }
    else{
      return _firestore
          .collection("User")
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .where('isLeader',isEqualTo: true)
          .snapshots();
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    _searchStream = searchUsers('');
  }

  void getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }



  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white70,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Search Users"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration:  InputDecoration(
                hintText: "search users...",
                prefixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Déclenche la recherche lorsque l'utilisateur appuie sur l'icône de recherche
                    _startSearch();
                  },
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: handleSearch,
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream:  _searchStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final users = snapshot.data!.docs;
              List<UserTile> userWidgets = [];

              for (var user in users) {
                final userData = user.data() as Map<String, dynamic>;
                if (userData['id'] != loggedInUser?.uid) {
                  final userId = userData['id'] ?? '';
                  if (userId.isEmpty) {
                    continue;
                  }
                  final userWidget = UserTile(
                    userId: userId,
                    name: userData['name'] ?? 'No Name',
                    email: userData['email'] ?? 'No Email',
                    imageUrl:
                        userData['imgUrl'] ?? 'https://via.placeholder.com/150',
                  );
                  userWidgets.add(userWidget);
                }
              }
              return ListView(
                children: userWidgets,
              );
            },
          ))
        ],
      ),
    );
  }

  void _startSearch() {
    setState(() {
      // Mettre à jour le Stream avec la nouvelle requête de recherche
      _searchStream = searchUsers(_searchController.text);
    });
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;

  const UserTile(
      {super.key,
      required this.userId,
      required this.name,
      required this.email,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(name),
      subtitle: Text(email),
      onTap: () async {
        final chatId = await chatProvider.getChatRoom(userId) ??
            await chatProvider.createChatRoom(userId);
        if (chatId != null && chatId.isNotEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chatId,
                  receiverId: userId,
                ),
              ));
        } else {
          print('Failed to create or retrieve chat room');
        }
      },
    );
  }

}
*/


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../theme_Provider.dart';
import 'Chat_provider.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _searchStream;

  User? loggedInUser;
  String searchQuery = '';

  Stream<QuerySnapshot> searchUsers(String query) {
    if (query.isEmpty) {
      return _firestore
          .collection("User")
          .where('isLeader', isEqualTo: true)
          .snapshots();
    } else {
      return _firestore
          .collection("User")
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .where('isLeader', isEqualTo: true)
          .snapshots();
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _searchStream = searchUsers('');
  }

  void getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
      _searchStream = searchUsers(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white70,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Search Users"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: handleSearch,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                final users = snapshot.data!.docs;
                List<UserTile> userWidgets = [];

                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  if (userData['id'] != loggedInUser?.uid) {
                    final userId = userData['id'] ?? '';
                    if (userId.isEmpty) {
                      continue;
                    }
                    final userWidget = UserTile(
                      userId: userId,
                      name: userData['name'] ?? 'No Name',
                      email: userData['email'] ?? 'No Email',
                      imageUrl: userData['imgUrl'] ?? 'https://via.placeholder.com/150',
                    );
                    userWidgets.add(userWidget);
                  }
                }

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  children: userWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startSearch() {
    setState(() {
      _searchStream = searchUsers(_searchController.text);
    });
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;

  const UserTile({
    Key? key,
    required this.userId,
    required this.name,
    required this.email,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(name),
      subtitle: Text(email),
      onTap: () async {
        final chatId = await chatProvider.getChatRoom(userId) ?? await chatProvider.createChatRoom(userId);
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
    );
  }
}
