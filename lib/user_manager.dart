class UserManager {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  String? _username;

  String? get username => _username;

  set username(String? username) {
    _username = username;
  }
}
