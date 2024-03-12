import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/model/Notification.dart';

import 'package:http/http.dart' as http;

import '../../../constant/global_variables.dart';
import '../../../model/Post.dart';
import '../../../model/User.dart';
import '../../personal/PersonalPage.dart';
import '../../watch/widgets/WatchCard.dart';
import '../DetailPost.dart';

class SingleNotification extends StatefulWidget {
  final Noti notification;
  const SingleNotification({super.key, required this.notification});

  @override
  State<SingleNotification> createState() => _SingleNotificationState();
}

class _SingleNotificationState extends State<SingleNotification> {
  List<String> texts = [];
  String token = "Bearer ${StaticVariable.currentSession.token}";

  @override
  void initState() {
    super.initState();
    setState(() {
      texts = [];
      int s = 0;
      if (widget.notification.bold != null) {
        for (int i = 0; i < widget.notification.bold!.length; i++) {
          int j =
          widget.notification.content.indexOf(widget.notification.bold![i]);
          texts.add(widget.notification.content.substring(s, j));
          texts.add(widget.notification.bold![i]);
          s = j + widget.notification.bold![i].length;
        }
      }

      texts.add(widget.notification.content
          .substring(s, widget.notification.content.length));
    });
  }

  Future<User> getUserInfo(int userId) async {
    var body = {"user_id": userId};
    var response = await http.post(Uri.parse('$root/get_user_info'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(body));
      var userBody = jsonDecode(response.body)['data'];
      return User(
          userId: userId,
          name: userBody['username'],
          avatar: userBody['avatar'].toString().isNotEmpty
                  ? userBody['avatar']
                  : defaultavt
      );
  }

  Future<Post?> loadPost(int postId) async {
    var body = {"id": "$postId"};
    var response = await http.post(Uri.parse('$root/get_post'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(body));
    var responseBody = jsonDecode(response.body);
    print(responseBody);
    if (int.parse(responseBody['code']) == 1000) {
      var data = responseBody['data'];
      var author = data['author'];
      List<String>? images = (data['image'] as List)
          ?.map((item) => item['url'] as String)
          ?.toList();
      final newPost = Post(
          postId: int.parse(data['id']),
          user: User(
              userId: int.parse(author['id']),
              name: author['name'],
              avatar: (author['avatar'] as String).isEmpty
                  ? defaultavt
                  : author['avatar']),
          time: data['created'],
          content: data['described'],
          image: images,
          video: data['video'] == null ? null : [data['video']['url']],
          kudos: int.parse(data['kudos']),
          disappointed: int.parse(data['disappointed']),
          mark: int.parse(data['fake']) + int.parse(data['trust']),
          status: data['state'],
          isModified: (data['modified'] as String).contains('1'),
          isFelt: int.parse(data['is_felt'])
      );
      return newPost;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          switch (widget.notification.type) {
            case 1:
              var user = await getUserInfo(widget.notification.objectId);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PersonalPage(
                            user: user)),
              );
              break;
            case 4:
            case 5:
            case 6:
            case 9:
              var post = await loadPost(widget.notification.objectId);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    (post!.video != null)
                        ? SafeArea(
                          child: Scaffold(
                            appBar: AppBar(
                              iconTheme: const IconThemeData(color: GlobalVariables.backgroundColor),
                              titleSpacing: 0,
                              centerTitle: true,
                              backgroundColor: GlobalVariables.secondaryColor.withOpacity(0.75),
                              toolbarHeight: 50,
                              title: Text(
                                'Bài viết của ${post.user.name}',
                                style: const TextStyle(
                                    color: GlobalVariables.backgroundColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            body: WatchCard(
                            post: post,
                            autoPlay: false
                    ),
                          ),
                        )
                        : DetailPostPage(post: post)),
              );
              break;

          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.notification.seen == true
                ? Colors.white.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              top: 10,
              bottom: 10,
              right: 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Stack(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black54,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                          NetworkImage(widget.notification.image),
                          radius: 40,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.notification.type == 1
                                  ? Colors.blue
                                  : widget.notification.type == 4
                                  ? Colors.red[400]
                                  : widget.notification.type == 6
                                  ? Colors.green[400]
                                  : widget.notification.type == 9
                                  ? Colors.green[400]
                                  : Colors.white),
                          child: (widget.notification.type == 1)
                              ? const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                              : (widget.notification.type == 4)
                              ? const Icon(
                                Icons.new_releases,
                                color: Colors.white,
                                size: 22,
                              )
                              : (widget.notification.type == 5)
                              ? (widget.notification.isTrust!)
                                  ? Image.asset('assets/images/reactions/like.png')
                                  : Image.asset('assets/images/reactions/dislike.png')
                              : (widget.notification.type == 6)
                              ? const ImageIcon(
                                AssetImage('assets/images/white-cmt.png'),
                                color: Colors.white,
                                size: 16,
                              )
                              : (widget.notification.type == 9)
                              ? const ImageIcon(
                                AssetImage('assets/images/white-cmt.png'),
                                color: Colors.white,
                                size: 16,
                              )
                              : const Icon(
                                Icons.facebook,
                                color: Colors.blue,
                                size: 30,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          text: TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  height: 1.4),
                              children: texts
                                  .map(
                                    (e) => TextSpan(
                                  text: e,
                                  style: TextStyle(
                                    fontWeight:
                                    widget.notification.bold != null &&
                                        widget.notification.bold!
                                            .contains(e)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              )
                                  .toList()),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            widget.notification.time,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (widget.notification.type == 1)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                  ),
                                  child: const Text(
                                    'Chấp nhận',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: const Color.fromARGB(
                                          237, 219, 218, 218),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(5)),
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: IconButton(
                    padding: const EdgeInsets.all(5),
                    splashRadius: 20,
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
