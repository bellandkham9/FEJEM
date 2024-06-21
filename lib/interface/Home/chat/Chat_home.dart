/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adminfejem/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../../../theme_Provider.dart';
import '../../../theme_Provider.dart';
import '../../../theme_Provider.dart';
import 'Chat_provider.dart';
import 'Search_Screen.dart';
import 'chat_tile.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? loggedInUser;



  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToNotifications();
    getCurrentUser();
  }

  Future<String?> getUserEmailById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('User').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get("email");
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }
  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('logo');

    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    final bool? result = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.notificationResponseType == NotificationResponseType.selectedNotification) {
          print('Notification clicked!');
        }
      },
    );

    if (result == false) {
      print('Failed to initialize notifications');
    } else {
      print('Notifications initialized successfully');
    }
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance.collection('chats').snapshots().listen((chatsSnapshot) {
      for (var chatDoc in chatsSnapshot.docs) {
        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots()
            .listen((messagesSnapshot) {
          if (messagesSnapshot.docs.isNotEmpty) {
            var messageDoc = messagesSnapshot.docs.first;

            // Récupérer l'utilisateur actuel
            String currentUserId = FirebaseAuth.instance.currentUser!.uid;
            String receiverId = messageDoc['receiver'];
            print("l'utilisateur actuel: "+receiverId+" "+currentUserId+" "+messageDoc['messageBody']);

            // Vérifier si l'utilisateur actuel est le destinataire
            if (receiverId == currentUserId) {
              _showNotification(messageDoc);
            }
          }
        });
      }
    });
  }

  void _showNotification(QueryDocumentSnapshot<Map<String, dynamic>> messageDoc) async {
    print("show notification successful");
    try {
      // Obtenir l'email du sender
      String? senderId = messageDoc.get('senderId') as String?;
      if (senderId != null) {
        String? userEmail = await getUserEmailById(senderId);
        String message = messageDoc.get('messageBody');
        if (userEmail != null) {
          print('Sender Email: $userEmail');

          const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            '001',
            'Local Notification',
            channelDescription: 'To send local notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: "logo",
          );

          const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

          await flutterLocalNotificationsPlugin.show(
            01,
            'NKUU'+' '+userEmail,
            message,
            notificationDetails,
          );
          print('Notification shown successfully');
        } else {
          print('User email not found for senderId: $senderId');
        }
      } else {
        print('senderId is null');
      }
    } catch (e) {
      print('Error showing notification: $e');
    }
  }




  Future<void> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }


  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return {}; // Return empty map if no user is logged in
    }

    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data();
    if (chatData == null) {
      return {}; // Return empty map if chatData is null
    }

    final users = chatData['users'] as List<dynamic>;
    final receiverId = users.firstWhere((id) => id != currentUser.uid);

    final userDoc = await FirebaseFirestore.instance.collection('User').doc(receiverId).get();
    final userData = userDoc.data();

    final isRead = chatData.containsKey('isRead') ? chatData['isRead'] : false; // Get the isRead value

    return {
      'chatId': chatId,
      'lastMessage': chatData['lastMessage'] ?? '',
      'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
      'userData': userData,
      'isRead': isRead, // Add the isRead value to the result
    };
  }


  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white70,
      body: FutureBuilder(
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
                  stream: chatProvider.getChats(loggedInUser!.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final chatDocs = snapshot.data!.docs;
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: Future.wait(chatDocs.map((chatDoc) => _fetchChatData(chatDoc.id))),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final chatDataList = snapshot.data!;
                        return ListView.builder(
                          itemCount: chatDataList.length,
                          itemBuilder: (context, index) {
                            final chatData = chatDataList[index];
                            return ChatTile(
                              chatId: chatData['chatId'] ?? '',
                              lastMessage: chatData['lastMessage'] ?? '',
                              timestamp: chatData['timestamp'],
                              receiverData: chatData['userData'] ?? {},
                              isRead: chatData['isRead'],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../theme_Provider.dart';
import 'Chat_provider.dart';
import 'Search_Screen.dart';
import 'chat_tile.dart';
import 'package:adminfejem/constants.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({Key? key}) : super(key: key);

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User loggedInUser;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToNotifications();
    getCurrentUser();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('logo');

    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    final bool? result = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.notificationResponseType == NotificationResponseType.selectedNotification) {
          print('Notification clicked!');
        }
      },
    );

    if (!result!) {
      print('Failed to initialize notifications');
    } else {
      print('Notifications initialized successfully');
    }
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance.collection('chats').snapshots().listen(
          (chatsSnapshot) {
        for (var chatDoc in chatsSnapshot.docs) {
          FirebaseFirestore.instance
              .collection('chats')
              .doc(chatDoc.id)
              .collection('messages')
              .where('isRead', isEqualTo: false)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots()
              .listen(
                (messagesSnapshot) {
              if (messagesSnapshot.docs.isNotEmpty) {
                var messageDoc = messagesSnapshot.docs.first;

                String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                String receiverId = messageDoc['receiver'];

                if (receiverId == currentUserId) {
                  _showNotification(messageDoc);
                }
              }
            },
          );
        }
      },
    );
  }

  void _showNotification(QueryDocumentSnapshot<Map<String, dynamic>> messageDoc) async {
    try {
      String? senderId = messageDoc.get('senderId') as String?;
      if (senderId != null) {
        String? userEmail = await getUserEmailById(senderId);
        String message = messageDoc.get('messageBody');
        if (userEmail != null) {
          const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            '001',
            'Local Notification',
            channelDescription: 'To send local notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: "logo",
          );

          const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

          await flutterLocalNotificationsPlugin.show(
            01,
            'NKUU $userEmail',
            message,
            notificationDetails,
          );
          print('Notification shown successfully');
        } else {
          print('User email not found for senderId: $senderId');
        }
      } else {
        print('senderId is null');
      }
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<String?> getUserEmailById(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('User').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get("email");
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  Future<void> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return {}; // Return empty map if no user is logged in
    }

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data();
    if (chatData == null) {
      return {}; // Return empty map if chatData is null
    }

    final users = chatData['users'] as List<dynamic>;
    final receiverId = users.firstWhere((id) => id != currentUser.uid);

    final userDoc = await _firestore.collection('User').doc(receiverId).get();
    final userData = userDoc.data();

    final isRead = chatData.containsKey('isRead') ? chatData['isRead'] : false;

    return {
      'chatId': chatId,
      'lastMessage': chatData['lastMessage'] ?? '',
      'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
      'userData': userData,
      'isRead': isRead,
    };
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor:
      uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white70,
      body: FutureBuilder(
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
                  stream: chatProvider.getChats(loggedInUser.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final chatDocs = snapshot.data!.docs;
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: Future.wait(
                          chatDocs.map((chatDoc) => _fetchChatData(chatDoc.id))),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final chatDataList = snapshot.data!;
                        return ListView.builder(
                          itemCount: chatDataList.length,
                          itemBuilder: (context, index) {
                            final chatData = chatDataList[index];
                            return ChatTile(
                              chatId: chatData['chatId'] ?? '',
                              lastMessage: chatData['lastMessage'] ?? '',
                              timestamp: chatData['timestamp'],
                              receiverData: chatData['userData'] ?? {},
                              isRead: chatData['isRead'],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
