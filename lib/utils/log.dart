import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
const DEBUG = !kReleaseMode;

class L{
  static p(String msg){
    if (DEBUG) {
      debugPrint(msg);
    }
  }
  
  static void printMap(dynamic debugiInfo) {
    if (DEBUG) {
      print('打印调试信息-------->$debugiInfo');
    }
  }
}