import 'package:flutter_application_2/model/Session.dart';
import 'package:flutter_application_2/operation/TimeConvert.dart';
import 'package:flutter_application_2/screen/newsfeed/widgets/PostContent.dart';
import 'package:flutter_application_2/model/Comment.dart';
import 'package:flutter_application_2/model/Post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/personal/PersonalPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/constant/global_variables.dart';
import 'dart:convert';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:intl/intl.dart';
import '../../../model/User.dart';

class MarkComment extends StatefulWidget {
  final Comment comment;
  final Post post;
  final int isMark;
  const MarkComment(
      {super.key,
      required this.comment,
      required this.post,
      required this.isMark});

  @override
  State<MarkComment> createState() => _MarkCommentState();
}

class _MarkCommentState extends State<MarkComment> {
  int index = 0;
  List<Comment> tmpList = [];
  TextEditingController replyController = new TextEditingController();
  final token = 'Bearer ${StaticVariable.currentSession.token}';
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int commentLength = widget.comment.comments?.length ?? 0;
    List<Comment>? listComment = widget.comment.comments;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.comment.user.avatar),
          radius: 15,
        ),
        SizedBox(width: 2),
        if (widget.comment.typeOfMark != null)
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: Image.asset(
                widget.comment.typeOfMark == 1
                    ? 'assets/images/reactions/like.png'
                    : 'assets/images/reactions/dislike.png',
                width: 16,
              )),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: 0.7 * screenWidth,
              ),
              decoration: BoxDecoration(
                color: GlobalVariables.greyCommentColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: EdgeInsets.only(top: 6, left: 8, bottom: 6, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      final user = User(
                          userId: widget.comment.user.userId,
                          name: widget.comment.user.name,
                          avatar: widget.comment.user.avatar);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PersonalPage(user: user)),
                      );
                    },
                    child: Text(
                      widget.comment.user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(widget.comment.content),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    TimeConvert().convert(widget.comment.time),
                    style: const TextStyle(
                        color: GlobalVariables.navIconColor, fontSize: 14),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        _isPressed = !_isPressed;
                      });
                    },
                    child: Text(
                      'Phản hồi',
                      style: const TextStyle(
                          color: GlobalVariables.navIconColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )),
                const SizedBox(
                  width: 6,
                ),
                if (widget.comment.user.userId ==
                    StaticVariable.currentUser.userId)
                  if (widget.isMark == 1)
                    InkWell(
                        onTap: () {
                          setState(() {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController textController =
                                    TextEditingController(
                                        text: widget.comment.content);
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  title: Text('Nhập nội dung sửa Comment'),
                                  content: TextField(
                                      controller: textController,
                                      decoration: InputDecoration(
                                        labelText: 'Sửa comment',
                                      )),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Sửa'),
                                      onPressed: () async {
                                        var body = {
                                          'id': widget.post.postId,
                                          'content': textController.text,
                                          'index': commentLength,
                                          'type': 0,
                                          'count': 10
                                        };
                                        var response = await http.post(
                                            Uri.parse('$root/set_mark_comment'),
                                            headers: <String, String>{
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization': token
                                            },
                                            body: jsonEncode(body));
                                        var responseBody =
                                            jsonDecode(response.body);
                                        Navigator.pop(context);
                                        setState(() {
                                          widget.comment.content =
                                              textController.text;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        },
                        child: Text(
                          'Sửa',
                          style: const TextStyle(
                              color: GlobalVariables.navIconColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        )),
              ],
            ),
            if (index != 0)
              InkWell(
                  onTap: () {
                    setState(() {
                      index -= 10;
                      if (listComment != null) {
                        if (index < 0) index = 0;
                        tmpList = listComment.sublist(0, index);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      if (index > 0)
                        Row(
                          children: [
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              'Ẩn bớt ${index} phản hồi ',
                              style: const TextStyle(
                                  color: GlobalVariables.navIconColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  )),
            if (listComment != null)
              ...tmpList.map((e) => Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: MarkComment(
                            comment: e, post: widget.post, isMark: 0),
                      )
                    ],
                  )),
            if (index != 0 || _isPressed == true)
              Padding(
                  padding: EdgeInsets.only(left: 10, top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(StaticVariable.currentUser.avatar),
                            radius: 15,
                          )),
                      Container(
                        padding: EdgeInsets.only(
                            top: 6, left: 12, bottom: 20, right: 8),
                        width: 0.5 * screenWidth,
                        height: 65,
                        child: TextField(
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          controller: replyController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              hintText: 'Nhập bình luận',
                              fillColor: GlobalVariables.greyCommentColor,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8)),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            if (replyController.text.isNotEmpty) {
                              var body = {
                                'id': widget.post.postId,
                                'content': replyController.text,
                                'index': commentLength,
                                'mark_id': widget.comment.commentId,
                                'type': 0,
                                'count': 10
                              };
                              var response = await http.post(
                                  Uri.parse('$root/set_mark_comment'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json',
                                    'Authorization': token
                                  },
                                  body: jsonEncode(body));
                              var responseBody = jsonDecode(response.body);

                              if (int.parse(responseBody['code']) == 1000) {
                                Comment tmpCmt = Comment(
                                    commentId: widget.comment.commentId,
                                    user: StaticVariable.currentUser,
                                    time: DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ")
                                        .format(DateTime.now()),
                                    content: replyController.text);
                                setState(() {
                                  listComment?.add(tmpCmt);
                                });
                                replyController.clear();
                              }
                            }
                          },
                          icon: Icon(Icons.send,
                              color: GlobalVariables.navIconColor, size: 20)),
                    ],
                  )),
            if (commentLength != 0)
              InkWell(
                  onTap: () {
                    setState(() {
                      index += 10;
                      if (listComment != null) {
                        if (index > commentLength) index = commentLength;
                        tmpList = listComment.sublist(0, index);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      if (commentLength > index)
                        Row(
                          children: [
                            Transform(
                              transform: Matrix4.identity()
                                ..scale(-1.0, 1.0)
                                ..translate(-24.0, 0.0),
                              child: Icon(
                                Icons.keyboard_return,
                                color: GlobalVariables.navIconColor,
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              'Xem thêm ${commentLength - index} phản hồi ',
                              style: const TextStyle(
                                  color: GlobalVariables.navIconColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  )),
          ],
        ),
      ],
    );
  }
}
