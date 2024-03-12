import 'package:flutter_application_2/model/Session.dart';
import 'package:flutter_application_2/screen/newsfeed/widgets/PostContent.dart';
import 'package:flutter_application_2/model/Comment.dart';
import 'package:flutter_application_2/model/Post.dart';
import 'package:flutter_application_2/model/Feel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/personal/PersonalPage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/constant/global_variables.dart';
import 'dart:convert';
import 'package:flutter_application_2/constant/static_variables.dart';

import '../../../model/User.dart';

class FeelTemplate extends StatefulWidget {
  final Feel feel;
  const FeelTemplate({super.key, required this.feel});

  @override
  State<FeelTemplate> createState() => _FeelTemplateState();
}

class _FeelTemplateState extends State<FeelTemplate> {
  int index = 0;
  List<Comment> tmpList = [];
  TextEditingController replyController = new TextEditingController();
  final token = 'Bearer ${StaticVariable.currentSession.token}';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.feel.user.avatar),
          radius: 15,
        ),
        SizedBox(width: 2),
        Padding(
            padding: EdgeInsets.only(top: 15),
            child: Image.asset(
              widget.feel.type == 1
                  ? 'assets/images/reactions/like.png'
                  : 'assets/images/reactions/dislike.png',
              width: 16,
            )),
        SizedBox(width: 4),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: EdgeInsets.only(top: 6, left: 8, bottom: 6, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    final user = User(
                        userId: widget.feel.user.userId,
                        name: widget.feel.user.name,
                        avatar: widget.feel.user.avatar);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PersonalPage(user: user)),
                    );
                  },
                  child: Text(
                    widget.feel.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}
