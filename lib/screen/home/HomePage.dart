import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/screen/friend/FriendRequestPage.dart';
import 'package:flutter_application_2/screen/home/widgets/HomeAppBar.dart';
import 'package:flutter_application_2/screen/menu/subscreen/MenuPage.dart';
import 'package:flutter_application_2/screen/notification/subscreen/NotificationPage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../newsfeed/subscreen/NewsfeedPage.dart';
import '../watch/subscreen/WatchPage.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double toolBarHeight = 60;
  late TabController tabController;
  ScrollController scrollController = ScrollController();

  late final list = <Widget>[
    NewsFeedScreen(parentScrollController: scrollController),
    const FriendsScreen(),
    const WatchScreen(),
    const NotificationsScreen(),
    const MenuScreen()
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {
        _selectedIndex = tabController.index;
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: toolBarHeight,
                titleSpacing: 0,
                title: AnimatedContainer(
                  onEnd: () {
                    setState(() {
                      if (_selectedIndex > 0) {
                        toolBarHeight = 0;
                      } else {
                        toolBarHeight = 60;
                      }
                    });
                  },
                  curve: Curves.linearToEaseOut,
                  height: (_selectedIndex > 0) ? 0 : 60,
                  duration: Duration(milliseconds: _selectedIndex == 0 ? 100 : 10),
                  child: const HomeAppBar(),
                ),
                floating: true,
                snap: _selectedIndex == 0,
                pinned: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(38),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TabBar(
                          padding: const EdgeInsets.only(top: 6),
                          labelColor: GlobalVariables.secondaryColor,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: GlobalVariables.secondaryColor,
                          unselectedLabelColor: GlobalVariables.navIconColor,
                          controller: tabController,
                          labelPadding: EdgeInsets.zero,
                          tabs: [
                            Icon(
                              MdiIcons.home,
                              size: 30,
                            ),
                            Icon(
                              MdiIcons.accountMultiple,
                              size: 30
                            ),
                            Icon(
                              MdiIcons.youtubeTv,
                              size: 30,
                            ),
                            Icon(
                              MdiIcons.bell,
                              size: 30,
                            ),
                            Icon(
                              MdiIcons.menu,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black12,
                        height: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              list[0],
              list[1],
              list[2],
              list[3],
              list[4],
            ],
          )
      )
    );
  }
}
