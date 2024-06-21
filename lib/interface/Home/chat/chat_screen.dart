/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme_Provider.dart';
import 'Chat_provider.dart';
import 'package:adminfejem/constants.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? loggedInUser;
  String? chatId;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    final TextEditingController _textController = TextEditingController();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('User').doc(widget.receiverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final receiverData = snapshot.data!.data() as Map<String, dynamic>;
            final imgUrl = receiverData['imgUrl'] ?? 'https://via.placeholder.com/150';
            return Scaffold(
              backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(imgUrl),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      receiverData['name'] ?? 'No Name',
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: chatId != null && chatId!.isNotEmpty
                        ? MessageStream(chatId: chatId!)
                        : const Center(
                      child: Text("No Messages yet"),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: "Enter your message...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_textController.text.isNotEmpty) {
                              if (chatId == null || chatId!.isEmpty) {
                                chatId = await chatProvider.createChatRoom(widget.receiverId);
                              }
                              if (chatId != null) {
                                chatProvider.sendMessage(chatId!, _textController.text, widget.receiverId);
                                _textController.clear();
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('User not found'),
              ),
            );
          }
        }
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class MessageStream extends StatelessWidget {
  final String chatId;
  const MessageStream({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];

        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>;

          final messageText = messageData['messageBody'];
          final messageSender = messageData['senderId'];
          final timestamp = messageData['timestamp'] ?? FieldValue.serverTimestamp();

          final currentUser = FirebaseAuth.instance.currentUser!.uid;
          final messageWidget = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            timestamp: timestamp,
          );

          messageWidgets.add(messageWidget);
        }
        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timestamp;
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
              borderRadius: isMe
                  ? const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              )
                  : const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              color: isMe ? primaryColor : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${messageTime.hour}:${messageTime.minute}',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../theme_Provider.dart';
import 'Chat_provider.dart';
import 'package:adminfejem/constants.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receiverId;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;
  String? chatId;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    final TextEditingController _textController = TextEditingController();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('User').doc(widget.receiverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('User not found')),
          );
        }

        final receiverData = snapshot.data!.data() as Map<String, dynamic>;
        final imgUrl = receiverData['imgUrl'] ?? 'https://via.placeholder.com/150';

        return Scaffold(
          backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(imgUrl),
                ),
                const SizedBox(width: 10),
                Text(
                  receiverData['name'] ?? 'No Name',
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: chatId != null && chatId!.isNotEmpty
                    ? MessageStream(chatId: chatId!)
                    : Center(child: Text("No Messages yet")),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: "Enter your message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (_textController.text.isNotEmpty) {
                          if (chatId == null || chatId!.isEmpty) {
                            chatId = await chatProvider.createChatRoom(widget.receiverId);
                          }
                          if (chatId != null) {
                            chatProvider.sendMessage(chatId!, _textController.text, widget.receiverId);
                            _textController.clear();
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MessageStream extends StatelessWidget {
  final String chatId;

  const MessageStream({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Messages yet"));
        }

        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];

        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>;

          final messageText = messageData['messageBody'];
          final messageSender = messageData['senderId'];
          final timestamp = messageData['timestamp'] ?? FieldValue.serverTimestamp();

          final currentUser = FirebaseAuth.instance.currentUser!.uid;
          final messageWidget = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            timestamp: timestamp,
          );

          messageWidgets.add(messageWidget);
        }

        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timestamp;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: isMe ? Radius.circular(15) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(15),
              ),
              color: isMe ? primaryColor : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${messageTime.hour}:${messageTime.minute}',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
