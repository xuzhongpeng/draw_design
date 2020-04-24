import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:gm_platform_channels/gm_platform_channels.dart';
import 'package:path_provider/path_provider.dart';
import 'package:staff_performance/config/dic.dart';
import 'package:staff_performance/config/dio.dart';
import 'package:gm_uikit/src/gm_sputils.dart';
class CenterUtils {
  factory CenterUtils() => _instance;

  static final _instance = CenterUtils._singleTon();
  CenterUtils._singleTon();

  ///app的code 指明是pro 还是mini
  String appCode;
  //userdata
  int userId;
  int entranceUser = 0; //账号管理入口权限
  int companyId = 0; //公司id,由原生传入 329
  bool isAdmin = false; //是否是法人
  bool isManager = false; //是否是管理员或者合伙人

  //true为在本项目中启动 false为在trojan启动
  bool isSingle = false;

  // 主页 店铺 员工 设置切换（设置在这主要是解决进入设置返回到第一个页面的问题）
  static int pageIndex = 0;

  ///在入口需要初始化该数据,或者数据会出错
  Future<void> initialCenterConfig({@required BuildContext context}) async {
    StaffDio dio = new StaffDio();
    dio.init();
    Map map = await GmSpUtil.getMap("token");
    final Map<dynamic, dynamic> result = await ChannelUtil.invokeUserData();
    String token=map!=null&&map['value']!=""?map['value']:result['token'];
    this.appCode = result['projectId'];
    userId = result['userId'];
    entranceUser = result['entranceUser'];
    companyId = result['companyId'];
    isAdmin = result['isAdmin'] == 1 ?? false;
    isManager = result['role'] == 1 ?? false; //1为法人 2为店长 3为销售员
    //设置token值
    dio.setRequestToken(token);
    //设置url值
    String baseUrl = await _getBaseUrl();
    dio.setRequestBaseUrl(baseUrl);
  }

  Future<String> _getBaseUrl() async {
    const baseUrl = 'https://api3c.duoke.net';
    // return 'http://api3-alpha.duoke.net';
    //const baseUrl = 'https://api3-beta.duoke.net'; //beta环境 测试用的
    //const baseUrl = 'http://api3-alpha.duoke.net'; //alpha 调试接口用
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/ServerAddress.json').create();
    String contents = await file.readAsString();
    String url;
    try {
      Map<String, dynamic> dc = jsonDecode(contents);
      url = dc['servers'][dc['current']]['urls']['native']['url'];
      url = url + '/p';
    } catch (e) {
      url = baseUrl;
    }
    // if (!kReleaseMode) return 'http://api3-test.duoke.net';

    return url;
  }

  static APP_TARGET appIdentity() {
    const miniCodes = ['404', '403', '402', '401'];
    const proCodes = ['301', '302', '303', '304', '305'];
    APP_TARGET appTarget = APP_TARGET.pro;
    if (miniCodes.indexOf(CenterUtils().appCode) != -1)
      appTarget = APP_TARGET.mini;
    if (proCodes.indexOf(CenterUtils().appCode) != -1)
      appTarget = APP_TARGET.pro;
    return appTarget;
  }

  static dynamic getImagePackage() {
    return CenterUtils().isSingle ? null : 'staff_performance';
  }
}
