// import 'package:adminfejem/constants.dart';
// import 'package:adminfejem/interface/admin/Leader/leader.dart';
// import 'package:adminfejem/interface/admin/Link/links.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'Home.dart';
// import 'interface/admin/AllNews/table.dart';
// import 'interface/admin/Post/newPost.dart';
// import 'theme_Provider.dart';
//
// class Admin extends StatelessWidget {
//   final Map<String, dynamic> infoUser;
//   const Admin({super.key, required this.infoUser});
//
//   @override
//   Widget build(BuildContext context) {
//     final uiProvider = Provider.of<UiProvider>(context);
//     return  Scaffold(
//       backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
//       body: TabBarExample(infoUser: infoUser,),
//     );
//   }
// }
//
// class TabBarExample extends StatefulWidget {
//   final Map<String, dynamic> infoUser;
//   const TabBarExample({super.key, required this.infoUser});
//
//   @override
//   State<TabBarExample> createState() => _TabBarExampleState();
// }
//
// class _TabBarExampleState extends State<TabBarExample>
//     with TickerProviderStateMixin {
//   late final TabController _tabController;
//
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _tabController.addListener(() {
//       setState(() {}); // Update the state when the tab index changes
//     });
//   }
//
//   getCurrentUser() async {
//     return await auth.currentUser;
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final uiProvider = Provider.of<UiProvider>(context);
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
//         appBar: AppBar(
//           backgroundColor: primaryColor,
//           leading: IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => NewsScreen(
//                     userInfo: widget.infoUser
//                   ),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//           ),
//           title: const Text('Administrator',
//               style: TextStyle(
//                   fontSize: 24.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white)),
//           bottom: TabBar(
//             controller: _tabController,
//             indicatorColor: Colors.white,
//             tabs: <Widget>[
//               Tab(
//                 icon: Icon(
//                   Icons.post_add,
//                   color: _tabController.index == 0 ? Colors.white : Colors.grey,
//                 ),
//                 child: Text(
//                   "add Post",
//                   style: TextStyle(
//                     color: _tabController.index == 0 ? Colors.white : Colors.grey,
//                   ),
//                 ),
//               ),
//               Tab(
//                 icon: Icon(
//                   Icons.add_link,
//                   color: _tabController.index == 1 ? Colors.white : Colors.grey,
//                 ),
//                 child: Text(
//                   "add Links",
//                   style: TextStyle(
//                     color: _tabController.index == 1 ? Colors.white : Colors.grey,
//                   ),
//                 ),
//               ),
//               Tab(
//                 icon: Icon(
//                   Icons.manage_accounts_outlined,
//                   color: _tabController.index == 2 ? Colors.white : Colors.grey,
//                 ),
//                 child: Text(
//                   "Leaders",
//                   style: TextStyle(
//                     color: _tabController.index == 2 ? Colors.white : Colors.grey,
//                   ),
//                 ),
//               ),
//               Tab(
//                 icon: Icon(
//                   Icons.list_alt,
//                   color: _tabController.index == 3 ? Colors.white : Colors.grey,
//                 ),
//                 child: Text(
//                   "All news",
//                   style: TextStyle(
//                     color: _tabController.index == 3 ? Colors.white : Colors.grey,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: <Widget>[
//             const AddPostScreen(),
//             AdminlinkScreen(),
//             const leader(),
//             const TableAlNews(isAdmim: true),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:adminfejem/constants.dart';
import 'package:adminfejem/interface/admin/Leader/leader.dart';
import 'package:adminfejem/interface/admin/Link/links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Home.dart';
import 'interface/admin/AllNews/table.dart';
import 'interface/admin/Post/newPost.dart';
import 'theme_Provider.dart';

class Admin extends StatelessWidget {
  final Map<String, dynamic> infoUser;
  const Admin({super.key, required this.infoUser});

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
      body: TabBarExample(infoUser: infoUser),
    );
  }
}

class TabBarExample extends StatefulWidget {
  final Map<String, dynamic> infoUser;
  const TabBarExample({super.key, required this.infoUser});

  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> with TickerProviderStateMixin {
  late final TabController _tabController;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Update the state when the tab index changes
    });
  }

  getCurrentUser() async {
    return await auth.currentUser;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsScreen(
                    userInfo: widget.infoUser,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Administrator',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(
                icon: Icon(
                  Icons.post_add,
                  color: _tabController.index == 0 ? Colors.white : Colors.grey,
                ),
                child: Text(
                  "+ Post",
                  style: TextStyle(
                    color: _tabController.index == 0 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.add_link,
                  color: _tabController.index == 1 ? Colors.white : Colors.grey,
                ),
                child: Text(
                  "+ Links",
                  style: TextStyle(
                    color: _tabController.index == 1 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.manage_accounts_outlined,
                  color: _tabController.index == 2 ? Colors.white : Colors.grey,
                ),
                child: Text(
                  "Leaders",
                  style: TextStyle(
                    color: _tabController.index == 2 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.list_alt,
                  color: _tabController.index == 3 ? Colors.white : Colors.grey,
                ),
                child: Text(
                  "All News",
                  style: TextStyle(
                    color: _tabController.index == 3 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    const AddPostScreen(),
                    AdminlinkScreen(),
                    const leader(),
                    const TableAlNews(isAdmim: true),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
