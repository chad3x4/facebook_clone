import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/screen/createpost/CreatePostPage.dart';
import 'package:http/http.dart' as http;

import '../../../constant/global_variables.dart';
import '../../../model/Post.dart';
import '../../../model/User.dart';
import '../../watch/widgets/WatchCard.dart';
import '../widgets/PostCard.dart';

class NewsFeedScreen extends StatefulWidget {
  static double offset = 0;
  final ScrollController parentScrollController;
  const NewsFeedScreen({super.key, required this.parentScrollController});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  Color colorNewPost = Colors.transparent;
  final token = 'Bearer ${StaticVariable.currentSession.token}';
  int count = 10;
  // Avoid loadListPosts multiple times when the scroll stuck to wait for API
  bool condition = true;
  List<Post> posts = [];
  bool reloadAll = false;

  ScrollController scrollController =
      ScrollController(initialScrollOffset: NewsFeedScreen.offset);

  Future<List<Post>>? storedFuture;

  @override
  void initState() {
    super.initState();
    storedFuture = loadNewPosts(10, false);
    scrollController.addListener(() async {
      if (scrollController.offset >= scrollController.position.maxScrollExtent - 200) {
        if (condition) {
          setState(() {
            condition = false;
          });
          var newPosts = await loadListPosts(count, 10);
          setState(() {
            posts.addAll(newPosts);
            count += 10;
            condition = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<List<Post>> loadListPosts(int index, int count) async {
      reloadAll = false;
      List<Post> posts = [];
      var body = {
        "index": "$index",
        "count": "$count"
      };
      var response = await http.post(Uri.parse('$root/get_list_posts'),
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
          List<String>? images = (item['image'] as List)
              .map((image) => image['url'] as String)
              .toList();
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
              image: images,
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

  Future<List<Post>> loadNewPosts(int count, bool reload) async {
    if (reload) {
      setState(() {
        StaticVariable.memCache = AsyncMemoizer();
      });
      reloadAll = false;
      List<Post> posts = [];
      var body = {"count": "$count"};
      var response = await http.post(Uri.parse('$root/get_new_posts'),
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
          List<String>? images = (item['image'] as List)
              .map((image) => image['url'] as String)
              .toList();
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
              image: images,
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
    } else {
      return StaticVariable.memCache.runOnce(() async {
        List<Post> posts = [];
        var body = {"count": "$count"};
        var response = await http.post(Uri.parse('$root/get_new_posts'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': token
            },
            body: jsonEncode(body));
        var responseBody = jsonDecode(response.body);
        if (int.parse(responseBody['code']) == 1000) {
          var postData = responseBody['data']['post'];
          for (var item in postData) {
            var author = item['author'];
            List<String>? images = (item['image'] as List)
                .map((image) => image['url'] as String)
                .toList();
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
                image: images,
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: CircleAvatar(
                      foregroundImage:
                          NetworkImage(StaticVariable.currentUser.avatar),
                      radius: 15,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        setState(() {
                          colorNewPost = Colors.transparent;
                        });
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreatePostPage()),
                        );
                        refresh();
                      },
                      onTapUp: (tapUpDetails) {
                        setState(() {
                          colorNewPost = Colors.black12;
                        });
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: Colors.black12,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          color: colorNewPost,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text('Bạn đang nghĩ gì?'),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    splashRadius: 20,
                    onPressed: () {},
                    icon: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 4,
              color: Colors.black26,
            ),
            FutureBuilder(
                future: storedFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!
                          .map((e) => Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              (e.video != null)
                              ? WatchCard(
                                post: e,
                                autoPlay: false,
                                isNFPost: true
                              )
                              : PostCard(post: e, isNFPost: true),
                              Container(
                                width: double.infinity,
                                height: 5,
                                color: Colors.black26,
                              ),
                            ],
                          )).toList(),
                      );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text('Not found!!!'));
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(
                        color: GlobalVariables.secondaryColor,
                      ),
                    );
                  }
                }),
            Column(
              children: posts
                  .map((e) => Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  (e.video != null)
                      ? WatchCard(
                      post: e,
                      autoPlay: false,
                      isNFPost: true
                  )
                      : PostCard(post: e, isNFPost: true),
                  Container(
                    width: double.infinity,
                    height: 5,
                    color: Colors.black26,
                  ),
                ],
              )).toList(),
            )
          ],
        ),
      ),
    );
  }

  Future refresh() async {
    final results = loadNewPosts(10, true);
    setState(() {
      storedFuture = Future.value(results);
      posts.clear();
    });
  }
}
