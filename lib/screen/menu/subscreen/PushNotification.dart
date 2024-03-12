import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/screen/menu/widgets/MenuOption.dart';
import 'package:flutter_application_2/screen/menu/widgets/ShortcutButton.dart';
import 'package:flutter_application_2/screen/personal/PersonalPage.dart';
import 'package:http/http.dart' as http;

import '../../../constant/global_variables.dart';
import '../../../main.dart';
import '../../../model/User.dart';
import 'SettingNotice.dart';
import 'Setting.dart';

class PushNotification extends StatefulWidget {
  static double offset = 0;
  static bool viewMoreShortcuts = false;
  static bool viewMoreHelps = false;
  static bool viewMoreSettings = false;
  const PushNotification({super.key});

  @override
  State<PushNotification> createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: PushNotification.offset);
  final TextEditingController searchController = TextEditingController();
  ScrollController headerScrollController = ScrollController();
  User user = StaticVariable.currentUser;
  final avatar = StaticVariable.currentUser.avatar;
  bool light = true;
  bool light1 = true;
  bool light2 = true;
  bool light3 = true;
  String switchText = 'Bật';
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
                'Thông báo đẩy',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/menu/settings.png',
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
                              'Tắt thông báo đẩy',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              switchText,
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
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: light,
                      activeColor: Colors.blueAccent,
                      onChanged: (bool value) {
                        setState(() {
                          light = value;
                          switchText = light ? 'Bật' : 'Tắt';
                        });
                      },
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
                        'assets/images/menu/problem.png',
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
                              'Rung',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Rung khi có thông báo đến',
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
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: light1,
                      activeColor: Colors.blueAccent,
                      onChanged: (bool value) {
                        setState(() {
                          light1 = value;
                        });
                      },
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
                        'assets/images/menu/phone.png',
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
                              'Đèn LED điện thoại',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Nhấp nháy đèn LED khi có thông báo đến',
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
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: light2,
                      activeColor: Colors.blueAccent,
                      onChanged: (bool value) {
                        setState(() {
                          light2 = value;
                        });
                      },
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
                              'Âm thanh',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only( left: 5),
                            child:Text(
                              'Phát âm thanh khi có thông báo đến',
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
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: light3,
                      activeColor: Colors.blueAccent,
                      onChanged: (bool value) {
                        setState(() {
                          light3 = value;
                        });
                      },
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

