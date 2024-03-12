import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/extension.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../model/Post.dart';
import '../../model/User.dart';
import '../newsfeed/widgets/PostCard.dart';
import '../watch/widgets/WatchCard.dart';

class PersonalPage extends StatefulWidget {
  final User user;
  const PersonalPage({super.key, required this.user});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  File? image;
  late String filename;
  late Image avt;
  bool _isImage = true;
  final TextEditingController searchController = TextEditingController();
  final token = 'Bearer ${StaticVariable.currentSession.token}';
  bool isMine = false;
  int mutualFriends = 0;
  int? coin = StaticVariable.currentUser.coins;
  var userBody;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  void getUserInfo() async {
    var body = {"user_id": widget.user.userId};
    var response = await http.post(Uri.parse('$root/get_user_info'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(body));

    setState(() {
      userBody = jsonDecode(response.body)['data'];
    });
    print(userBody);
  }

  Future<File?> uploadFile() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    List<String> imageFormat = ['.png', '.jpg', '.svg', 'jpeg'];

    if (pickedFile != null) {
      File result = File(pickedFile.path ?? " ");
      filename = result.path.split('/').last;
      if (imageFormat.contains(filename.lastChars(4).toLowerCase())) {
        _isImage = true;
        return result;
      } else {
        setState(() {
          setState(() {
            _isImage = false;
          });
        });
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Image> convertFileToImage(File picture) async {
    List<int> imageBase64 = picture.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    Image image = Image.memory(uint8list);
    return image;
  }

  String getSubType(String filename) {
    var subType = filename.lastChars(4).toLowerCase();
    switch (subType) {
      case '.jpg':
        return 'jpg';
      case '.png':
        return 'png';
      case '.svg':
        return 'svg';
      case 'jpeg':
        return 'jpeg';
      default:
        return 'Not an image';
    }
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
          isModified: (data['modified'] as String).contains('1'));
      return newPost;
    } else {
      return null;
    }
  }

  Future<List<User>> loadFriend(int userId) async {
    var body = {"index": 0, "count": 6, "user_id": widget.user.userId};
    var response = await http.post(Uri.parse('$root/get_user_friends'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(body));
    var responseBody = jsonDecode(response.body);
    print(responseBody);
    List<User> friend =
        (responseBody['data']['friends'] as List<dynamic>).map((item) {
      return User(
          userId: int.parse(item['id']),
          name: item['username'],
          avatar: item['avatar'],
          sameFriends: int.parse(item['same_friends']));
    }).toList();
    return friend;
  }

  Future<List<Post>> loadPostFromUser(int userId) async {
    List<Post> posts = [];
    Map<String, String> body;
    if (isMine) {
      body = {
        "user_id": "$userId",
        "in_campaign": "1",
        "campaign_id": "1",
        "latitude": "1.0",
        "longitude": "1.0",
        "index": "0",
        "count": "20"
      };
    } else {
      body = {
        "user_id": "$userId",
        "in_campaign": "1",
        "campaign_id": "1",
        "latitude": "1.0",
        "longitude": "1.0",
        "index": "0",
        "count": "5"
      };
    }
    var response = await http.post(Uri.parse('$root/get_list_posts'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token
        },
        body: jsonEncode(body));
    var responseBody = jsonDecode(response.body);
    if (int.parse(responseBody['code']) == 1000) {
      final postsData = responseBody['data']['post'];
      final postsId = postsData.map((e) => int.parse(e['id']));
      for (int i in postsId) {
        Post? newPost = await loadPost(i);
        posts.add(newPost!);
      }
    } else {
      print("Có lỗi khi lấy bài từ user $userId");
    }
    return posts;
  }

  Future<List<Map<String, dynamic>>?> SendFriendRequest(int userId) async {
    try {
      var body = {
        'user_id': widget.user.userId,
      };

      var response = await http.post(
        Uri.parse('$root/set_request_friend'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(body),
      );

      var responseBody = jsonDecode(response.body);
      print(responseBody);

      if (int.parse(responseBody['code']) == 1000) {
        return responseBody['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = widget.user;

    if (user.email != StaticVariable.currentUser.email) {
      // Code lấy số bạn chung ở đây
    } else {
      setState(() {
        isMine = true;
      });
    }
    if (userBody != null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                color: Colors.black12,
                width: double.infinity,
                height: 0.5,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              splashRadius: 20,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 30,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                      top: 5,
                      bottom: 5,
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Tìm kiếm',
                        hintStyle: const TextStyle(
                          fontSize: 18,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: GlobalVariables.greyBackgroundColor,
                            size: 25,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 45, maxHeight: 41),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[200],
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      cursorColor: Colors.black,
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    height: 270,
                  ),
                  userBody['cover_image'].toString().isNotEmpty
                      ? Image.network(
                          userBody['cover_image'],
                          fit: BoxFit.cover,
                          height: 220,
                          width: double.infinity,
                        )
                      : Container(
                          width: double.infinity,
                          height: 220,
                          color: GlobalVariables.greyBackgroundColor,
                        ),
                  Positioned(
                    left: 15,
                    bottom: 0,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: (image != null)
                              ? CircleAvatar(
                                  backgroundImage: avt.image,
                                  radius: 75,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(user.avatar),
                                  radius: 75,
                                ),
                        ),
                        if (isMine)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    image = await uploadFile();
                                    print(image);
                                    if (image != null) {
                                      avt = await convertFileToImage(image!);
                                      Map<String, String> headers = {
                                        "Content-Type": "multipart/form-data",
                                        "Authorization": token
                                      };
                                      var request = http.MultipartRequest(
                                          'POST',
                                          Uri.parse('$root/set_user_info'));

                                      var subType = getSubType(filename);
                                      var avtFile =
                                          await http.MultipartFile.fromPath(
                                              'avatar', image!.path,
                                              contentType:
                                                  MediaType('image', subType));
                                      request.files.add(avtFile);

                                      request.headers.addAll(headers);

                                      request.send().then((response) {
                                        response.stream
                                            .transform(utf8.decoder)
                                            .listen((value) {
                                          print("Value: $value");
                                          var valueBody = jsonDecode(value);
                                          if (int.parse(valueBody['code']) ==
                                              1000) {
                                            var data =
                                                json.decode(value)['data'];
                                            StaticVariable.currentUser.avatar =
                                                data['avatar'];
                                          }
                                        });
                                      });
                                    }
                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                )),
                          ),
                      ],
                    ),
                  ),
                  if (isMine)
                    Positioned(
                      bottom: 65,
                      right: 15,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                image = await uploadFile();
                                print(image);
                                if (image != null) {
                                  avt = await convertFileToImage(image!);
                                  Map<String, String> headers = {
                                    "Content-Type": "multipart/form-data",
                                    "Authorization": token
                                  };
                                  var request = http.MultipartRequest(
                                      'POST', Uri.parse('$root/set_user_info'));

                                  var subType = getSubType(filename);
                                  var avtFile =
                                      await http.MultipartFile.fromPath(
                                          'cover_image', image!.path,
                                          contentType:
                                              MediaType('image', subType));
                                  request.files.add(avtFile);

                                  request.headers.addAll(headers);

                                  request.send().then((response) {
                                    response.stream
                                        .transform(utf8.decoder)
                                        .listen((value) {
                                      print("Value: $value");
                                      var valueBody = jsonDecode(value);
                                      if (int.parse(valueBody['code']) ==
                                          1000) {
                                        var data = json.decode(value)['data'];
                                        StaticVariable.currentUser.cover =
                                            data['cover_image'];
                                      }
                                    });
                                  });
                                }
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (user.bio != null)
                      Text(
                        user.bio!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    (isMine)
                        ? Container()
                        : Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: userBody['is_friend']
                                        .toString()
                                        .contains('1')
                                    ? ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor: Colors.grey[200],
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ImageIcon(
                                              AssetImage(
                                                  'assets/images/friend.png'),
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Bạn bè',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () => SendFriendRequest(
                                            widget.user.userId),
                                        style: ElevatedButton.styleFrom(
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor:
                                              GlobalVariables.secondaryColor,
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(MdiIcons.accountPlus,
                                                size: 18, color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Thêm bạn bè',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 3,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor:
                                        GlobalVariables.secondaryColor,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ImageIcon(
                                        AssetImage('assets/images/message.png'),
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Nhắn tin',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                              16.0), // Adjust the radius as needed
                                        ),
                                      ),
                                      builder: (BuildContext context) {
                                        double screenWidth =
                                            MediaQuery.of(context).size.width;
                                        double screenHeight =
                                            MediaQuery.of(context).size.height;
                                        return Wrap(
                                          children: <Widget>[
                                            Container(
                                                height: 0.2 * screenHeight,
                                                width: screenWidth,
                                                child: Column(
                                                  children: [
                                                    Row(children: [
                                                      InkWell(
                                                          onTap: () async {
                                                            var body = {
                                                              "user_id": widget
                                                                  .user.userId
                                                            };
                                                            var response = await http.post(
                                                                Uri.parse(
                                                                    '$root/set_block'),
                                                                headers: <String,
                                                                    String>{
                                                                  'Content-Type':
                                                                      'application/json',
                                                                  'Authorization':
                                                                      token
                                                                },
                                                                body:
                                                                    jsonEncode(
                                                                        body));
                                                            var responseBody =
                                                                jsonDecode(
                                                                    response
                                                                        .body);
                                                          },
                                                          child: Text(
                                                            'Block',
                                                          ))
                                                    ]),
                                                  ],
                                                ))
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.grey[200],
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz_rounded,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              if (isMine)
                Container(
                  width: double.infinity,
                  height: 10,
                  color: GlobalVariables.greyBackgroundColor,
                ),
              if (isMine)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số coin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        StaticVariable.currentUser.coins.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: GlobalVariables.secondaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          var body = {
                            "email": StaticVariable.currentUser.email
                          };
                          var response = await http.post(
                              Uri.parse('$root/get_verify_code'),
                              headers: <String, String>{
                                'Content-Type': 'application/json',
                                'Authorization': token
                              },
                              body: jsonEncode(body));
                          print(jsonDecode(response.body));
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              double screenWidth =
                                  MediaQuery.of(context).size.width;
                              double screenHeight =
                                  MediaQuery.of(context).size.height;
                              TextEditingController codeController =
                                  TextEditingController();
                              TextEditingController coinController =
                                  TextEditingController();
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                title: Text('Nhập số coin bạn muốn nạp'),
                                content: Container(
                                    height: 0.2 * screenHeight,
                                    child: Column(
                                      children: [
                                        TextField(
                                            controller: codeController,
                                            decoration: InputDecoration(
                                              labelText: 'Mã Xác nhận',
                                            )),
                                        TextField(
                                            controller: coinController,
                                            decoration: InputDecoration(
                                              labelText: 'Số coin',
                                            )),
                                      ],
                                    )),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Gửi'),
                                    onPressed: () async {
                                      var body = {
                                        "code": codeController.text,
                                        "coins": int.parse(coinController.text),
                                      };
                                      var response = await http.post(
                                          Uri.parse('$root/buy_coins'),
                                          headers: <String, String>{
                                            'Content-Type': 'application/json',
                                            'Authorization': token
                                          },
                                          body: jsonEncode(body));
                                      var responseBody =
                                          jsonDecode(response.body);
                                      print(responseBody);
                                      if (int.parse(responseBody["code"]) ==
                                          1000) {
                                        setState(() {
                                          print(responseBody['data']['coins']);
                                          StaticVariable.currentUser.coins =
                                              responseBody['data']['coins'];
                                          print(
                                              "Current coin: ${StaticVariable.currentUser.coins}");
                                        });
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.add,
                          size: 25,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isMine)
                Container(
                  width: double.infinity,
                  height: 10,
                  color: GlobalVariables.greyBackgroundColor,
                ),
              if (isMine)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Bài viết',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              isMine
                  ? Container(
                      width: double.infinity,
                      color: Colors.black12,
                      height: 0.5,
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      width: double.infinity,
                      color: Colors.black12,
                      height: 0.5,
                    ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMine)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Chi tiết',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    if (userBody['address'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.home,
                              size: 25,
                              color: Colors.black54,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                'Sống tại ${userBody['address']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (userBody['city'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_city,
                              size: 25,
                              color: Colors.black54,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                'Thành phố ${userBody['city']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (userBody['country'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 25,
                              color: Colors.black54,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                'Đến từ ${userBody['country']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: InkWell(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.more_horiz_rounded,
                                size: 25,
                                color: Colors.black54,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  isMine
                                      ? 'Xem thông tin giới thiệu của bạn'
                                      : 'Xem thông tin giới thiệu của ${user.name}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (isMine)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    TextEditingController usernameController =
                                        TextEditingController(
                                            text: widget.user.name);
                                    TextEditingController
                                        descriptionController =
                                        TextEditingController(
                                            text: userBody['description']);
                                    TextEditingController addressController =
                                        TextEditingController(
                                            text: userBody['address']);
                                    TextEditingController cityController =
                                        TextEditingController(
                                            text: userBody['city']);
                                    TextEditingController countryController =
                                        TextEditingController(
                                            text: userBody['country']);
                                    TextEditingController linkController =
                                        TextEditingController(
                                            text: userBody['link']);
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      title:
                                          Text('Chỉnh sửa chi tiết công khai'),
                                      content: Column(
                                        children: [
                                          TextField(
                                              controller: usernameController,
                                              decoration: InputDecoration(
                                                labelText: 'Tên',
                                              )),
                                          TextField(
                                              controller: descriptionController,
                                              decoration: InputDecoration(
                                                labelText: 'Mô tả',
                                              )),
                                          TextField(
                                              controller: addressController,
                                              decoration: InputDecoration(
                                                labelText: 'Địa chỉ',
                                              )),
                                          TextField(
                                              controller: cityController,
                                              decoration: InputDecoration(
                                                labelText: 'Thành phố',
                                              )),
                                          TextField(
                                              controller: countryController,
                                              decoration: InputDecoration(
                                                labelText: 'Đất nước',
                                              )),
                                          TextField(
                                              controller: linkController,
                                              decoration: InputDecoration(
                                                labelText: 'Link',
                                              )),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Gửi'),
                                          onPressed: () async {
                                            Map<String, String> headers = {
                                              "Content-Type":
                                                  "multipart/form-data",
                                              "Authorization": '$token'
                                            };
                                            var request = http.MultipartRequest(
                                                'POST',
                                                Uri.parse(
                                                    '$root/set_user_info'));
                                            request.fields['username'] =
                                                usernameController.text;
                                            request.fields['description'] =
                                                descriptionController.text;
                                            request.fields['address'] =
                                                addressController.text;
                                            request.fields['city'] =
                                                cityController.text;
                                            request.fields['country'] =
                                                countryController.text;
                                            request.fields['link'] =
                                                linkController.text;

                                            request.headers.addAll(headers);
                                            print(request.fields);
                                            request.send().then((response) {
                                              response.stream
                                                  .transform(utf8.decoder)
                                                  .listen((value) {
                                                print("Value: $value");
                                                var valueBody =
                                                    jsonDecode(value);
                                                if (int.parse(
                                                        valueBody['code']) ==
                                                    1000) {
                                                  var data = json
                                                      .decode(value)['data'];
                                                  print("Data: $data");
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            PersonalPage(
                                                                user: widget
                                                                    .user)),
                                                  );
                                                }
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Chỉnh sửa chi tiết công khai',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isMine)
                Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Colors.black12,
                ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bạn bè',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        if (isMine)
                          Text(
                            'Tìm bạn bè',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[700],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        text: "${userBody['listing']} người bạn",
                        style: const TextStyle(
                          color: GlobalVariables.borderInputColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FutureBuilder(
                        future: loadFriend(widget.user.userId),
                        builder: ((context, snapshot) {
                          if (snapshot.hasData) {
                            List<User> topFriends = snapshot.data!;
                            print(snapshot);
                            return Column(
                              children: [
                                if (topFriends.length != null)
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (int i = 0;
                                            i < min(3, topFriends!.length);
                                            i++)
                                          GestureDetector(
                                              onTap: () {
                                                final user = User(
                                                    userId:
                                                        topFriends[i].userId,
                                                    name: topFriends[i].name,
                                                    avatar: topFriends[i]
                                                            .avatar
                                                            .isNotEmpty
                                                        ? topFriends[i].avatar
                                                        : defaultavt);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PersonalPage(
                                                              user: user)),
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      topFriends[i]
                                                              .avatar
                                                              .isNotEmpty
                                                          ? topFriends[i].avatar
                                                          : defaultavt,
                                                      width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              100) /
                                                          3,
                                                      height: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              100) /
                                                          3,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                100) /
                                                            3,
                                                    child: Text(
                                                      topFriends![i].name,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        for (int i = min(3, topFriends!.length);
                                            i < 3;
                                            i++)
                                          SizedBox(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    100) /
                                                3,
                                          ),
                                      ],
                                    ),
                                  ),
                                if (topFriends.length > 3)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                if (topFriends.length > 3)
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (int i = 3;
                                            i < min(6, topFriends!.length);
                                            i++)
                                          GestureDetector(
                                              onTap: () {
                                                final user = User(
                                                    userId:
                                                        topFriends[i].userId,
                                                    name: topFriends[i].name,
                                                    avatar: topFriends[i]
                                                            .avatar
                                                            .toString()
                                                            .isNotEmpty
                                                        ? topFriends[i].avatar
                                                        : defaultavt);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PersonalPage(
                                                              user: user)),
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      topFriends[i]
                                                              .avatar
                                                              .isNotEmpty
                                                          ? topFriends[i].avatar
                                                          : defaultavt,
                                                      width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              100) /
                                                          3,
                                                      height: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              100) /
                                                          3,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: 40,
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                100) /
                                                            3,
                                                    child: Text(
                                                      topFriends![i].name,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        for (int i = min(6, topFriends!.length);
                                            i < 6;
                                            i++)
                                          SizedBox(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    100) /
                                                3,
                                          ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: const Text(
                                          'Xem tất cả bạn bè',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(
                                child: Text('Xảy ra lỗi khi lấy dữ liệu'));
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        })),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 10,
                width: double.infinity,
                color: GlobalVariables.greyBackgroundColor,
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bài viết',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    if (isMine)
                      Text(
                        'Bộ lọc',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue[700],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 15,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar),
                        radius: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: GlobalVariables.borderInputColor,
                                width: 2),
                          ),
                          hintText: isMine
                              ? 'Bạn đang nghĩ gì?'
                              : 'Viết gì đó cho ${user.name}',
                        ),
                      ),
                    ),
                    IconButton(
                      splashRadius: 20,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.green,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 10,
                color: GlobalVariables.greyBackgroundColor,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Ảnh',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 10,
                color: GlobalVariables.greyBackgroundColor,
              ),
              FutureBuilder(
                  future: loadPostFromUser(widget.user.userId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      double screenWidth = MediaQuery.of(context).size.width;
                      return Column(
                        children: snapshot.data!.isEmpty
                            ? <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  width: screenWidth,
                                  color: GlobalVariables.greyBackgroundColor,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(top: 15, bottom: 12),
                                    child: Text(
                                      "Không có bài viết",
                                      style: TextStyle(
                                          color: GlobalVariables.navIconColor,
                                          fontSize: 16),
                                    ),
                                  ),
                                )
                              ]
                            : snapshot.data!
                                .map((e) => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        (e.video != null)
                                            ? WatchCard(
                                                post: e,
                                                autoPlay: false,
                                                isNFPost: true,
                                              )
                                            : PostCard(post: e),
                                        Container(
                                          width: double.infinity,
                                          height: 5,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ))
                                .toList(),
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Center(
                          child: Text('Xảy ra lỗi khi lấy dữ liệu'));
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          ),
        ),
      );
    } else {
      return const Row(children: [
        CircularProgressIndicator(
          color: GlobalVariables.primaryColor,
        )
      ]);
    }
  }
}
