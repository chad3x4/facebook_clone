import 'package:flutter_application_2/model/User.dart';

class Feel {
  final int? id;
  final User user;
  final int? type;

  Feel({
    required this.id,
    required this.user,
    required this.type,
  });

  Feel copyWith({
    int? id,
    User? user,
    int? type,
  }) {
    return Feel(
      id: id ?? this.id,
      user: user ?? this.user,
      type: type ?? this.type,
    );
  }
}
