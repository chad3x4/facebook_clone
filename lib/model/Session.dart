class Session {
  String? username;
  String? token;
  String? uuid;

  Session(this.username, this.token, this.uuid);

  toMap() {
    var mapping = <String, dynamic>{};
    mapping['username'] = username;
    mapping['token'] = token;
    mapping['uuid'] = uuid;
    return mapping;
  }

  static fromMap(Map<String, dynamic> json) {
    return Session(json['username'], json['token'], json['uuid']);
  }
}