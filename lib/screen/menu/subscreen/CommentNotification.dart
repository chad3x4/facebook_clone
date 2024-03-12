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

class CommentNotification extends StatefulWidget {
  static double offset = 0;
  static bool viewMoreShortcuts = false;
  static bool viewMoreHelps = false;
  static bool viewMoreSettings = false;
  const CommentNotification({super.key});

  @override
  State<CommentNotification> createState() => _CommentNotificationState();
}

class _CommentNotificationState extends State<CommentNotification> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: CommentNotification.offset);
  final TextEditingController searchController = TextEditingController();
  ScrollController headerScrollController = ScrollController();
  User user = StaticVariable.currentUser;
  final avatar = StaticVariable.currentUser.avatar;
  bool light = true;
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
          title: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                    Text(
                      'Bình luận',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.search_rounded,
                  color: Colors.black,
                  size: 25,
                ),
              ],
            ),
          )
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          child: Column(
            crossAxisAlignment :CrossAxisAlignment.start ,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20,10,20,10),
                child: Text(
                  'Đây là thông báo khi có người bình luận về bài viết và trả lời bình luận của bạn. Sau đây là ví dụ.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: Colors.black12,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                StaticVariable.currentUser.avatar),
                            radius: 20,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: const <TextSpan>[
                                    TextSpan(text: 'Đèn', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: ' đã trả lời một bình luận có gắn thẻ bạn'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


              const Divider(
                color: Colors.black12,
                indent: 10,
                endIndent: 10,
                height: 0,
              ),

              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Nơi bạn nhận các thông báo này',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10,5,10,5) ,
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
                            ],
                          ),
                         Padding(
                           padding: EdgeInsets.only(top: 5),
                           child:  Transform.scale(
                             scale: 0.75,
                             child: Switch(
                               value: light,
                               activeColor: Colors.blueAccent,
                               onChanged: (bool value) {
                                 setState(() {
                                   light = value;
                                 });
                               },
                             ),
                           ),
                         )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

}

