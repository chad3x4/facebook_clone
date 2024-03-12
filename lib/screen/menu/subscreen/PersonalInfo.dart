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
import 'NameSetting.dart';

class PersonalSetting extends StatefulWidget {
  static double offset = 0;
  static bool viewMoreShortcuts = false;
  static bool viewMoreHelps = false;
  static bool viewMoreSettings = false;
  const PersonalSetting({super.key});

  @override
  State<PersonalSetting> createState() => _PersonalSettingState();
}

class _PersonalSettingState extends State<PersonalSetting> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: PersonalSetting.offset);
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
            leading: IconButton(
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
         ),
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
               Padding(
               padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
               child: Text(
                 'Thông tin cá nhân',
                 style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30),
               )
               ),
               Padding(
                 padding: EdgeInsets.only(left: 10, bottom:10, top:20),
                 child: Text(
                   'Chung',
                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)
                 ),
               ),
               Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(
                   crossAxisAlignment :CrossAxisAlignment.start ,
                   children: [
                     Container(
                       padding: EdgeInsets.only( left: 15),
                       child: Text(
                         'Tên',
                         style: const TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                         ),
                       ),
                     ),
                     Container(
                       padding: EdgeInsets.only( left: 15),
                       child:Text(
                         user.name,
                         style: TextStyle(
                           color: Colors.black54,
                           fontSize: 12,
                         ),
                       ),
                     )
                   ],
                 ),
                 IconButton(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (context) =>
                           const NameSetting()), // Thay SettingPage() bằng widget của trang cài đặt
                     );
                   },
                   splashRadius: 20,
                   icon: const Icon(
                     Icons.arrow_forward_ios_outlined,
                     color: Colors.grey,
                     size: 24,
                   ),
                 ),
               ],
             ),
           ],
          ),
        ),
      );
    }
}