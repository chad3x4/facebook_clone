import 'package:flutter_application_2/model/User.dart';

class Comment {
  final int? commentId;
  final User user;
  final String time;
  final int? typeOfMark;
  String content;
  final List<Comment>? comments;

  Comment({
    this.commentId,
    required this.user,
    required this.time,
    required this.content,
    this.typeOfMark,
    this.comments,
  });

  Comment copyWith({
    int? commentId,
    User? user,
    String? time,
    int? typeOfMark,
    String? content,
    List<Comment>? comments,
  }) {
    return Comment(
      commentId: commentId ?? this.commentId,
      user: user ?? this.user,
      time: time ?? this.time,
      content: content ?? this.content,
    );
  }
}
