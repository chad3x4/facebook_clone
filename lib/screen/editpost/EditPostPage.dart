import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/extension.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_player/video_player.dart';

import '../../model/Post.dart';
import '../home/HomePage.dart';
import '../newsfeed/widgets/VideoPlayerCard.dart';

class EditPostPage extends StatefulWidget {
  Post post;
  EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late VideoPlayerController controller;
  final _focusNode = FocusNode();
  bool _isTyping = false;
  final contentController = TextEditingController();
  List<XFile>? pickedFiles = [];
  bool _typeMedia = true; // true: images, false: video
  List<Image> images = [];
  String? status;
  var parser = EmojiParser();
  List<List<String>> emojis = [[':)', ':slightly_smiling_face:'], [':D', ':smiley:'], ['BD', ':sunglasses:'], [':*', ':kissing_heart:'], [':p', ':stuck_out_tongue_winking_eye:'], ['-_-', ':expressionless:'], [':(', ':disappointed:'], [':\'(', ':cry:'], ['TT', ':sob:']];

  @override
  void initState() {
    super.initState();
    contentController.text = widget.post.content ?? "";
    if (widget.post.video != null) {
      controller =
      VideoPlayerController.networkUrl(Uri.parse(widget.post.video![0]))
        ..initialize().then((_) {
          setState(() {
            controller.setVolume(1.0);
          });
        });
    }
  }

  @override
  void dispose() {
    // Dispose of the FocusNode when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 40,
        title: Row(
          children: [
            const Text('Chỉnh sửa bài viết'),
            const Spacer(),
            TextButton(
              onPressed: () async {
                Map<String, String> headers = {
                  "Content-Type": "multipart/form-data",
                  "Authorization": 'Bearer ${StaticVariable.currentSession.token}'
                };
                var request = http.MultipartRequest('POST',
                    Uri.parse('$root/edit_post'));

                if (images.isNotEmpty) {
                  for (var image in pickedFiles!) {
                    if (image != null) {
                      var subType = getSubType(image.path.split('/').last);
                      var imgFile = await http.MultipartFile.fromPath(
                          'image', image!.path,
                          contentType: MediaType('image', subType));
                      request.files.add(imgFile);
                    }
                  }
                } else if (pickedFiles!.isNotEmpty) {
                  var vidFile = await http.MultipartFile.fromPath('video', pickedFiles![0].path, contentType: MediaType('video', 'mp4'));
                  request.files.add(vidFile);
                }

                request.fields['id'] = widget.post.postId.toString();
                request.fields['described'] = contentController.text;
                if (status != null) {
                  request.fields['status'] = status!;
                }
                request.headers.addAll(headers);
                print(request.fields);

                request.send().then((response) {
                  response.stream
                      .transform(utf8.decoder)
                      .listen((value) {
                    print("Value: $value");
                    var valueBody = jsonDecode(value);
                    if (int.parse(valueBody['code']) == 1000) {
                      var data = json.decode(value)['data'];
                      print("Data: $data");
                      Navigator.pop(context);
                    }
                  });
                });
              },
              child: const Text(
                'SỬA',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            )
          ],
        ),
      ),
      body: Container(
        height: 0.9 * MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(StaticVariable.currentUser.avatar),
                            radius: 30,
                          ),
                          title: Text(
                            StaticVariable.currentUser.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: GlobalVariables.iconColor),
                                    onPressed: () {},
                                    icon: const Icon(Icons.public),
                                    label: const Text('Public'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: GlobalVariables.iconColor),
                                    onPressed: () {},
                                    icon: const Icon(Icons.add),
                                    label: const Row(
                                      children: [
                                        Text('Album'),
                                        Expanded(
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextFormField(
                          onChanged: (e) {
                            var text = contentController.text;
                            for (var emoji in emojis) {
                              text = text.replaceAll(emoji[0]!, emoji[1]!);
                            }
                            setState(() {
                              contentController.text = parser.emojify(text);
                            });
                          },
                          controller: contentController,
                          focusNode: _focusNode,
                          onTap: () {
                            setState(() {
                              _isTyping = true;
                            });
                          },
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Bạn đang nghĩ gì?',
                            hintStyle: TextStyle(
                                fontSize: 20,
                                color: GlobalVariables.iconColor
                            ),
                          ),
                        ),
                        (pickedFiles!.isNotEmpty)
                            ? FutureBuilder(
                            future: showMedia(pickedFiles!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              } else if (snapshot.hasError) {
                                print(snapshot.error);
                                return const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text('Không tải được ảnh!'));
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: CircularProgressIndicator(color: GlobalVariables.secondaryColor,),
                                );
                              }
                            }
                        )
                            : (widget.post.image!.isEmpty && widget.post.video == null)
                              ? Container()
                              : (widget.post.video == null)
                                ? showPostMedia(widget.post.image!, true)
                                : showPostMedia(widget.post.video!, false),
                        (_isTyping)
                            ? Container()
                            : Column(
                          children: [
                            const Divider(
                              thickness: 0.3,
                              color: GlobalVariables.greyBackgroundColor,
                            ),
                            ListTile(
                              onTap: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        alignment: Alignment.center,
                                        backgroundColor: GlobalVariables.backgroundColor,
                                        title: const Center(child: Text('Đăng tải Ảnh/Video')),
                                        content: Container(
                                            height: 25,
                                            child: const Center(child: Text(
                                              'Chọn loại dữ liệu muốn đăng tải',
                                              textAlign: TextAlign.center,
                                            ))),
                                        actions: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                    onPressed: () async {
                                                      setState(() {
                                                        _typeMedia = true;
                                                      });
                                                      final picker = ImagePicker();
                                                      pickedFiles = await picker.pickMultiImage();
                                                      print(pickedFiles);
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          MdiIcons.image,
                                                          color: Colors.white,
                                                        ),
                                                        const Text(
                                                          "Ảnh",
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: GlobalVariables.secondaryColor),
                                                    onPressed: () async {
                                                      setState(() {
                                                        _typeMedia = false;
                                                      });
                                                      final picker = ImagePicker();
                                                      var pickedFile = await picker.pickVideo(
                                                          source: ImageSource.gallery, maxDuration: const Duration(seconds: 5));
                                                      setState(() {
                                                        pickedFiles = [];
                                                        pickedFiles!.add(pickedFile!);
                                                      });
                                                      print(pickedFiles);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          MdiIcons.video,
                                                          color: Colors.white,
                                                        ),
                                                        const Text(
                                                            "Video",
                                                            style: TextStyle(color: Colors.white)
                                                        )
                                                      ],
                                                    )
                                                ),
                                              )
                                            ],
                                          ),

                                        ],
                                      );
                                    }
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.image,
                                color: Colors.green,
                                size: 30,
                              ),

                              title: const Text(
                                "Ảnh/Video",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 0.3,
                              color: GlobalVariables.greyBackgroundColor,
                            ),
                            ListTile(
                              onTap: () {},
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.person_add_alt_1,
                                color: Colors.blue,
                                size: 30,
                              ),
                              title: const Text(
                                "Gắn thẻ người khác",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 0.3,
                              color: GlobalVariables.greyBackgroundColor,
                            ),
                            ListTile(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        insetPadding: EdgeInsets.all(8),
                                        alignment: Alignment.center,
                                        backgroundColor: GlobalVariables.backgroundColor,
                                        title: const Center(child: Text('Cảm xúc của bạn')),
                                        content: Container(
                                            height: 25,
                                            child: const Center(child: Text(
                                              'Bạn đang cảm thấy thế nào',
                                              textAlign: TextAlign.center,
                                            ))),
                                        actions: [
                                          Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.zero,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            alignment: Alignment.center
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            status = 'Happy';
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Text(
                                                              "Vui vẻ 😊",
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.zero,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                                        onPressed: () {
                                                          setState(() {
                                                            status = 'Worried';
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Text(
                                                                "Lo lắng 😰",
                                                                style: TextStyle(color: Colors.white)
                                                            )
                                                          ],
                                                        )
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.zero,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.green,
                                                            alignment: Alignment.center
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            status = 'Hyped';
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Text(
                                                              "Hào hứng 🤩",
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.zero,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: GlobalVariables.secondaryColor),
                                                        onPressed: () {
                                                          setState(() {
                                                            status = "Not Hyped";
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Text(
                                                                "Chán nản 😞",
                                                                style: TextStyle(color: Colors.white)
                                                            )
                                                          ],
                                                        )
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),

                                        ],
                                      );
                                    }
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.insert_emoticon,
                                color: GlobalVariables.yellowColor,
                                size: 30,
                              ),
                              title: const Text(
                                "Cảm xúc/hoạt động",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 0.3,
                              color: GlobalVariables.greyBackgroundColor,
                            ),
                            ListTile(
                              onTap: () {},
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.place,
                                color: GlobalVariables.redColor,
                                size: 30,
                              ),
                              title: const Text(
                                "Gắn thẻ người khác",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            (_isTyping)
                ? Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).viewInsets.bottom - 7,
              child: Container(
                padding: const EdgeInsets.only(left: 6.0, top: 10, bottom: 10),
                color: GlobalVariables.backgroundColor,
                child: Row(
                  children: [
                    const Text(
                      "Thêm vào bài viết của bạn",
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      child: const Icon(
                          Icons.image,
                          size: 24.0,
                          color: Colors.green
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                alignment: Alignment.center,
                                backgroundColor: GlobalVariables.backgroundColor,
                                title: const Center(child: Text('Đăng tải Ảnh/Video')),
                                content: Container(
                                    height: 25,
                                    child: const Center(child: Text(
                                      'Chọn loại dữ liệu muốn đăng tải',
                                      textAlign: TextAlign.center,
                                    ))),
                                actions: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            onPressed: () async {
                                              setState(() {
                                                _typeMedia = true;
                                              });
                                              final picker = ImagePicker();
                                              pickedFiles = await picker.pickMultiImage();
                                              print(pickedFiles);
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  MdiIcons.image,
                                                  color: Colors.white,
                                                ),
                                                const Text(
                                                  "Ảnh",
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: GlobalVariables.secondaryColor),
                                            onPressed: () async {
                                              setState(() {
                                                _typeMedia = false;
                                              });
                                              final picker = ImagePicker();
                                              var pickedFile = await picker.pickVideo(
                                                  source: ImageSource.gallery, maxDuration: const Duration(seconds: 5));
                                              pickedFiles!.add(pickedFile!);
                                              print(pickedFiles);
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  MdiIcons.video,
                                                  color: Colors.white,
                                                ),
                                                const Text(
                                                    "Video",
                                                    style: TextStyle(color: Colors.white)
                                                )
                                              ],
                                            )
                                        ),
                                      )
                                    ],
                                  ),

                                ],
                              );
                            }
                        );
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      child: const Icon(
                          Icons.person_add_alt_1,
                          size: 24.0,
                          color: Colors.blue
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      child: const Icon(
                          Icons.emoji_emotions,
                          size: 24.0,
                          color: GlobalVariables.yellowColor
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                insetPadding: EdgeInsets.all(8),
                                alignment: Alignment.center,
                                backgroundColor: GlobalVariables.backgroundColor,
                                title: const Center(child: Text('Cảm xúc của bạn')),
                                content: Container(
                                    height: 25,
                                    child: const Center(child: Text(
                                      'Bạn đang cảm thấy thế nào',
                                      textAlign: TextAlign.center,
                                    ))),
                                actions: [
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.zero,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    alignment: Alignment.center
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    status = 'Happy';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Row(
                                                  children: [
                                                    Text(
                                                      "Vui vẻ 😊",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ],
                                                )
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.zero,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                                onPressed: () {
                                                  setState(() {
                                                    status = 'Worried';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Row(
                                                  children: [
                                                    Text(
                                                        "Lo lắng 😰",
                                                        style: TextStyle(color: Colors.white)
                                                    )
                                                  ],
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.zero,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    alignment: Alignment.center
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    status = 'Hyped';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Row(
                                                  children: [
                                                    Text(
                                                      "Hào hứng 🤩",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ],
                                                )
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.zero,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: GlobalVariables.secondaryColor),
                                                onPressed: () {
                                                  setState(() {
                                                    status = "Not Hyped";
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Row(
                                                  children: [
                                                    Text(
                                                        "Chán nản 😞",
                                                        style: TextStyle(color: Colors.white)
                                                    )
                                                  ],
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),

                                ],
                              );
                            }
                        );
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      child: const Icon(
                          Icons.place,
                          size: 24.0,
                          color: GlobalVariables.redColor
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
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

  Widget showPostMedia(List<String> medias, bool isImage) {
    int length = medias.length;
    Image image;
    List<StaggeredGridTile> imageTiles = [];

    if (isImage) {
      for (var media in medias) {
        image = Image.network(media);
        images.add(image);
      }
    }

    switch (length) {
      case 1:
        if (isImage) {
          return Image(image: images[0].image,);
        } else {
          print("Phát video ${medias[0]}");
          return Stack(
            alignment: Alignment.center,
            children: [
              controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: FlickVideoPlayer(flickManager: FlickManager(videoPlayerController: controller)),
              )
                  : const CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 5,
              )
            ],
          );
        }
      case 2:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
        ];
        break;
      case 3:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[2].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
        ];
      case 4:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[2].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[3].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
        ];
      default:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[2].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: images[3].image,
                          fit: BoxFit.cover,
                        ),
                      ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
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
                                fontWeight: FontWeight.w500
                            ),
                          )
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ];
    }

    return StaggeredGrid.count(
      crossAxisCount: 2,
      children: imageTiles,
    );
  }

  Future<Widget> showMedia(List<XFile> pickedFiles) async {
    int length = pickedFiles.length;
    Image image;
    List<StaggeredGridTile> imageTiles = [];

    if (_typeMedia) {
      for (var pickedFile in pickedFiles) {
        File result = File(pickedFile.path);
        image = await convertFileToImage(result);
        images.add(image);
      }
    }

    switch (length) {
      case 1:
        if (_typeMedia) {
          return Image(image: images[0].image,);
        } else {
          print("Phát video ${pickedFiles[0].path}");
          return VideoPlayerCard(video: File(pickedFiles[0].path));
        }
      case 2:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
        ];
        break;
      case 3:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[2].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
        ];
      case 4:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[2].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[3].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
        ];
      default:
        imageTiles = <StaggeredGridTile>[
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[0].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[1].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: images[2].image,
                        fit: BoxFit.cover,
                      ),
                    ]
                ),
              )
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: images[3].image,
                          fit: BoxFit.cover,
                        ),
                      ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
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
                                fontWeight: FontWeight.w500
                            ),
                          )
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ];
    }

    return StaggeredGrid.count(
      crossAxisCount: 2,
      children: imageTiles,
    );
  }

  Future<Image> convertFileToImage(File picture) async {
    List<int> imageBase64 = picture.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    Image image = Image.memory(uint8list);
    return image;
  }
}