class Noti {
  final int objectId;
  final String content;
  final List<String>? bold;
  final String image;
  final String time;
  final int type;
  final bool? seen;
  final bool? isTrust;
  Noti(
      {required this.content,
        required this.objectId,
        this.bold,
        required this.image,
        required this.time,
        required this.type,
        this.seen,
        this.isTrust
      });
}


/* NOTIFICATIONS TYPES:

1. page - bỏ
2. group - bỏ
3. comment - 6. PostMarked, 9. PostCommented - reply 1 mark
4. friend - 1. FriendRequest
5. security - bỏ
6. date - bỏ
7. badge - bỏ
8-14: reactions - 5. PostFelt
15: memory - bỏ
 */
