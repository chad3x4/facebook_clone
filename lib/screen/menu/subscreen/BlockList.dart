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
import 'AddBlockList.dart';

class BlockList extends StatefulWidget {
  static double offset = 0;
  static bool viewMoreShortcuts = false;
  static bool viewMoreHelps = false;
  static bool viewMoreSettings = false;
  const BlockList({super.key});

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: BlockList.offset);
  final TextEditingController searchController = TextEditingController();
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
                          'Chặn',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
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
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.fromLTRB(20,20,20,5),
                  child: Text(
                    'Người bị chặn',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10,5,10,10),
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Một khi bạn đã chặn ai đó, họ sẽ không xem được nội dung bạn tự đăng trên dòng thời gian mình, gắn thẻ bạn, mời bạn tham gia sự kiện hoặc nhóm, bắt đầu cuộc trò chuyện với bạn hay thêm bạn làm bạn bè. Điều này không bao gồm các ứng dụng, trò chơi hay nhóm mà cả bạn và người này đều tham gia.',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
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
                        padding: EdgeInsets.fromLTRB(10,10,10,5) ,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddBlockList(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                      width: 45,
                                      height: 45,
                                      margin:EdgeInsets.only(left: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 24,
                                        color: Colors.white,
                                      )
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  //margin:EdgeInsets.only(left: 5),
                                  padding: EdgeInsets.only( left: 5),
                                  child: Text(
                                    'THÊM VÀO DANH SÁCH CHẶN',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10,10,10,5) ,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Image.asset(
                                    'assets/images/user/baongan.jpg',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.only( left: 5),
                                  child: Text(
                                    'Nguyen Tran Chung',
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
                              child:  Text(
                                'BỎ CHẶN',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
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

