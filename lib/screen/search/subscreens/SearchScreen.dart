import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/screen/newsfeed/widgets/PostCard.dart';
import 'package:flutter_application_2/screen/watch/widgets/WatchCard.dart';
import 'package:http/http.dart' as http;
import 'package:inview_notifier_list/inview_notifier_list.dart';

import '../../../model/Post.dart';
import '../../../model/User.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearchClicked = false;
  final token = 'Bearer ${StaticVariable.currentSession.token}';
  bool _isLoading = false;
  FocusNode _focusNode = FocusNode();
  List<String> items = [
    'Items 1',
    'Messi',
    'Ronaldo',
    'Virat Kohli',
    '2',
    'Rock',
    'Elon Musk',
  ];
  List<Post> searchResults = [];

  List<String> filteredItems = [];
  @override
  void initState() {
    super.initState();
  }

  Future<List<Post>> loadPost(String text) async {
    List<Post> posts = [];
    var body = {
      "keyword": _searchController.text,
      "index": 0,
      "count": 10
    };
    var response = await http.post(Uri.parse('$root/search'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(body));
    var responseBody = jsonDecode(response.body);
    if (int.parse(responseBody['code']) == 1000) {
      var postData = responseBody['data'];
      print(postData);
      for (var item in postData) {
        var author = item['author'];
        List<String>? images = (item['image'] as List)
            ?.map((image) => image['url'] as String)
            ?.toList();
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
            mark: int.parse(item['mark_comment']),
            status: item['state'],
            isModified: false,
            isFelt: int.parse(item['is_felt']) == 0 ? -1 : 1
        );
        posts.add(newPost);
      }
    } else {
      print("Có lỗi khi lấy bài mới");
      print(responseBody);
    }
    return posts;
  }

  void _onSearchIconTap() async {
    setState(() {
      _isLoading = true;
    });
    try{
      String searchTerm = _searchController.text;
      searchResults = await loadPost(searchTerm);
      setState(() {});
      print(searchResults);
    } catch(error) {
      print('Error during search: $error');
    }
    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.greyCommentColor.withOpacity(0.2),
        titleSpacing: 0,
        centerTitle: true,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                width: 0.7 * MediaQuery.of(context).size.width,
                height: 40,
                decoration: BoxDecoration(
                  color: GlobalVariables.greyCommentColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onTapOutside: (e) {
                    _focusNode.unfocus();
                  },
                  focusNode: _focusNode,
                  controller: _searchController,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      hintText: 'Tìm kiếm'),
                ),
              ),
            ),
            InkWell(
                onTap: _onSearchIconTap,
                child: const Icon(Icons.search)
            )
          ],
        ),
      ),
      body: _isLoading
        ? const Center(
          child: CircularProgressIndicator(
            color: GlobalVariables.secondaryColor,
          ),
        )
        : InViewNotifierList(
          isInViewPortCondition:
              (double deltaTop, double deltaBottom, double vpHeight) {
            return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
          },
          itemCount: searchResults.length,
          builder: (BuildContext context, int index) {
            return InViewNotifierWidget(
                id: '$index',
                builder: (BuildContext context, bool isInView, Widget? child) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 5,
                        color: Colors.black26,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: (searchResults[index].video != null)
                            ? WatchCard(
                              post: searchResults[index],
                              autoPlay: isInView ? true : false
                            )
                            : PostCard(post: searchResults[index], isNFPost: true),
                      ),
                    ],
                  );
                }
            );
          }
      ),
    );
  }
}