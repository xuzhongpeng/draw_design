/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-15 21:10:44
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-08-16 10:14:57
 * @Description: 本地使用GmProvider建立model
 */
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'dart:async';

class GmProvider extends ChangeNotifier {
  //重写notifyListeners目的是在initState中调用
  //notifyListeners不会报错
  @override
  void notifyListeners() {
    scheduleMicrotask(() {
      super.notifyListeners();
    });
  }
}
