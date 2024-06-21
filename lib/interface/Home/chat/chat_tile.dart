/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Chat_provider.dart';
import 'Search_Screen.dart';
import 'chat_screen.dart';

class ChatTile extends StatefulWidget {
  final String chatId;
  final String lastMessage;
  final DateTime timestamp;
  final Map<String, dynamic> receiverData;
  final bool isRead; // Nouvelle variable pour stocker isRead

  const ChatTile({
    super.key,
    required this.chatId,
    required this.lastMessage,
    required this.timestamp,
    required this.receiverData,
    required this.isRead,
  }) ;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  // Add a variable to track whether the tile is expanded

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final imgUrl =
        widget.receiverData['imgUrl'] ?? 'https://via.placeholder.com/150';
    final receiverName = widget.receiverData['name'] ?? 'No Name';
    final String lastMessage = widget.lastMessage ?? ""; // Set an empty string if null
    bool isRead = widget.isRead;
    return lastMessage != ""
        ? ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(imgUrl),
            ),
            title: Text(receiverName),
            subtitle: isRead==false
                ? Text(
              lastMessage,
                    maxLines: null, // Allow full message display when expanded
                    style:  TextStyle(fontSize: 16, fontWeight: isRead==false ?  FontWeight.bold: FontWeight.normal),
                  )
                : Text(
                    widget.lastMessage,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.timestamp.hour}:${widget.timestamp.minute}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: ()  async {
              // Mark messages as read
              var rep = await chatProvider.markMessagesAsRead(widget.chatId);
              print("la valeur de isRead $rep");

              setState(() {
                isRead=rep;
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: widget.chatId,
                    receiverId: widget.receiverData['id'],
                  ),
                ),
              );
            },
          )
        : Container();
  }
}
*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Chat_provider.dart';
import 'chat_screen.dart';

class ChatTile extends StatefulWidget {
  final String chatId;
  final String lastMessage;
  final DateTime timestamp;
  final Map<String, dynamic> receiverData;
  final bool isRead;

  const ChatTile({
    Key? key,
    required this.chatId,
    required this.lastMessage,
    required this.timestamp,
    required this.receiverData,
    required this.isRead,
  }) : super(key: key);

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool _isRead = false; // Local state to track if message is read

  @override
  void initState() {
    super.initState();
    _isRead = widget.isRead; // Initialize local state from widget prop
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final imgUrl = widget.receiverData['imgUrl'] ?? 'https://via.placeholder.com/150';
    final receiverName = widget.receiverData['name'] ?? 'No Name';

    return widget.lastMessage.isNotEmpty
        ? ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(imgUrl),
      ),
      title: Text(receiverName),
      subtitle: Text(
        widget.lastMessage,
        maxLines: _isRead ? 2 : null, // Allow full message display when not read
        style: TextStyle(
          fontSize: _isRead ? 14 : 16,
          fontWeight: _isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      trailing: Text(
        '${widget.timestamp.hour}:${widget.timestamp.minute}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () async {
        if (!_isRead) {
          // Only mark as read if it's not already read
          bool isMessageRead = await chatProvider.markMessagesAsRead(widget.chatId);
          setState(() {
            _isRead = isMessageRead;
          });
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: widget.chatId,
              receiverId: widget.receiverData['id'],
            ),
          ),
        );
      },
    )
        : Container(); // Return an empty container if there's no last message
  }
}
