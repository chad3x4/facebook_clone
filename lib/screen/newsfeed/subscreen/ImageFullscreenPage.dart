import 'package:flutter/material.dart';

import '../../../model/Post.dart';
import '../../../operation/TimeConvert.dart';
import '../widgets/PostContent.dart';

class ImageFullscreenPage extends StatefulWidget {
  static const String routeName = '/image-fullscreen';
  final Post post;
  const ImageFullscreenPage({super.key, required this.post});

  @override
  State<ImageFullscreenPage> createState() => _ImageFullscreenPageState();
}

class _ImageFullscreenPageState extends State<ImageFullscreenPage> {
  List<String> icons = [];
  String reactions = '0';
  bool contentVisible = true;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          contentVisible = !contentVisible;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onVerticalDragUpdate: (details) {
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.post.image![0]),
              ),
            ),
            child: contentVisible
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 15,
                                ),
                                child: Text(
                                  widget.post.user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                ),
                                child: PostContent(
                                  text: widget.post.content!,
                                  textColor: Colors.white,
                                  type: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                ),
                                child: Text(
                                  TimeConvert().convert(widget.post.time),
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.4),
                          child: GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
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
                                                        color: Colors.black,
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
                                      if (reactions.isNotEmpty && icons.isNotEmpty)
                                        Text(
                                          reactions,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                  ),
          ),
        ),
      ),
    );
  }
}
