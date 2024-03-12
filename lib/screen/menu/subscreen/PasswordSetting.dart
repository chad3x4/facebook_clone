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

class PasswordSetting extends StatefulWidget {
  static double offset = 0;
  static bool viewMoreShortcuts = false;
  static bool viewMoreHelps = false;
  static bool viewMoreSettings = false;
  const PasswordSetting({super.key});

  @override
  State<PasswordSetting> createState() => _PasswordSettingState();
}

class _PasswordSettingState extends State<PasswordSetting> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: PasswordSetting.offset);
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
                        'Đổi mật khẩu',
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

      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10,10,10,20),
              margin: const EdgeInsets.fromLTRB(10,20,10,20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: Colors.black12,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.2),
                  //     blurRadius: 20,
                  //     offset: const Offset(0, 0),
                  //     spreadRadius: 0,
                  //   ),
                  // ]
              ),
              child: Column(
                children: [
                  Container(
                      child: Column(
                        children: [
                          TextField(
                              obscureText: true,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                  hintText: 'Mật khẩu hiện tại',
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6 )
                              )
                          ),
                          TextField(
                              obscureText: true,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                  hintText: 'Mật khẩu mới',
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6 )
                              )
                          ),
                          TextField(
                              obscureText: true,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                  hintText: 'Gõ lại mật khẩu mới',
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6 )
                              )
                          ),
                        ],
                      )
                  )
                ],
              ),
            ),

            Container(
              color: Colors.blue,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(10,5,10,5),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Lưu thay đổi',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                  ),
                ),
              )
            ),

            Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.fromLTRB(10,10,10,5),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Hủy',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16
                    ),
                  ),
                )
            ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Quên mật khẩu?',
                      style: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16
                      ),
                    ),
                  )
            )
          ],
        ),
      ),
    );
  }
}
