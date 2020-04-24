import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_performance/utils/center_util.dart';
import 'package:staff_performance/trojanMain.dart';
import 'package:gm_platform_channels/gm_platform_channels.dart';
import 'package:gm_uikit/gm_uikit.dart';
import 'package:developcenter/server_address.dart';

void main() async {
  await init();
  return runApp(MyApp());
}

Future init() async {
  final Map result = await ChannelUtil.invokeUserData();
  String appCode = result['projectId'];
  //uikit注册类 注册基本信息

  /// 初始化服务器地址
  await ServerManager.instance.requestServerAddresses();
  ChannelUtil.invokeGetServerAddressDone();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Map<String, WidgetBuilder> routes = {
    '/server-address': (BuildContext context) => ServerAddress(),
    'staffPerformance': (_) => StaffPerformance(),
  };
  @override
  Widget build(BuildContext context) {
    CenterUtils().isSingle = true;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        cupertinoOverrideTheme:
            CupertinoThemeData(primaryColor: GlobalConstant.themeColor),
        primaryColor: GlobalConstant.themeColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        cursorColor: GlobalConstant.themeColor,
        // scaffoldBackgroundColor: Color.fromRGBO(244, 245, 246, 1.0),
      ),
      routes: routes,
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: GlobalConstant.fontScale),
        );
      },
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ListView(
                children: routes.keys.map((route) {
              return GMListViewItem(
                leading: GMCommonWidget.normalText(route),
                trailing: GMCommonWidget.forwardIcon(),
                padding: EdgeInsets.only(left: 20),
                callback: () {
                  // FlutterBoost.singleton.openPage(route, {});
                  Navigator.pushNamed(context, route);
                },
                effectAble: true,
              );
            }).toList()),
          ),
        ),
      ),
    );
  }
}
