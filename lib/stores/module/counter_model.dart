/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-07 16:06:33
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-08-13 17:06:08
 */
import 'package:flutter/foundation.dart' show ChangeNotifier;

class Counter with ChangeNotifier {
  int count = 0;

  void increment() {
    count++;
    notifyListeners();
  }

  void decrement() {
    count--;
    count--;
    notifyListeners();
  }
}
