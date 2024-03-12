import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/operation/TimeConvert.dart';
import 'package:flutter_application_2/screen/watch/widgets/ControlsOverlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../../../constant/global_variables.dart';
import '../../../constant/static_variables.dart';
import '../../../model/Comment.dart';
import '../../../model/Feel.dart';
import '../../../model/Post.dart';
import '../../../model/User.dart';
import '../../editpost/EditPostPage.dart';
import '../../newsfeed/widgets/MarkComment.dart';
import '../../newsfeed/widgets/PostContent.dart';
import '../../newsfeed/widgets/FeelTemplate.dart';
import '../../personal/PersonalPage.dart';
import '../subscreen/WatchFullPage.dart';
import '../subscreen/WatchPage.dart';

// ignore: must_be_immutable
class WatchCard extends StatefulWidget {
  final Post post;
  bool autoPlay;
  bool? isDarkMode;
  bool? isNFPost;
  WatchCard(
      {super.key,
      required this.post,
      required this.autoPlay,
      this.isDarkMode = false,
      this.isNFPost = false});

  @override
  State<WatchCard> createState() => _WatchCardState();
}

class _WatchCardState extends State<WatchCard> {
  static double offset = 0;
  late List<String> icons = [];
  int? firstReaction;
  int? secondReaction;
  bool _feltKudos = false;
  bool _feltDisappointed = false;
  final token = 'Bearer ${StaticVariable.currentSession.token}';
  TextEditingController commentController = TextEditingController();
  late List<Comment> data;

  ScrollController scrollController =
      ScrollController(initialScrollOffset: offset);

  late VideoPlayerController controller;

  @override
  void didUpdateWidget(WatchCard oldWidget) {
    if (oldWidget.autoPlay != widget.autoPlay) {
      if (widget.autoPlay) {
        controller.play();
      } else {
        controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.post.video![0]))
          ..initialize().then((_) {
            setState(() {
              controller.setVolume(1.0);
            });
          });
    List<int> reactions = [
      widget.post.kudos != null ? widget.post.kudos! : 0,
      widget.post.disappointed != null ? widget.post.disappointed! : 0,
    ];
    reactions.sort((a, b) => b - a);
    firstReaction = reactions[0];
    secondReaction = reactions[1];
    int sum = 0;
    for (int i = 0; i < reactions.length; i++) {
      sum += reactions[i];
    }
    setState(() {
      icons = [];
      if (reactions[0] == widget.post.kudos) {
        icons.add('assets/images/reactions/like.png');
        icons.add('assets/images/reactions/dislike.png');
      } else if (reactions[0] == widget.post.disappointed) {
        icons.add('assets/images/reactions/dislike.png');
        icons.add('assets/images/reactions/like.png');
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDarkMode == true
          ? Colors.black.withOpacity(0.85)
          : Colors.white,
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final user = User(
                            userId: widget.post.user.userId,
                            name: widget.post.user.name,
                            avatar: widget.post.user.avatar);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PersonalPage(user: user)),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.post.user.avatar),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Text(
                                  widget.post.user.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: widget.isDarkMode == true
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 165,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  TimeConvert().convert(widget.post.time),
                                  style: TextStyle(
                                    color: widget.isDarkMode == true
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 2,
                                    left: 5,
                                    right: 5,
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    size: 2,
                                    color: widget.isDarkMode == true
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black54,
                                  ),
                                ),
                                Icon(
                                  Icons.public,
                                  color: widget.isDarkMode == true
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black54,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                (widget.post.isModified!)
                                    ? const Text('Đã chỉnh sửa',
                                        style: TextStyle(
                                          color: GlobalVariables.iconColor,
                                          fontSize: 12,
                                        ))
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                color: Colors.grey[300],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 4,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        (widget.post.user.userId ==
                                            StaticVariable.currentUser.userId)
                                            ? Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditPostPage(post: widget.post)),
                                              );
                                            },
                                            child: const ListTile(
                                              tileColor: Colors.white,
                                              minLeadingWidth: 10,
                                              titleAlignment:
                                              ListTileTitleAlignment
                                                  .center,
                                              leading: Icon(
                                                Icons.edit,
                                                size: 30,
                                                color: Colors.black,
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    'Chỉnh sửa bài viết',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                            : Container(),
                                        (widget.post.user.userId ==
                                            StaticVariable.currentUser.userId)
                                            ? Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {},
                                            child: const ListTile(
                                              tileColor: Colors.white,
                                              minLeadingWidth: 10,
                                              titleAlignment:
                                              ListTileTitleAlignment
                                                  .center,
                                              leading: Icon(
                                                Icons.delete,
                                                size: 30,
                                                color: Colors.black,
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    'Xóa bài viết',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                            : Container(),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {},
                                            child: ListTile(
                                              tileColor: Colors.white,
                                              minLeadingWidth: 10,
                                              titleAlignment:
                                              ListTileTitleAlignment.center,
                                              leading: const Icon(
                                                Icons.feedback_rounded,
                                                size: 30,
                                                color: Colors.black,
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Báo cáo bài viết',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Chúng tôi sẽ không cho ${widget.post.user.name} biết ai đã báo cáo.',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: widget.isDarkMode == true
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          PostContent(
            text: widget.post.content!,
            textColor: widget.isDarkMode == true ? Colors.white : Colors.black,
          ),
          controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    // if (widget.isDarkMode == null ||
                    //     widget.isDarkMode == false) {
                    //   controller.pause();
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => WatchFullPage(
                    //         controllerInit: widget.controller,
                    //         postInit: widget.post,
                    //       ),
                    //     ),
                    //   );
                    // }
                  },
                  child: GestureDetector(
                    onTap: () {
                      controller.pause();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WatchFullPage(
                                  postInit: widget.post,
                                  controllerInit: controller,
                                )),
                      );
                    },
                    child: widget.isDarkMode!
                        ? AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: Stack(
                              children: [
                                VideoPlayer(
                                  controller,
                                ),
                                if (widget.isDarkMode == true)
                                  ControlsOverlay(controller: controller),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: GlobalVariables.greyBackgroundColor,
                                ),
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: Stack(
                                      children: [
                                        VideoPlayer(
                                          controller,
                                        ),
                                        if (widget.isDarkMode == true)
                                          ControlsOverlay(
                                              controller: controller),
                                      ],
                                    ),
                                  ),
                                ),
                                if (widget.isDarkMode == null ||
                                    widget.isDarkMode == false)
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.picture_in_picture_alt_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                if (widget.isDarkMode == null ||
                                    widget.isDarkMode == false)
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (controller.value.volume > 0) {
                                            controller.setVolume(0);
                                          } else {
                                            controller.setVolume(1.0);
                                          }
                                        });
                                      },
                                      icon: controller.value.volume > 0
                                          ? const Icon(
                                              Icons.volume_up_outlined,
                                              color: Colors.white,
                                              size: 25,
                                            )
                                          : const Icon(
                                              Icons.volume_off_outlined,
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                    ),
                                  ),
                                widget.isNFPost!
                                    ? Positioned.fill(
                                        child: Center(
                                            child: Icon(Icons.play_arrow,
                                                color: GlobalVariables
                                                    .backgroundColor,
                                                size: 80)),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                  ),
                )
              : Container(
                  color: GlobalVariables.blackNavIcon,
                  height: 200,
                  width: double.infinity,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: GlobalVariables.secondaryColor)),
                ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 8,
              left: 10,
              right: 10,
            ),
            child: InkWell(
                onTap: () async {
                  var body = {
                    'id': widget.post.postId,
                    'index': 0,
                    'count': 50
                  };
                  var response = await http.post(
                      Uri.parse('$root/get_list_feels'),
                      headers: <String, String>{
                        'Content-Type': 'application/json',
                        'Authorization': token
                      },
                      body: jsonEncode(body));
                  var responseBody = jsonDecode(response.body);
                  print(responseBody['data'][0]);
                  if (int.parse(responseBody['code']) == 1000) {
                    List<Feel> data =
                        (responseBody['data'] as List<dynamic>).map((item) {
                      return Feel(
                        id: int.parse(item['id']),
                        user: User(
                          userId: int.parse(item['feel']['user']['id']),
                          name: item['feel']['user']['name'] as String,
                          avatar:
                              (item['feel']['user']['avatar'] as String).isEmpty
                                  ? defaultavt
                                  : item['feel']['user']['avatar'] as String,
                        ),
                        type: int.parse(item['feel'][
                            'type']), // Assuming the comments field is empty for now
                      );
                    }).toList();
                    _showFeelBottomSheet(data);
                  }
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: Image.asset(
                        icons[0],
                        width: 20,
                      ),
                    ),
                    Text(
                      "$firstReaction",
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDarkMode == true
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0, right: 3.0),
                      child: Image.asset(
                        icons[1],
                        width: 20,
                      ),
                    ),
                    Text(
                      "$secondReaction",
                      style: TextStyle(
                        color: widget.isDarkMode == true
                            ? Colors.white
                            : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      width: 0.55 * MediaQuery.of(context).size.width,
                    ),
                    widget.post.mark != 0
                        ? widget.post.mark == 1
                            ? Text(
                                '1 mark',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: widget.isDarkMode == true
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              )
                            : Text(
                                '${widget.post.mark} marks',
                                style: TextStyle(
                                  color: widget.isDarkMode == true
                                      ? Colors.white
                                      : Colors.black54,
                                  fontSize: 14,
                                ),
                              )
                        : const SizedBox(),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              color: widget.isDarkMode == true ? Colors.white : Colors.black38,
              height: 0,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: (MediaQuery.of(context).size.width) / 3,
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      _feltKudos = !_feltKudos;

                      if (firstReaction != null) {
                        if (_feltKudos == true) {
                          if (_feltDisappointed == true) {
                            firstReaction = firstReaction! + 1;
                            secondReaction = secondReaction! - 1;
                          } else
                            firstReaction = firstReaction! + 1;
                        } else
                          firstReaction = firstReaction! - 1;
                      }
                      if (_feltDisappointed)
                        _feltDisappointed = !_feltDisappointed;
                    });
                    if (_feltKudos == true) {
                      var body = {'id': widget.post.postId, 'type': 1};
                      var response = await http.post(Uri.parse('$root/feel'),
                          headers: <String, String>{
                            'Content-Type': 'application/json',
                            'Authorization': token
                          },
                          body: jsonEncode(body));
                      var responseBody = jsonDecode(response.body);
                      print(responseBody);
                    } else {
                      var body = {'id': widget.post.postId};
                      var response = await http.post(
                          Uri.parse('$root/delete_feel'),
                          headers: <String, String>{
                            'Content-Type': 'application/json',
                            'Authorization': token
                          },
                          body: jsonEncode(body));
                      var responseBody = jsonDecode(response.body);
                      print(responseBody);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _feltKudos
                          ? Icon(MdiIcons.thumbUp,
                              size: 24, color: GlobalVariables.secondaryColor)
                          : Icon(
                              MdiIcons.thumbUpOutline,
                              size: 24,
                              color: (widget.isDarkMode == true)
                                  ? GlobalVariables.backgroundColor
                                  : GlobalVariables.navIconColor,
                            ),
                      Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text(
                          "Tin thật",
                          style: TextStyle(
                              color: _feltKudos
                                  ? GlobalVariables.secondaryColor
                                  : (widget.isDarkMode == true)
                                      ? GlobalVariables.backgroundColor
                                      : GlobalVariables.navIconColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: (MediaQuery.of(context).size.width) / 3,
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      _feltDisappointed = !_feltDisappointed;
                      if (secondReaction != null) {
                        if (_feltDisappointed == true) {
                          if (_feltKudos == true) {
                            secondReaction = secondReaction! + 1;
                            firstReaction = firstReaction! - 1;
                          } else {
                            secondReaction = secondReaction! + 1;
                          }
                        } else
                          secondReaction = secondReaction! - 1;
                      }
                      if (_feltKudos) _feltKudos = !_feltKudos;
                    });
                    if (_feltDisappointed == true) {
                      var body = {'id': widget.post.postId, 'type': 0};
                      var response = await http.post(Uri.parse('$root/feel'),
                          headers: <String, String>{
                            'Content-Type': 'application/json',
                            'Authorization': token
                          },
                          body: jsonEncode(body));
                      var responseBody = jsonDecode(response.body);
                      print(responseBody);
                    } else {
                      var body = {'id': widget.post.postId};
                      var response = await http.post(
                          Uri.parse('$root/delete_feel'),
                          headers: <String, String>{
                            'Content-Type': 'application/json',
                            'Authorization': token
                          },
                          body: jsonEncode(body));
                      var responseBody = jsonDecode(response.body);
                      print(responseBody);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _feltDisappointed
                          ? Icon(MdiIcons.thumbDown,
                              size: 24, color: GlobalVariables.redColor)
                          : Icon(
                              MdiIcons.thumbDownOutline,
                              size: 24,
                              color: (widget.isDarkMode == true)
                                  ? GlobalVariables.backgroundColor
                                  : GlobalVariables.navIconColor,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          "Tin giả",
                          style: TextStyle(
                              color: _feltDisappointed
                                  ? GlobalVariables.redColor
                                  : (widget.isDarkMode == true)
                                      ? GlobalVariables.backgroundColor
                                      : GlobalVariables.navIconColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  var body = {
                    'id': widget.post.postId,
                    'index': 0,
                    'count': 10
                  };
                  var response = await http.post(
                      Uri.parse('$root/get_mark_comment'),
                      headers: <String, String>{
                        'Content-Type': 'application/json',
                        'Authorization': token
                      },
                      body: jsonEncode(body));
                  var responseBody = jsonDecode(response.body);
                  print(responseBody);
                  if (int.parse(responseBody['code']) == 1000) {
                    data = (responseBody['data'] as List<dynamic>).map((item) {
                      return Comment(
                        commentId: int.parse(item['id']),
                        content: item['mark_content'] as String,
                        typeOfMark: int.parse(item['type_of_mark']),
                        time: item['created'] as String,
                        user: User(
                          userId: int.parse(item['poster']['id']),
                          name: item['poster']['name'] as String,
                          avatar: (item['poster']['avatar'] as String).isEmpty
                              ? "https://it4788.catan.io.vn/files/avatar-1701332613133-239789843.jpg"
                              : item['poster']['avatar'] as String,
                        ),
                        comments: (item['comments'] as List<dynamic>)
                            .map((smallerItem) {
                          return Comment(
                            content: smallerItem['content'] as String,
                            time: smallerItem['created'] as String,
                            user: User(
                              userId: int.parse(smallerItem['poster']['id']),
                              name: smallerItem['poster']['name'] as String,
                              avatar: (smallerItem['poster']['avatar']
                                          as String)
                                      .isEmpty
                                  ? "https://it4788.catan.io.vn/files/avatar-1701332613133-239789843.jpg"
                                  : smallerItem['poster']['avatar'] as String,
                            ),
                          );
                        }).toList(), // Assuming the comments field is empty for now
                      );
                    }).toList();
                    setState(() {
                      commentController.clear();
                    });
                    _showCommentBottomSheet(data);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  alignment: Alignment.center,
                  width: (MediaQuery.of(context).size.width) / 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.commentOutline,
                        size: 24,
                        color: (widget.isDarkMode == true)
                            ? GlobalVariables.backgroundColor
                            : GlobalVariables.navIconColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          'Mark',
                          style: TextStyle(
                              color: (widget.isDarkMode == true)
                                  ? GlobalVariables.backgroundColor
                                  : GlobalVariables.navIconColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCommentBottomSheet(List<Comment> markComments) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0), // Adjust the radius as needed
        ),
      ),
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        return Container(
            height: 0.9 * screenHeight,
            child: Wrap(children: <Widget>[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 8,
                      left: 15,
                      right: 15,
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 3.0),
                              child: Image.asset(
                                icons[0],
                                width: 20,
                              ),
                            ),
                            Text(
                              "$firstReaction",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 6.0, right: 3.0),
                              child: Image.asset(
                                icons[1],
                                width: 20,
                              ),
                            ),
                            Text(
                              "$secondReaction",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              width: 0.5 * MediaQuery.of(context).size.width,
                            ),
                            widget.post.mark != null
                                ? Text(
                                    '${widget.post.mark} marks',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(
                  color: Colors.black38,
                  height: 0,
                ),
              ),
              SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    height: 0.75 * screenHeight,
                    child: ListView(
                      children: markComments
                          .map((e) => Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: MarkComment(
                                        comment: e,
                                        post: widget.post,
                                        isMark: 1),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  )),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(
                  color: Colors.black38,
                  height: 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 12, bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: GlobalVariables.navIconColor, size: 30)),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 6, left: 12, bottom: 20, right: 8),
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              hintText: 'Mark điều gì đó',
                              fillColor: GlobalVariables.greyCommentColor),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          if (commentController.text.isNotEmpty) {
                            var body = {
                              'id': widget.post.postId,
                              'content': commentController.text,
                              'type': 0,
                              'index': markComments.length + 1,
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
                              Navigator.of(context).pop();
                              Comment tmp = Comment(
                                  user: StaticVariable.currentUser,
                                  time: 'Vừa xong',
                                  content: commentController.text);
                              setState(() {
                                data.add(tmp);
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.send,
                            color: GlobalVariables.navIconColor, size: 30)),
                  ],
                ),
              ),
            ]));
      },
    );
  }

  void _showFeelBottomSheet(List<Feel> feelList) {
    int index = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0), // Adjust the radius as needed
        ),
      ),
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        return Wrap(
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 8,
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      (firstReaction! + secondReaction! == 0)
                          ? Container()
                          : widget.isNFPost!
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 42,
                                          child: Stack(
                                            children: [
                                              const SizedBox(
                                                width: 24,
                                                height: 24,
                                              ),
                                              Positioned(
                                                top: 2,
                                                left: 18,
                                                child: Image.asset(
                                                  icons[1],
                                                  width: 20,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      )),
                                                  child: Image.asset(
                                                    icons[0],
                                                    width: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '$firstReaction',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 3.0),
                                      child: Image.asset(
                                        icons[0],
                                        width: 20,
                                      ),
                                    ),
                                    Text(
                                      "$firstReaction",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 6.0, right: 3.0),
                                      child: Image.asset(
                                        icons[1],
                                        width: 20,
                                      ),
                                    ),
                                    Text(
                                      "$secondReaction",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.black38,
                height: 0,
              ),
            ),
            SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  height: 0.4 * screenHeight,
                  child: ListView(
                    children: feelList
                        .map((e) => Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: FeelTemplate(feel: e),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                )),
          ],
        );
      },
    );
  }
}
