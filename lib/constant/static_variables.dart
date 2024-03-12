import 'package:async/async.dart';
import 'package:flutter_application_2/model/Session.dart';

import '../model/Notification.dart';
import '../model/Post.dart';
import '../model/User.dart';

class StaticVariable {
  static AsyncMemoizer<List<Post>> memCache = AsyncMemoizer();
  static AsyncMemoizer<List<Noti>> memCache1 = AsyncMemoizer();
  static AsyncMemoizer<List<Post>> memCache2 = AsyncMemoizer();
  static late String deviceId;
  static late String name;
  static late User currentUser;
  static late Session currentSession;
}
