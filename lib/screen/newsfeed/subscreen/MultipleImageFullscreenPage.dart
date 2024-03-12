import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/screen/newsfeed/subscreen/ImageFullscreenPage.dart';

import '../../../model/Post.dart';
import '../../../operation/TimeConvert.dart';
import '../widgets/PostContent.dart';

class MultipleImageFullscreenPage extends StatefulWidget {
  final Post post;
  final List<String> familyImages;
  final int index;
  const MultipleImageFullscreenPage({super.key, required this.post, required this.familyImages, required this.index});

  @override
  State<MultipleImageFullscreenPage> createState() => _MultipleImageFullscreenPageState();
}

class _MultipleImageFullscreenPageState extends State<MultipleImageFullscreenPage> {
  List<String> icons = [];
  String reactions = '0';
  bool contentVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.blackNavIcon,
      body: CarouselSlider.builder(
        itemCount: widget.familyImages.length,
        options: CarouselOptions(
          viewportFraction: 1,
          enableInfiniteScroll: false,
          height: MediaQuery.of(context).size.height,
          initialPage: widget.index - 1
        ),
        itemBuilder: (context, index, realIndex) {
          return ImageFullscreenPage(
              post: Post(
                postId: 1,
                user: widget.post.user,
                time: widget.post.time,
                isModified: false,
                content: '',
                image: [widget.familyImages[index]],
                kudos: widget.post.kudos,
                disappointed: widget.post.disappointed,
              )
          );
        },
        )
    );
  }
}
