import 'package:flutter/gestures.dart';
import 'package:flutter_application_2/operation/TimeConvert.dart';
import 'package:flutter_application_2/screen/newsfeed/subscreen/ImageFullscreenPage.dart';
import 'package:flutter_application_2/screen/newsfeed/subscreen/MultipleImagePage.dart';
import 'package:flutter_application_2/screen/newsfeed/widgets/FeelTemplate.dart';
import 'package:flutter_application_2/screen/newsfeed/widgets/MarkComment.dart';
import 'package:flutter_application_2/screen/newsfeed/widgets/PostContent.dart';
import 'package:flutter_application_2/model/Post.dart';
import 'package:flutter_application_2/model/Comment.dart';
import 'package:flutter_application_2/model/Feel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/personal/PersonalPage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/constant/global_variables.dart';
import 'dart:convert';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:intl/intl.dart';

import '../../../model/User.dart';

class DetailPostPage extends StatefulWidget {
  final Post post;
  const DetailPostPage({super.key, required this.post});

  @override
  State<DetailPostPage> createState() => _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  static double offset = 0;
  List<String> icons = [];
  List<int> reactions = [];
  int? firstReaction;
  int? secondReaction;
  final token = 'Bearer ${StaticVariable.currentSession.token}';
  bool _feltKudos = false;
  bool _feltDisappointed = false;
  TextEditingController commentController = TextEditingController();

  ScrollController scrollController =
      ScrollController(initialScrollOffset: offset);
  @override
  void initState() {
    super.initState();
    List<int> reactions = [
      widget.post.kudos != null ? widget.post.kudos! : 0,
      widget.post.disappointed != null ? widget.post.disappointed! : 0,
    ];
    reactions.sort((a, b) => b - a);
    firstReaction = reactions[0];
    secondReaction = reactions[1];
    setState(() {
      icons = [];
      if (reactions[0] == widget.post.kudos) {
        icons.add('assets/images/reactions/like.png');
        icons.add('assets/images/reactions/dislike.png');
      } else if (reactions[0] == widget.post.disappointed) {
        icons.add('assets/images/reactions/dislike.png');
        icons.add('assets/images/reactions/like.png');
      }
      if (widget.post.isFelt == 1) {
        _feltKudos = true;
      } else if (widget.post.isFelt == 0) {
        _feltDisappointed = true;
      }
    });
  }

  void _showCommentBottomSheet(List<Comment> markComments) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0), // Adjust the radius as needed
        ),
      ),
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        return SizedBox(
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
                        (firstReaction! + secondReaction! == 0)
                            ? Container()
                            : Row(
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
                              ),
                        SizedBox(
                          width: ((firstReaction! + secondReaction! == 0)
                                  ? 0.75
                                  : 0.55) *
                              MediaQuery.of(context).size.width,
                        ),
                        widget.post.mark != 0
                            ? widget.post.mark == 1
                                ? const Text(
                                    '1 mark',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  )
                                : Text(
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
                          if (widget.post.isFelt == -1) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  title: const Text(
                                      'Bạn chưa thả feel cho bài viết này'),
                                  content: const Text(
                                      'Vui lòng thả feel cho bài viết trước khi comment'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Đóng'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            if (commentController.text.isNotEmpty) {
                              var body = {
                                'id': widget.post.postId,
                                'content': commentController.text,
                                'type': 0,
                                'index': markComments.length + 1,
                                'count': 10,
                                'type': widget.post.isFelt
                              };
                              var response = await http.post(
                                  Uri.parse('$root/set_mark_comment'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json',
                                    'Authorization': token
                                  },
                                  body: jsonEncode(body));
                              var responseBody = jsonDecode(response.body);
                              print(responseBody);
                              if (int.parse(responseBody['code']) == 1000) {
                                Navigator.pop(context);
                                Comment tmp = new Comment(
                                    user: StaticVariable.currentUser,
                                    time: DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ")
                                        .format(DateTime.now()),
                                    content: commentController.text);
                                setState(() {
                                  markComments.add(tmp);
                                });
                              }
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget showImages(List<String> imageLinks) {
    int length = imageLinks.length;
    List<Image> images = [];
    List<StaggeredGridTile> imageTiles = [];

    for (var imageLink in imageLinks) {
      images.add(Image.network(imageLink, fit: BoxFit.cover));
    }

    switch (length) {
      case 1:
        return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ImageFullscreenPage(post: widget.post)));
            },
            child: images[0]);
      case 2:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[0]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[1]]),
              )),
        ];
      case 3:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[0]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[1]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[2]]),
              )),
        ];
      case 4:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[0]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[1]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[2]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[3]]),
              )),
        ];
      default:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[0]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[1]]),
              )),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(fit: StackFit.expand, children: [images[2]]),
              )),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Stack(fit: StackFit.expand, children: [images[3]]),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      //Code xem ảnh muốn đăng tải ở đây
                    },
                    child: Container(
                      color: Colors.black54.withOpacity(0.4),
                      child: Center(
                          child: Text(
                        "+${length - 4}",
                        style: const TextStyle(
                            color: GlobalVariables.backgroundColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w500),
                      )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ];
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultipleImagesPage(post: widget.post)));
      },
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        children: imageTiles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme:
              const IconThemeData(color: GlobalVariables.backgroundColor),
          titleSpacing: 0,
          centerTitle: true,
          backgroundColor: GlobalVariables.secondaryColor.withOpacity(0.75),
          toolbarHeight: 50,
          title: Text(
            'Bài viết của ${widget.post.user.name}',
            style: const TextStyle(
                color: GlobalVariables.backgroundColor,
                fontSize: 19,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black12,
                              width: 0.5,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final user = User(
                                  userId: widget.post.user.userId,
                                  name: widget.post.user.name,
                                  avatar: widget.post.user.avatar);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PersonalPage(user: user)),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(widget.post.user.avatar),
                            ),
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
                                    SizedBox(
                                      width: 0.63 *
                                          MediaQuery.of(context).size.width,
                                      child: RichText(
                                        overflow: TextOverflow.fade,
                                        text: TextSpan(children: [
                                          TextSpan(
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                final user = User(
                                                  userId:
                                                      widget.post.user.userId,
                                                  name: widget.post.user.name,
                                                  avatar:
                                                      widget.post.user.avatar,
                                                  totalFriends: widget
                                                      .post.user.totalFriends,
                                                );
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PersonalPage(
                                                              user: user)),
                                                );
                                              },
                                            text: widget.post.user.name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: (widget.post.status!.isEmpty)
                                                ? ""
                                                : "\nis feeling ${widget.post.status!}",
                                            style: const TextStyle(
                                              color: GlobalVariables.iconColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    TimeConvert().convert(widget.post.time),
                                    style: const TextStyle(
                                        color: GlobalVariables.navIconColor,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.circle,
                                      size: 2,
                                      color: GlobalVariables.iconColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.public,
                                    color: GlobalVariables.iconColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  (widget.post.isModified!)
                                      ? const Icon(Icons.edit,
                                          color: GlobalVariables.iconColor,
                                          size: 14)
                                      : Container()
                                ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                                    StaticVariable
                                                        .currentUser.userId)
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
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                                    StaticVariable
                                                        .currentUser.userId)
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
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                                      ListTileTitleAlignment
                                                          .center,
                                                  leading: const Icon(
                                                    Icons.feedback_rounded,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                  title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Báo cáo bài viết',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: GlobalVariables.darkGreyColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: PostContent(
                  text: widget.post.content!,
                  textColor: GlobalVariables.blackNavIcon,
                ),
              ),
              (widget.post.image!.isEmpty)
                  ? Container()
                  : showImages(widget.post.image!),
              Material(
                color: Colors.transparent,
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
                            avatar: (item['feel']['user']['avatar'] as String)
                                    .isEmpty
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
                            : Row(
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
                                        '${firstReaction! + secondReaction!} ',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        SizedBox(
                          width: ((firstReaction! + secondReaction! == 0)
                                  ? 0.75
                                  : 0.55) *
                              MediaQuery.of(context).size.width,
                        ),
                        widget.post.mark != 0
                            ? widget.post.mark == 1
                                ? const Text(
                                    '1 mark',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  )
                                : Text(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: (MediaQuery.of(context).size.width) / 3,
                    child: InkWell(
                      onTap: () async {
                        if (_feltDisappointed == true) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                title: Text('Bài viết đã có feel'),
                                content: Text(
                                    'Vui lòng xoá feel truóc của bạn để thêm feel mới'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Đóng'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          setState(() {
                            _feltKudos = !_feltKudos;

                            if (firstReaction != null) {
                              if (_feltKudos == true) {
                                firstReaction = firstReaction! + 1;
                              } else
                                firstReaction = firstReaction! - 1;
                            }
                          });
                        }
                        if (_feltKudos == true) {
                          var body = {'id': widget.post.postId, 'type': 1};
                          var response = await http.post(
                              Uri.parse('$root/feel'),
                              headers: <String, String>{
                                'Content-Type': 'application/json',
                                'Authorization': token
                              },
                              body: jsonEncode(body));
                          var responseBody = jsonDecode(response.body);
                          if (responseBody['code'] == 1000) {
                            StaticVariable.currentUser.coins =
                                StaticVariable.currentUser.coins! - 1;
                          } else if (responseBody['code'] == 1) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  title: Text('Bạn không đủ coin'),
                                  content: Text(
                                      'Vui lòng nạp thêm coin để thực hiện hành động'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Đóng'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            setState(() {
                              firstReaction = firstReaction! + 1;
                              _feltKudos = false;
                            });
                          }
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
                                  size: 24,
                                  color: GlobalVariables.secondaryColor)
                              : Icon(
                                  MdiIcons.thumbUpOutline,
                                  size: 24,
                                  color: GlobalVariables.navIconColor,
                                ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              "Tin thật",
                              style: TextStyle(
                                  color: _feltKudos
                                      ? GlobalVariables.secondaryColor
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
                        if (_feltKudos == true) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                title: Text('Bài viết đã có feel'),
                                content: Text(
                                    'Vui lòng xoá feel truóc của bạn để thêm feel mới'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Đóng'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          setState(() {
                            _feltDisappointed = !_feltDisappointed;

                            if (secondReaction != null) {
                              if (_feltDisappointed == true) {
                                secondReaction = secondReaction! + 1;
                              } else
                                secondReaction = secondReaction! - 1;
                            }
                          });
                        }
                        if (_feltDisappointed == true) {
                          var body = {'id': widget.post.postId, 'type': 0};
                          var response = await http.post(
                              Uri.parse('$root/feel'),
                              headers: <String, String>{
                                'Content-Type': 'application/json',
                                'Authorization': token
                              },
                              body: jsonEncode(body));
                          var responseBody = jsonDecode(response.body);
                          print(responseBody);
                          if (responseBody['code'] == 1000) {
                            StaticVariable.currentUser.coins =
                                StaticVariable.currentUser.coins! - 1;
                          } else if (responseBody['code'] == 1) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  title: Text('Bạn không đủ coin'),
                                  content: Text(
                                      'Vui lòng nạp thêm coin để thực hiện hành động'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Đóng'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            setState(() {
                              secondReaction = secondReaction! + 1;
                              _feltDisappointed = false;
                            });
                          }
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
                                  color: GlobalVariables.navIconColor,
                                ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              "Tin giả",
                              style: TextStyle(
                                  color: _feltDisappointed
                                      ? GlobalVariables.redColor
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
                        List<Comment> data =
                            (responseBody['data'] as List<dynamic>).map((item) {
                          return Comment(
                            commentId: int.parse(item['id']),
                            content: item['mark_content'] as String,
                            typeOfMark: int.parse(item['type_of_mark']),
                            time: item['created'] as String,
                            user: User(
                              userId: int.parse(item['poster']['id']),
                              name: item['poster']['name'] as String,
                              avatar:
                                  (item['poster']['avatar'] as String).isEmpty
                                      ? defaultavt
                                      : item['poster']['avatar'] as String,
                            ),
                            comments: (item['comments'] as List<dynamic>)
                                .map((smallerItem) {
                              return Comment(
                                content: smallerItem['content'] as String,
                                time: smallerItem['created'] as String,
                                user: User(
                                  userId:
                                      int.parse(smallerItem['poster']['id']),
                                  name: smallerItem['poster']['name'] as String,
                                  avatar: (smallerItem['poster']['avatar']
                                              as String)
                                          .isEmpty
                                      ? defaultavt
                                      : smallerItem['poster']['avatar']
                                          as String,
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
                            color: GlobalVariables.navIconColor,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              'Mark',
                              style: TextStyle(
                                  color: GlobalVariables.navIconColor,
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
        ),
      ),
    );
  }
}
