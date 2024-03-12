import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../constant/global_variables.dart';
import '../../../model/Post.dart';
import '../../../operation/TimeConvert.dart';
import '../widgets/PostContent.dart';
import '../widgets/SingleImage.dart';

class MultipleImagesPage extends StatefulWidget {
  final Post post;
  const MultipleImagesPage({super.key, required this.post});

  @override
  State<MultipleImagesPage> createState() => _MultipleImagesPageState();
}

class _MultipleImagesPageState extends State<MultipleImagesPage> {
  List<String> icons = [];
  String reactions = '0';
  final Random random = Random();
  int totalReactions = 0;
  @override
  void initState() {
    List<int> list = [
      widget.post.kudos != null ? widget.post.kudos! : 0,
      widget.post.disappointed != null ? widget.post.disappointed! : 0
    ];
    list.sort((a, b) => b - a);
    int sum = 0;
    for (int i = 0; i < list.length; i++) {
      sum += list[i];
    }
    setState(() {
      if (sum > 0) {
        totalReactions = sum;
      } else {
        totalReactions = 1;
      }
      reactions = '';
      String tmp = sum.toString();
      int x = 0;
      for (int i = tmp.length - 1; i > 0; i--) {
        x++;
        reactions = '${tmp[i]}$reactions';
        if (x == 3) reactions = '.$reactions';
      }
      reactions = '${tmp[0]}$reactions';
      icons = [];
      if (list[0] == widget.post.kudos) {
        icons.add('assets/images/reactions/like.png');
        icons.add('assets/images/reactions/dislike.png');
      } else if (list[0] == widget.post.disappointed) {
        icons.add('assets/images/reactions/dislike.png');
        icons.add('assets/images/reactions/like.png');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: GlobalVariables.backgroundColor),
        titleSpacing: 0,
        centerTitle: true,
        backgroundColor: GlobalVariables.secondaryColor.withOpacity(0.75),
        toolbarHeight: 50,
        title: Text(
          'Bài viết của ${widget.post.user.name}',
          style: const TextStyle(
            color: GlobalVariables.backgroundColor,
            fontSize: 19,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 10,
                ),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black12,
                          width: 0.5,
                        ),
                      ),
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  TimeConvert().convert(widget.post.time),
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 2, left: 5, right: 5),
                                  child: Icon(
                                    Icons.circle,
                                    size: 2,
                                    color: Colors.black54,
                                  ),
                                ),
                                const Icon(
                                  Icons.public,
                                  color: Colors.black54,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              PostContent(text: widget.post.content!),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Row(
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
                                if (icons.length > 1)
                                  Positioned(
                                    top: 2,
                                    left: 18,
                                    child: Image.asset(
                                      icons[1],
                                      width: 20,
                                    ),
                                  ),
                                if (icons.isNotEmpty)
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
                          if (reactions != '0')
                            Text(
                              reactions,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          widget.post.mark != 0
                              ? widget.post.mark == 1
                                  ? const Text(
                                    '1 mark',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  )
                                  : Text(
                                    '${widget.post.mark} marks',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 5,
                ),
                color: Colors.grey[400],
                height: 0.25,
                width: double.infinity,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 11.5,
                      ),
                      alignment: Alignment.centerLeft,
                      width: (MediaQuery.of(context).size.width) / 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.thumbUpOutline,
                            size: 24,
                            color: GlobalVariables.navIconColor,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              "Tin thật",
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
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      alignment: Alignment.centerRight,
                      width: (MediaQuery.of(context).size.width) / 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.thumbDownOutline,
                            size: 24,
                            color: GlobalVariables.navIconColor,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              "Tin giả",
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
                  InkWell(
                    onTap: () {},
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
                              "Mark",
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
              Container(
                width: double.infinity,
                height: 5,
                color: GlobalVariables.greyBackgroundColor,
              ),
              for (int i = 0; i < widget.post.image!.length; i++)
                Column(
                  children: [
                    SingleImage(
                      post: widget.post.copyWith(
                        image: [widget.post.image![i]],
                        kudos: widget.post.kudos,
                        disappointed: widget.post.disappointed,
                        mark: widget.post.mark,
                        content: '',
                      ),
                      familyImages: widget.post.image!,
                      index: i + 1,
                    ),
                    Container(
                      width: double.infinity,
                      height: 8,
                      color: GlobalVariables.greyBackgroundColor,
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
