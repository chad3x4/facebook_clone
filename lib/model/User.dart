class User {
  final int userId;
  final String? email;
  final String name;
  String avatar;
  String? cover;
  final String? bio;
  int? _coins;
  int? totalFriends;
  int? sameFriends;
  bool? isFriend;

  int? get coins => _coins;

  set coins(int? value) {
    _coins = value;
  }
  User(
      {required this.userId,
      this.email,
      required this.name,
      required this.avatar,
      this.cover,
      this.bio,
      this.totalFriends,
      this.sameFriends,
      this.isFriend,
      int? coins,}) : _coins = coins;

  User copyWith(
      {int? userId,
      String? email,
      String? name,
      String? avatar,
      String? cover,
      String? bio,
      int? coin,
      int? totalFriends,
      int? sameFriends}) {
    return User(
        userId: userId ?? this.userId,
        email: email ?? this.email,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        cover: cover ?? this.cover,
        bio: bio ?? this.bio,
        coins: coin ?? this.coins,
        totalFriends: totalFriends ?? this.totalFriends,
        sameFriends: sameFriends ?? this.sameFriends
    );
  }
}
