import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_2/screen/watch/subscreen/WatchPage.dart';
import 'package:video_player/video_player.dart';

import '../../../model/Post.dart';
import '../../../model/User.dart';
import '../widgets/WatchCard.dart';

class WatchFullPage extends StatefulWidget {
  final VideoPlayerController controllerInit;
  final Post postInit;
  const WatchFullPage({
    super.key,
    required this.controllerInit,
    required this.postInit,
  });

  @override
  State<WatchFullPage> createState() => _WatchFullPageState();
}

class _WatchFullPageState extends State<WatchFullPage> {
  final keyInit = GlobalKey();
  ScrollController scrollController = ScrollController();
  int index = 0;
  List<VideoControllerWrapper> videoController = [];
  final posts = [
    // Post(
    //   postId: 1,
    //   user: User(
    //       userId: 1,
    //       name: 'Aki Michio',
    //       avatar: 'assets/images/user/aki.jpg'),
    //   time: '14 thg 7, 2022',
    //   content: 'Xinh quá đi',
    //   kudos: 10,
    //   disappointed: 5,
    //   mark: 10,
    //   video: ['assets/videos/1.mp4'],
    //   isModified: false
    // ),
    // Post(
    //   postId: 2,
    //   user: User(
    //       userId: 2,
    //       name: 'Spezon',
    //       avatar: 'assets/images/user/spezon.jpg'
    //   ),
    //   time: '27 tháng 8',
    //   content: 'Quá trời xinh',
    //   kudos: 30,
    //   disappointed: 5,
    //   mark: 0,
    //   video: ['assets/videos/2.mp4'],
    //   isModified: true
    // ),
  ];
  List<GlobalKey> key = [];

  @override
  void initState() {
    super.initState();
    videoController =
        List.generate(posts.length, (index) => VideoControllerWrapper(null));
    key = List.generate(
        posts.length, (index) => GlobalKey(debugLabel: index.toString()));
  }

  @override
  void dispose() {
    scrollController.dispose();

    /*for (int i = 0; i < videoController.length; i++) {
      videoController[i].value?.dispose();
    }*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.black87,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                color: Colors.black12,
                height: 0.5,
              )),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                splashRadius: 20,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const Expanded(
                child: Text(
                  'Video khác',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () {},
                splashRadius: 20,
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              )
            ],
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scroll) {
          var currentContext = keyInit.currentContext;
          if (currentContext != null) {
            var renderObject = currentContext.findRenderObject();
            RenderAbstractViewport viewport =
            RenderAbstractViewport.of(renderObject);
            var offsetToRevealBottom =
            viewport.getOffsetToReveal(renderObject!, 1.0);
            var offsetToRevealTop =
            viewport.getOffsetToReveal(renderObject, 0.0);

            if (offsetToRevealBottom.offset > scroll.metrics.pixels ||
                scroll.metrics.pixels > offsetToRevealTop.offset) {
              //print('$i out of viewport');
            } else {
              //print('$i in viewport');
              if (widget.controllerInit.value != null) {
                if (widget.controllerInit.value.isInitialized) {
                  widget.controllerInit.play();
                }
              }
              return false;
            }
          }
          for (int i = 0; i < posts.length; i++) {
            var currentContext = key[i].currentContext;
            if (currentContext == null) continue;

            var renderObject = currentContext.findRenderObject();
            RenderAbstractViewport viewport =
            RenderAbstractViewport.of(renderObject);
            var offsetToRevealBottom =
            viewport.getOffsetToReveal(renderObject!, 1.0);
            var offsetToRevealTop =
            viewport.getOffsetToReveal(renderObject, 0.0);

            if (offsetToRevealBottom.offset > scroll.metrics.pixels ||
                scroll.metrics.pixels > offsetToRevealTop.offset) {
              //print('$i out of viewport');
            } else {
              //print('$i in viewport');
              if (videoController[i].value != null) {
                if (videoController[i].value!.value.isInitialized) {
                  videoController[i].value!.play();
                }
              }
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Column(
                children: [
                  WatchCard(
                    post: widget.postInit,
                    autoPlay: true,
                    isDarkMode: true,
                  ),
                  Container(
                    width: double.infinity,
                    height: 5,
                    color: Colors.black87,
                  ),
                  ...posts.asMap().entries.map((e) {
                    return Column(
                      children: [
                        WatchCard(
                          post: e.value,
                          autoPlay: false,
                          isDarkMode: true,
                        ),
                        Container(
                          width: double.infinity,
                          height: 5,
                          color: Colors.black87,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
