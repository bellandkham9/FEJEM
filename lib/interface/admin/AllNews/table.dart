import 'package:adminfejem/interface/admin/AllNews/AllPost.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../theme_Provider.dart';

import 'AllLink.dart';

class TableAlNews extends StatefulWidget {
  final bool isAdmim;
  const TableAlNews({super.key, required this.isAdmim});

  @override
  State<TableAlNews> createState() => _TableAlNewsState();
}

class _TableAlNewsState extends State<TableAlNews> with TickerProviderStateMixin {
  late final TabController _tabController1;

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);
    _tabController1.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController1.removeListener(_handleTabSelection);
    _tabController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.grey.shade200,
      appBar: AppBar(
        toolbarHeight: 7.0,
        bottom: TabBar(
          controller: _tabController1,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.post_add_sharp,
                color: _tabController1.index == 0
                    ? (uiProvider.isDark ? secondaryColor : Colors.black)
                    : Colors.grey,
              ),
              child: Text(
                "Post",
                style: TextStyle(
                  color: _tabController1.index == 0
                      ? (uiProvider.isDark ? secondaryColor : Colors.black)
                      : Colors.grey,
                ),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.link,
                color: _tabController1.index == 1
                    ? (uiProvider.isDark ? secondaryColor : Colors.black)
                    : Colors.grey,
              ),
              child: Text(
                "Links",
                style: TextStyle(
                  color: _tabController1.index == 1
                      ? (uiProvider.isDark ? secondaryColor : Colors.black)
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController1,
        children: <Widget>[
          AllPost(isLeader: widget.isAdmim),
          AllLinks(isLeader: widget.isAdmim),
        ],
      ),
    );
  }
}
