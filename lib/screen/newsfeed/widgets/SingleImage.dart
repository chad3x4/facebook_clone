import 'package:flutter/material.dart';

import '../../../model/Post.dart';
import '../subscreen/ImageFullscreenPage.dart';
import '../subscreen/MultipleImageFullscreenPage.dart';

class SingleImage extends StatelessWidget {
  final List<String> familyImages;
  final int index;
  final Post post;
  const SingleImage({super.key, required this.post, required this.familyImages, required this.index});

  @override
  Widget build(BuildContext context) {
    List<String> icons = [];
    String reactions = '0';
    List<int> list = [
      post.kudos != null ? post.kudos! : 0,
      post.disappointed != null ? post.disappointed! : 0
    ];
    list.sort((a, b) => b - a);
    int sum = 0;
    for (int i = 0; i < list.length; i++) {
      sum += list[i];
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
    if (list[0] == post.kudos) {
      icons.add('assets/images/reactions/like.png');
      icons.add('assets/images/reactions/dislike.png');
    } else if (list[0] == post.disappointed) {
      icons.add('assets/images/reactions/dislike.png');
      icons.add('assets/images/reactions/like.png');
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MultipleImageFullscreenPage(post: post, familyImages: familyImages, index: index,)),
            );
          },
          child: Image.network(
            post.image![0],
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 3
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
