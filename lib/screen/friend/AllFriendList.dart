import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:http/http.dart' as http;
import '../../model/User.dart';

class AllFriendList extends StatefulWidget {
  const AllFriendList({Key? key}) : super(key: key);

  @override
  State<AllFriendList> createState() => _AllFriendListState();
}

class FriendRequest {
  final User user;
  final String time;
  final User? f1;
  final User? f2;
  FriendRequest({
    required this.user,
    required this.time,
    this.f1,
    this.f2,
  });
}

class _AllFriendListState extends State<AllFriendList> {
  final today = DateTime.now();
  final token = 'Bearer ${StaticVariable.currentSession.token}';
  List<FriendRequest> friends = [];
  int itemCount = 0;
  Future<List<Map<String, dynamic>>?> get_user_friends() async {
    try {
      final token = 'Bearer ${StaticVariable.currentSession.token}';
      var body = {
        "index": 0,
        "count": 6,
      };
      var response = await http.post(
        Uri.parse('$root/get_user_friends'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(body),
      );

      var responseBody = jsonDecode(response.body);
      if (int.parse(responseBody['code']) == 1000) {
        final requestDataList = responseBody['data']['friends'];

        itemCount = responseBody['total'];
        friends = [];
        for (var requestData in requestDataList) {
          friends.add(
            FriendRequest(
              user: User(
                userId: requestData['id'],
                name: requestData['username'],
                avatar: requestData['avatar'],
              ),
              time: requestData['created'],
            ),
          );
        }
        print(friends);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    get_user_friends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Tất cả bạn bè',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            for (int i = 0; i < friends.length; i++)
              Padding(
                padding: const EdgeInsets.all(10),
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
                        backgroundImage: AssetImage(friends[i].user.avatar),
                        radius: 46,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                friends[i].user.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                friends[i].time,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
