import 'package:gm_uikit/gm_uikit.dart';
import 'package:flutter/material.dart';
import 'package:staff_performance/constant/constant.dart';
import 'package:staff_performance/pages/setting_performance_goal.dart';
import 'package:staff_performance/pages/setting_performance_indicator.dart';

// 业绩 = Performance
// 指标 = Indicator
// 目标 = Goal
class SettingPerformance extends StatefulWidget {
  @override
  _SettingPerformanceState createState() => _SettingPerformanceState();
}

class _SettingPerformanceState extends State<SettingPerformance>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width,
      color: ColorRes.bgGrey,
      child: Material(
        child: ListView(
          children: <Widget>[
            GMListViewItem(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: GMCommonWidget.topAndBottomBorderSide()),
              padding: EdgeInsets.only(left: 20),
              leading: GMCommonWidget.normalText("目标设置"),
              trailing: GMCommonWidget.forwardIcon(),
              callback: _goalSetClick,
              effectAble: true,
            ),
            GMListViewItem(
              padding: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: GMCommonWidget.bottomBorderSide()),
              leading: GMCommonWidget.normalText("常用指标设置"),
              trailing: GMCommonWidget.forwardIcon(),
              callback: _normalIndicatorSetClick,
              effectAble: true,
            ),
          ],
        ),
      ),
    );
  }

  _goalSetClick() {
    // showModalBottomSheet<Null>(context:context,
    //           backgroundColor: Colors.transparent,
    //           isScrollControlled: true,
    //           // shape: RoundedRectangleBorder (borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
    //           builder:(BuildContext context) {
    //           return GmDateChoose(
    //             dateConfirmed:(start, end, type){
    //               print("type$type start$start end$end");
    //             }
    //           );
    // });
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return SettingGoalPage();
    }));
  }

  _normalIndicatorSetClick() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return SettingIndicatorPage();
    }));
  }
}
