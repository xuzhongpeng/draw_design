import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:gm_platform_channels/gm_platform_channels.dart';
import 'package:staff_performance/performance_main.dart';
import 'package:staff_performance/stores/index.dart';

class StaffPerformance extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StaffPerformance> {
  @override
  void initState() {
    super.initState();
    ChannelUtil.invokeBackGesture({'status': 1});
    registerService();
  }

  void registerService() {
    ChannelUtil.registerMethodCallHandler((MethodCall call) async {
      if (call.method == "pushReplace") {
        Navigator.pushReplacementNamed(context, call.arguments['routeName']);
      } else if (call.method == 'setState') {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    ChannelUtil.invokeBackGesture({'status': 0});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Store.init(
      context: context,
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Color(0xFF4D759C),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          cursorColor: Colors.blue,
          scaffoldBackgroundColor: Color.fromRGBO(244, 245, 246, 1.0),
        ),
        home: StartPage(),
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: PerformanceMain()),
    );
  }
}
