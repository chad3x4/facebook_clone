import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/screen/menu/subscreen/CommentNotification.dart';
import 'package:flutter_application_2/screen/menu/subscreen/PushNotification.dart';
import 'package:flutter_application_2/screen/menu/widgets/MenuOption.dart';
import 'package:flutter_application_2/screen/menu/widgets/ShortcutButton.dart';
import 'package:flutter_application_2/screen/personal/PersonalPage.dart';
import 'package:http/http.dart' as http;

import '../../../constant/global_variables.dart';
import '../../../main.dart';
import '../../../model/User.dart';

class SettingNotice extends StatefulWidget {
  static double offset = 0;
  static bool viewMoreShortcuts = false;
  static bool viewMoreHelps = false;
  static bool viewMoreSettings = false;
  const SettingNotice({super.key});

  @override
  State<SettingNotice> createState() => _SettingNoticeState();
}

class _SettingNoticeState extends State<SettingNotice> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: SettingNotice.offset);
  ScrollController headerScrollController = ScrollController();
  User user = StaticVariable.currentUser;
  final avatar = StaticVariable.currentUser.avatar;
  final List<Widget> shortcuts = [
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    headerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      headerScrollController.jumpTo(headerScrollController.offset +
          scrollController.offset -
          SettingNotice.offset);
      SettingNotice.offset = scrollController.offset;
    });
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              color: Colors.black12,
              width: double.infinity,
              height: 0.5,
            ),
          ),
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                splashRadius: 20,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              Text(
                'Cài đặt thông báo',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(5, 5, 10, 10),
                      child: Text(
                        'Bạn nhận thông báo về',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                 InkWell(
                   onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (context) =>
                           const CommentNotification()),
                     );
                   },
                   child:  Row(
                     children: [
                       Image.asset(
                         'assets/images/menu/chat.png',
                         width: 40,
                         height: 40,
                       ),
                       const SizedBox(width: 10),
                       Column(
                         crossAxisAlignment :CrossAxisAlignment.start ,
                         children: [
                           Container(
                             padding: EdgeInsets.only( left: 5),
                             child: Text(
                               'Bình luận',
                               style: const TextStyle(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 16,
                               ),
                             ),
                           ),
                           Container(
                             padding: EdgeInsets.only( left: 5),
                             child:Text(
                               'Thông báo đẩy, email, SMS',
                               style: TextStyle(
                                 color: Colors.black54,
                                 fontSize: 12,
                               ),
                             ),
                           )
                         ],
                       ),
                     ],
                   ),
                 )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/mail.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Thẻ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/emergency.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Lời nhắc',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/event.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Hoạt động khác về bạn',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/friends.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Cập nhật từ bạn bè',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/feed.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Lời mời kết bạn',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/settings2.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Những người bạn có thể biết',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/memory.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Sinh nhật',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/group.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Nhóm',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/video.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Video',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10) ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/game.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment :CrossAxisAlignment.start ,
                        children: [
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child: Text(
                              'Hoạt động khác về bạn',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Thông báo đẩy, email, SMS',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              height: 0,
              color: Colors.black12,
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 5, 10, 5),
                      child: Text(
                        'Bạn nhận thông báo qua',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const PushNotification()),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/menu/order.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment :CrossAxisAlignment.start ,
                            children: [
                              Container(
                                padding: EdgeInsets.only( left: 5),
                                child: Text(
                                  'Thông báo đẩy',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only( left: 5),
                                child:Text(
                                  'Bật',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}



