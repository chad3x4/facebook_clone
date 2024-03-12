import 'package:flutter_application_2/model/User.dart';

class Post {
  final int? postId;
  final User user;
  final String time;
  final List<String>? image;
  final List<String>? video;
  final String? content;
  final int? kudos;
  final int? disappointed;
  final int? isFelt;
  final int? mark;
  final String? layout; // classic, column, quote, frame
  final String? status;
  final bool? isModified;
  final int? isBlocked;

  Post(
      {required this.postId,
      required this.user,
      required this.time,
      this.isFelt,
      this.image,
      this.video,
      this.content,
      this.kudos,
      this.disappointed,
      this.mark,
      this.status,
      this.isBlocked,
      this.isModified,
      this.layout});

  Post copyWith(
      {int? postId,
      User? user,
      String? time,
      List<String>? image,
      List<String>? video,
      String? content,
      int? kudos,
      int? disappointed,
      int? mark,
      String? layout,
      String? status,
      bool? isModified,
      int? isFelt,
      int? isBlocked}) {
    return Post(
        postId: postId ?? this.postId,
        user: user ?? this.user,
        time: time ?? this.time,
        image: image ?? this.image,
        video: video ?? this.video,
        content: content ?? this.content,
        kudos: kudos ?? this.kudos,
        disappointed: disappointed ?? this.disappointed,
        mark: mark ?? this.mark,
        layout: layout ?? this.layout,
        status: status ?? this.status,
        isModified: isModified ?? this.isModified,
        isFelt: isFelt ?? this.isFelt,
        isBlocked: isBlocked ?? this.isBlocked);
  }
}
