import 'package:flutter/foundation.dart' show ChangeNotifier;

class UserModel with ChangeNotifier {
  String name = 'come on man';

  void setName(name) {
    this.name = name;
    notifyListeners();
  }
}
