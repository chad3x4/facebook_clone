import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:http/http.dart' as http;
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:video_player/video_player.dart';

import '../../../model/Post.dart';
import '../../../model/User.dart';
import '../widgets/WatchCard.dart';


class WatchScreen extends StatefulWidget {
  static double offset = 0;
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class VideoControllerWrapper {
  VideoPlayerController? value;
  VideoControllerWrapper(this.value);
}

class _WatchScreenState extends State<WatchScreen> {
  ScrollController scrollController =
  ScrollController(initialScrollOffset: WatchScreen.offset);
  ScrollController headerScrollController = ScrollController();
  String token = "Bearer ${StaticVariable.currentSession.token}";
  int index = 0;
  int count = 10;
  Future<List<Post>>? storedFuture;
  List<Post> posts = [];
  List<GlobalKey> key = [];
  bool reloadAll = false;

  @override
  void initState() {
    super.initState();
    storedFuture = loadNewVideos(30);
    scrollController.addListener(() async {
      if (scrollController.offset >= scrollController.position.maxScrollExtent - 800) {
        var newPosts = await loadListVideos(count, 10);
        setState(() {
          posts.addAll(newPosts);
          count += 10;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    headerScrollController.dispose();
    super.dispose();
  }

  Future<List<Post>> loadNewVideos(int count) async {
      reloadAll = false;
      List<Post> posts = [];
      var body = {
        "index": 0,
        "count": "$count"
      };
      var response = await http.post(Uri.parse('$root/get_list_videos'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token
          },
          body: jsonEncode(body));
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      if (int.parse(responseBody['code']) == 1000) {
        var postData = responseBody['data']['post'];
        for (var item in postData) {
          var author = item['author'];
          final newPost = Post(
              postId: int.parse(item['id']),
              user: User(
                  userId: int.parse(author['id']),
                  name: author['name'],
                  avatar: (author['avatar'] as String).isEmpty
                      ? defaultavt
                      : author['avatar']
              ),
              time: item['created'],
              content: item['described'],
              video: item['video'] == null ? null : [item['video']['url']],
              kudos: int.parse(item['feel']),
              disappointed: 0,
              mark: int.parse(item['comment_mark']),
              status: item['state'],
              isModified: false,
              isFelt: int.parse(item['is_felt'])
          );
          posts.add(newPost);
        }
      } else {
        print("Có lỗi khi lấy bài mới");
      }
      return posts;
  }

  Future<List<Post>> loadListVideos(int index, int count) async {
    reloadAll = false;
    List<Post> posts = [];
    var body = {
      "index": '$index',
      "count": "$count"
    };
    var response = await http.post(Uri.parse('$root/get_list_videos'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(body));
    var responseBody = jsonDecode(response.body);
    print(responseBody);
    if (int.parse(responseBody['code']) == 1000) {
      var postData = responseBody['data']['post'];
      for (var item in postData) {
        var author = item['author'];
        final newPost = Post(
            postId: int.parse(item['id']),
            user: User(
                userId: int.parse(author['id']),
                name: author['name'],
                avatar: (author['avatar'] as String).isEmpty
                    ? defaultavt
                    : author['avatar']
            ),
            time: item['created'],
            content: item['described'],
            video: item['video'] == null ? null : [item['video']['url']],
            kudos: int.parse(item['feel']),
            disappointed: 0,
            mark: int.parse(item['comment_mark']),
            status: item['state'],
            isModified: false,
            isFelt: int.parse(item['is_felt'])
        );
        posts.add(newPost);
      }
    } else {
      print("Có lỗi khi lấy bài mới");
    }
    return posts;
  }


  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      headerScrollController.jumpTo(headerScrollController.offset +
          scrollController.offset -
          WatchScreen.offset);
      WatchScreen.offset = scrollController.offset;
    });
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: NestedScrollView(
          controller: headerScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              toolbarHeight: 100,
              titleSpacing: 0,
              pinned: true,
              floating: true,
              primary: false,
              centerTitle: true,
              automaticallyImplyLeading: false,
              snap: true,
              forceElevated: innerBoxIsScrolled,
              bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(0), child: SizedBox()),
              title: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Video',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 35,
                              height: 35,
                              padding: const EdgeInsets.all(0),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black12,
                              ),
                              child: IconButton(
                                splashRadius: 18,
                                padding: const EdgeInsets.all(0),
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 35,
                              height: 35,
                              padding: const EdgeInsets.all(0),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black12,
                              ),
                              child: IconButton(
                                splashRadius: 18,
                                padding: const EdgeInsets.all(0),
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  index = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: (index == 0)
                                    ? BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                )
                                    : const BoxDecoration(),
                                child: Text(
                                  'Dành cho bạn',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: index == 0
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: index == 0
                                        ? Colors.blue[800]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  index = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: (index == 1)
                                    ? BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                )
                                    : const BoxDecoration(),
                                child: Text(
                                  'Đang theo dõi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: index == 1
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: index == 1
                                        ? Colors.blue[800]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
          body: FutureBuilder(
            future: storedFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return InViewNotifierList(
                    isInViewPortCondition:
                        (double deltaTop, double deltaBottom, double vpHeight) {
                      return deltaTop < (0.5 * vpHeight) &&
                          deltaBottom > (0.5 * vpHeight);
                    },
                    itemCount: snapshot.data!.length,
                    builder: (BuildContext context, int index) {
                      return InViewNotifierWidget(
                          id: '$index',
                          builder: (BuildContext context, bool isInView,
                              Widget? child) {
                            return Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 5,
                                  color: Colors.black26,
                                ),
                                WatchCard(
                                  post: snapshot.data![index],
                                  autoPlay: isInView ? true : false,
                                ),
                              ],
                            );
                          }
                      );
                    }
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('Not found!!!'));
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: GlobalVariables.secondaryColor,
                    ),
                  ),
                );
              }
            }
          )
        ),
      ),
    );
  }

  Future refresh() async {
    storedFuture = loadNewVideos(40);
    setState(() {
      posts.clear();
    });
  }
}
