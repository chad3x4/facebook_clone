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

class NameSetting extends StatefulWidget {
  static double offset = 0;
  static bool viewMoreShortcuts = false;
  static bool viewMoreHelps = false;
  static bool viewMoreSettings = false;
  const NameSetting({super.key});

  @override
  State<NameSetting> createState() => _NameSettingState();
}

class _NameSettingState extends State<NameSetting> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: NameSetting.offset);
  final TextEditingController searchController = TextEditingController();
  final TextEditingController editingController = TextEditingController();
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
                'Tên',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),

      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  child: Text(
                    'Tên',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  )
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: Colors.black12,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment :CrossAxisAlignment.start ,
                      children: [
                        Column(
                          crossAxisAlignment :CrossAxisAlignment.start ,
                          children: [
                            Text(
                                'Họ',
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)
                            ),
                            Container(
                              height: 1.5 * 14,
                              width: MediaQuery.of(context).size.width * 3/5,
                              child: TextField(
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter your text',
                                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6 )
                                  )
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment :CrossAxisAlignment.start ,
                          children: [
                            Text(
                                'Tên đệm',
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)
                            ),
                            Container(
                              height: 1.5 * 14,
                              width: MediaQuery.of(context).size.width * 3/5,
                              child: TextField(
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter your text',
                                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6 ),
                                  )
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment :CrossAxisAlignment.start ,
                          children: [
                            Text(
                                'Tên',
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)
                            ),
                            Container(
                              height: 1.5 * 14,
                              width: MediaQuery.of(context).size.width * 3/5,
                              child: TextField(
                                  controller: editingController,
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: user.name,
                                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                                  )
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top:10.0),
                          padding: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: Colors.black12,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: const <TextSpan>[
                                TextSpan(text: 'Xin lưu ý rằng:', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ' Nếu đổi tên trên Facebook, bạn không thể đổi lại tên trong 60 ngày. Đừng thêm bất cứ cách viết hoa khác thường, dấu câu, ký tự hoặc các từ ngẫu nhiên.'),
                                TextSpan(text: ' Tìm hiểu thêm.', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.lightBlue)),
                              ],
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
      ),


    );
  }
}