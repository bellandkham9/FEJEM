// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'admin.dart';
// import 'constants.dart';
// import 'interface/Home/chat/Chat_home.dart';
// import 'interface/Home/SavedNews.dart';
// import 'interface/Home/homeNews.dart';
// import 'interface/user/Profile.dart';
//
// class NewsScreen extends StatefulWidget {
//   final Map<String, dynamic> userInfo;
//   const NewsScreen({super.key, required this.userInfo});
//
//   @override
//   State<NewsScreen> createState() => _NewsScreenState();
// }
//
// class _NewsScreenState extends State<NewsScreen> {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   int _currentIndex = 0;
//   int unreadMessageCount = 0;
//
//   User? loggedInUser;
//   Map<String, dynamic>? dataUser;
//   List<Widget> _body = [
//     const Center(child: CircularProgressIndicator()),
//     const Center(child: CircularProgressIndicator()),
//     const Center(child: CircularProgressIndicator()),
//   ];
//
//   Future<void> signOut() async {
//     await GoogleSignIn().signOut();
//     await FirebaseAuth.instance.signOut();
//   }
//
//   Future<void> getCurrentUser() async {
//     final user = auth.currentUser;
//     if (user != null) {
//       setState(() {
//         loggedInUser = user;
//       });
//     }
//   }
//
//   void checkForNewMessages() {
//     if (loggedInUser == null) return;
//
//     FirebaseFirestore.instance
//         .collection('chats')
//         .where('users', arrayContains: loggedInUser!.uid)
//         .snapshots()
//         .listen((snapshot) {
//       int newMessageCount = 0;
//
//       for (var chatDoc in snapshot.docs) {
//         chatDoc.reference
//             .collection('messages')
//             .where('receiver', isEqualTo: loggedInUser!.uid)
//             .where('isRead', isEqualTo: false)
//             .snapshots()
//             .listen((messageSnapshot) {
//           for (var messageDoc in messageSnapshot.docs) {
//             final data = messageDoc.data();
//             if (data.containsKey('isRead') && !data['isRead']) {
//               newMessageCount++;
//             }
//           }
//           setState(() {
//             unreadMessageCount = newMessageCount;
//           });
//         });
//       }
//     });
//   }
//
//   Future<Map<String, dynamic>> getCurrentUserInfo() async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//     User? currentUser = auth.currentUser;
//
//     if (currentUser == null) {
//       throw Exception('No user is currently signed in.');
//     }
//
//     try {
//       DocumentSnapshot userDoc = await firestore.collection('User').doc(currentUser.uid).get();
//
//       if (userDoc.exists) {
//         return userDoc.data() as Map<String, dynamic>;
//       } else {
//         throw Exception('User document does not exist in Firestore.');
//       }
//     } catch (e) {
//       throw Exception('Error getting user info: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser().then((_) {
//       checkForNewMessages();
//       getCurrentUserInfo().then((userInfo) {
//         setState(() {
//           dataUser = userInfo;
//           _body = [
//             HomeNews(isLeader: dataUser!["isLeader"]),
//              SavedNews(),
//             const ChatHome(),
//           ];
//         });
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String? imgUrl = widget.userInfo['imgUrl'];
//     String email = widget.userInfo['email'];
//     String initialLetter = email.isNotEmpty ? email[0].toUpperCase() : "";
//
//     return FutureBuilder<Map<String, dynamic>>(
//       future: getCurrentUserInfo(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(child: Text('Error: ${snapshot.error}')),
//           );
//         } else if (snapshot.hasData) {
//           dataUser = snapshot.data;
//           _body = [
//             HomeNews(isLeader: dataUser!["isLeader"]),
//              SavedNews(),
//             const ChatHome(),
//           ];
//
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text(
//                 "NKUU",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               elevation: 12,
//               backgroundColor: primaryColor,
//               leading: IconButton(onPressed: (){
//                 signOut();
//                 Navigator.popUntil(
//                     context, (route) => route.isFirst);
//               },
//                   icon: const Icon(Icons.arrow_back, color: Colors.white,)),
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 10.0),
//                   child: Row(
//                     children: [
//                       unreadMessageCount > 0
//                           ? Badge(
//                         backgroundColor: secondaryColor,
//                         alignment: AlignmentDirectional.topEnd,
//                         largeSize: 16,
//                         label: Text(
//                           unreadMessageCount.toString(),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.notifications_active_rounded,
//                           size: 28,
//                           color: Colors.white,
//                         ),
//                       )
//                           : const Icon(
//                         Icons.notifications_active_rounded,
//                         size: 28,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: 20.0),
//                       if (dataUser != null && dataUser!['isLeader'] == true)
//                         IconButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>  Admin(infoUser:widget.userInfo)),
//                             );
//                           },
//                           icon: const Icon(
//                             Icons.admin_panel_settings_rounded,
//                             size: 30,
//                             color: Colors.white,
//                           ),
//                         ),
//                       const SizedBox(width: 20.0),
//                       PopupMenuButton(
//                         padding: const EdgeInsets.all(10.0),
//                         position: PopupMenuPosition.under,
//                         child: CircleAvatar(
//                           backgroundColor: secondaryColor,
//                           radius: 20,
//                           backgroundImage: imgUrl != null && imgUrl.isNotEmpty
//                               ? NetworkImage(imgUrl)
//                               : null,
//                           child: imgUrl == null || imgUrl.isEmpty
//                               ? Text(
//                             initialLetter,
//                             style: const TextStyle(
//                               fontSize: 20.0,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           )
//                               : null,
//                         ),
//                         itemBuilder: (context) {
//                           return [
//                             PopupMenuItem(
//                               child: Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) => Profile(
//                                               userInfo: widget.userInfo,
//                                             )),
//                                       );
//                                     },
//                                     child: const Row(
//                                       children: [
//                                         Icon(Icons.account_circle),
//                                         SizedBox(width: 10,),
//                                         Text("Profile")
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             PopupMenuItem(
//                               child: Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       signOut();
//                                       Navigator.popUntil(
//                                           context, (route) => route.isFirst);
//                                     },
//                                     child: const Row(
//                                       children: [
//                                         Icon(Icons.logout),
//                                         SizedBox(width: 10,),
//                                         Text("Logout")
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ];
//                         },
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//             body: Column(
//               children: [
//                 Expanded(child: _body[_currentIndex]),
//               ],
//             ),
//             bottomNavigationBar: BottomNavigationBar(
//               selectedItemColor: Colors.orange,
//               unselectedItemColor: Colors.grey,
//               currentIndex: _currentIndex,
//               onTap: (int newIndex) {
//                 setState(() {
//                   _currentIndex = newIndex;
//                 });
//               },
//               items: const [
//                 BottomNavigationBarItem(
//                   label: 'Home',
//                   icon: Icon(Icons.home),
//                 ),
//                 BottomNavigationBarItem(
//                   label: 'Saved',
//                   icon: Icon(Icons.save),
//                 ),
//                 BottomNavigationBarItem(
//                   label: 'Message',
//                   icon: Icon(Icons.message, size: 28),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return const Scaffold(
//             body: Center(child: Text('No user data found')),
//           );
//         }
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'admin.dart';
import 'constants.dart';
import 'interface/Home/chat/Chat_home.dart';
import 'interface/Home/SavedNews.dart';
import 'interface/Home/homeNews.dart';
import 'interface/user/Profile.dart';

class NewsScreen extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const NewsScreen({super.key, required this.userInfo});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  int _currentIndex = 0;
  int unreadMessageCount = 0;

  User? loggedInUser;
  Map<String, dynamic>? dataUser;
  List<Widget> _body = [
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
  ];

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void checkForNewMessages() {
    if (loggedInUser == null) return;

    FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: loggedInUser!.uid)
        .snapshots()
        .listen((snapshot) {
      int newMessageCount = 0;

      for (var chatDoc in snapshot.docs) {
        chatDoc.reference
            .collection('messages')
            .where('receiver', isEqualTo: loggedInUser!.uid)
            .where('isRead', isEqualTo: false)
            .snapshots()
            .listen((messageSnapshot) {
          for (var messageDoc in messageSnapshot.docs) {
            final data = messageDoc.data();
            if (data.containsKey('isRead') && !data['isRead']) {
              newMessageCount++;
            }
          }
          setState(() {
            unreadMessageCount = newMessageCount;
          });
        });
      }
    });
  }

  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      DocumentSnapshot userDoc = await firestore.collection('User').doc(currentUser.uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception('User document does not exist in Firestore.');
      }
    } catch (e) {
      throw Exception('Error getting user info: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((_) {
      checkForNewMessages();
      getCurrentUserInfo().then((userInfo) {
        setState(() {
          dataUser = userInfo;
          _body = [
            HomeNews(isLeader: dataUser!["isLeader"]),
            SavedNews(),
            const ChatHome(),
          ];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String? imgUrl = widget.userInfo['imgUrl'];
    String email = widget.userInfo['email'];
    String initialLetter = email.isNotEmpty ? email[0].toUpperCase() : "";

    return FutureBuilder<Map<String, dynamic>>(
      future: getCurrentUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          dataUser = snapshot.data;
          _body = [
            HomeNews(isLeader: dataUser!["isLeader"]),
            SavedNews(),
            const ChatHome(),
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "NKUU",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 12,
              backgroundColor: primaryColor,
              leading: IconButton(onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "You are on NKUU APP",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ));
              },
                  icon: const Icon(Icons.info, color: Colors.white,)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(
                    children: [
                      unreadMessageCount > 0
                          ? Badge(
                        backgroundColor: secondaryColor,
                        alignment: AlignmentDirectional.topEnd,
                        largeSize: 16,
                        label: Text(
                          unreadMessageCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.notifications_active_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20.0),
                      if (dataUser != null && dataUser!['isLeader'] == true)
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  Admin(infoUser:widget.userInfo)),
                            );
                          },
                          icon: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 20.0),
                      PopupMenuButton(
                        padding: const EdgeInsets.all(10.0),
                        position: PopupMenuPosition.under,
                        child: CircleAvatar(
                          backgroundColor: secondaryColor,
                          radius: 20,
                          backgroundImage: imgUrl != null && imgUrl.isNotEmpty
                              ? NetworkImage(imgUrl)
                              : null,
                          child: imgUrl == null || imgUrl.isEmpty
                              ? Text(
                            initialLetter,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                              : null,
                        ),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Profile(
                                              userInfo: widget.userInfo,
                                            )),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.account_circle),
                                        SizedBox(width: 10,),
                                        Text("Profile")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      signOut();
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.logout),
                                        SizedBox(width: 10,),
                                        Text("Logout")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
            body: OrientationBuilder(
              builder: (context, orientation) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Expanded(child: _body[_currentIndex]),
                      ],
                    );
                  },
                );
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              currentIndex: _currentIndex,
              onTap: (int newIndex) {
                setState(() {
                  _currentIndex = newIndex;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  label: 'Home',
                  icon: Icon(Icons.home),
                ),
                BottomNavigationBarItem(
                  label: 'Saved',
                  icon: Icon(Icons.save),
                ),
                BottomNavigationBarItem(
                  label: 'Message',
                  icon: Icon(Icons.message, size: 28),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('No user data found')),
          );
        }
      },
    );
  }
}
