import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/operation/TimeConvert.dart';
import 'package:http/http.dart' as http;

import '../../../constant/global_variables.dart';
import '../../../constant/static_variables.dart';
import '../../../model/Notification.dart';
import '../../../model/User.dart';
import '../../search/subscreens/SearchScreen.dart';
import '../widgets/NotificationCard.dart';

class NotificationsScreen extends StatefulWidget {
  static double offset = 0;
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool reloadAll = false;
  final token = 'Bearer ${StaticVariable.currentSession.token}';

  ScrollController scrollController =
  ScrollController(initialScrollOffset: NotificationsScreen.offset);
  ScrollController headerScrollController = ScrollController();

  Future<List<Noti>>? storedFuture;

  @override
  void initState() {
    super.initState();
    storedFuture = loadNewNotis(30, false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    headerScrollController.dispose();
    super.dispose();
  }

  String generateContent(int type, String? username, String? postDescribed, String? feelType) {
    switch (type) {
      case 1:
        return '$username đã gửi lời mời kết bạn';
      case 2:
        return '$username đã chấp nhận lời mời kết bạn';
      case 4:
        return 'Bài viết của $username có cập nhật mới';
      case 5:
        return feelType!.contains('1')
          ? '$username đã đánh giá bài viết của bạn là thật'
          : '$username đã đánh giá bài viết của bạn là giả';
      case 6:
        return '$username đã mark về một bài viết của bạn';
      case 9:
        return '$username đã trả lời một mark trong bài viết của bạn';
      default:
        return 'Thông báo';
    }
  }

  Future<List<Noti>> loadNewNotis(int count, bool reload) async {
    List<Noti> notis = [];
    if (reload) {
      setState(() {
        StaticVariable.memCache1 = AsyncMemoizer();
      });
      reloadAll = false;
      var body = {
        "index": 0,
        "count": "$count"
      };
      var response = await http.post(Uri.parse('$root/get_notification'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token
          },
          body: jsonEncode(body));
      var responseBody = jsonDecode(response.body);
      print(responseBody['data']);
      if (int.parse(responseBody['code']) == 1000) {
        for (var item in responseBody['data']) {
          var user = item['user'];
          var post = item['post'];
          var mark = item['mark'];
          var feel = item['feel'];
          String time = TimeConvert().convert(item['created']);
          int type = int.parse(item['type']);
          var newNoti = Noti(
            objectId: int.parse(item['object_id']),
            content: generateContent(
                type,
                (user == null) ? null : user['username'],
                (post == null) ? null : post['described'],
                (feel == null) ? null : feel['type']
            ),
            bold: [user['username']],
            image: user['avatar'].toString().isEmpty ? defaultavt : user['avatar'],
            time: time,
            type: type,
            seen: item['read'].toString().contains('1'),
            isTrust: (feel == null) ? null : feel['type'].contains('1')
          );
          notis.add(newNoti);
        }
      } else {
        print("Có lỗi khi lấy bài mới");
      }
      return notis;
    } else {
      return StaticVariable.memCache1.runOnce(() async {
        var body = {
          "index": 0,
          "count": "$count"
        };
        var response = await http.post(Uri.parse('$root/get_notification'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': token
            },
            body: jsonEncode(body));
        var responseBody = jsonDecode(response.body);
        print(responseBody['data']);
        if (int.parse(responseBody['code']) == 1000) {
          for (var item in responseBody['data']) {
            var user = item['user'];
            var post = item['post'];
            var mark = item['mark'];
            var feel = item['feel'];
            String time = TimeConvert().convert(item['created']);
            int type = int.parse(item['type']);
            var newNoti = Noti(
                objectId: int.parse(item['object_id']),
                content: generateContent(
                    type,
                    (user == null) ? null : user['username'],
                    (post == null) ? null : post['described'],
                    (feel == null) ? null : feel['type']
                ),
                bold: [user['username']],
                image: user['avatar'].toString().isEmpty ? defaultavt : user['avatar'],
                time: time,
                type: type,
                seen: item['read'].toString().contains('1'),
                isTrust: (feel == null) ? null : feel['type'].contains('1')
            );
            notis.add(newNoti);
          }
        } else {
          print("Có lỗi khi lấy bài mới");
        }
        return notis;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      headerScrollController.jumpTo(headerScrollController.offset +
          scrollController.offset -
          NotificationsScreen.offset);
      NotificationsScreen.offset = scrollController.offset;
    });
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: NestedScrollView(
          controller: headerScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              toolbarHeight: 50,
              titleSpacing: 0,
              pinned: true,
              floating: true,
              primary: false,
              centerTitle: true,
              automaticallyImplyLeading: false,
              snap: true,
              forceElevated: innerBoxIsScrolled,
              bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(0), child: SizedBox()),
              title: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: const ImageIcon(
                            AssetImage('assets/images/menu.png'),
                            color: Colors.black,
                            size: 50,
                          ),
                        ),
                        const Text(
                          'Thông báo',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: 35,
                      height: 35,
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                      ),
                      child: IconButton(
                        splashRadius: 18,
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const SearchScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
          body: SingleChildScrollView(
            controller: scrollController,
            child: FutureBuilder(
                future: storedFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!
                          .map((e) =>
                          SingleNotification(
                              notification: e,
                          )).toList(),
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text('Not found!!!'));
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: GlobalVariables.secondaryColor,
                        ),
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }

  Future refresh() async {
    storedFuture = loadNewNotis(40, true);
    setState(() {
    });
  }
}
