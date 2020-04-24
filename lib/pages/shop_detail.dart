import 'package:flutter/material.dart';

import 'package:gm_uikit/gm_uikit.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:staff_performance/views/gm_table.dart';
// import 'package:staff_performance/model/peformance_data_manager.dart';
// import 'package:staff_performance/model/entities/performance_entity.dart';
// import 'package:staff_performance/config/dic.dart';
// import 'package:staff_performance/model/detail_model.dart';
import 'package:staff_performance/model/peformance_data_manager.dart';
import 'package:staff_performance/views/goal_ui.dart';
import 'package:staff_performance/model/entities/goal_entity.dart';
import 'package:staff_performance/stores/index.dart';

class DataMessage {
  ///店铺id
  String companyId;

  ///员工还是店铺
  String showType;

  ///type为0表示店铺，为1表示员工
  int type = 0;
  DataMessage(this.companyId, this.showType);
}

class ShopDetail extends StatefulWidget {
  final String ownerableType;
  final String ownerableId;
  final String userName;
  ShopDetail({this.ownerableType, this.ownerableId, this.userName});
  // final Map<String, dynamic> datas;
  // final DataMessage message;
  @override
  _ShopDetail createState() => _ShopDetail();
}

class _ShopDetail extends State<ShopDetail> {
  Map<String, dynamic> datas = new Map();
  Map<String, dynamic> target = new Map();
  DetailModel detailModel;
  Map<String, String> resData;
  int dateType = 0; //日期type
  bool showLoading = false;
  bool isOneDay; //日期不是同一天
  List<GoalEntity> goalList = new List();
  @override
  void didChangeDependencies() {
    resData = {
      "include": "payments,sales,items,customers",
      "ownerable_type": widget.ownerableType,
      "ownerable_id": widget.ownerableId,
      // "company_id": "6",
      "sday": PeformanceDataHandle.dateToString(DateTime.now(),
          format: 'yyyy-MM-dd'),
      "eday": PeformanceDataHandle.dateToString(DateTime.now(),
          format: 'yyyy-MM-dd'),
    };
    isOneDay = true;
    request();
  }

  //请求数据
  void request() async {
    Map<String, String> data = {
      'ownerable_type': widget.ownerableType,
      'ownerable_id': widget.ownerableId
    };
    detailModel = Store.value<DetailModel>(context);
    setState(() {
      showLoading = true;
    });
    try {
      widget.ownerableType == 'staff'
          ? detailModel.getTargetData(data).then((res) {
              setState(() {
                goalList = res;
              });
            }).catchError((e) {
              showLoading = false;
              GmToast.showToast('网络请求超时或错误');
            })
          : new List();
      datas = await detailModel.getData(resData);
    } catch (e) {
      showLoading = false;
      GmToast.showToast('网络请求超时或错误');
    }
    target = datas.remove('target');
    showLoading = false;
    setState(() {});
  }

  //显示日期
  String dateShow() {
    DateTime start = DateTime.parse(resData['sday']);
    DateTime end = DateTime.parse(resData['eday']);
    String format =
        dateType == 0 ? 'yyyy年MM月dd日' : dateType == 1 ? 'yyyy年MM月' : 'yyyy年';
    String startStr = PeformanceDataHandle.dateToString(start, format: format);
    String endStr = PeformanceDataHandle.dateToString(end, format: format);
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    bool isSame = dateType == 0
        ? start.compareTo(end) == 0
        : dateType == 1
            ? (start.year == end.year && start.month == end.month)
            : start.year == end.year;
    if (isSame) {
      isOneDay = true;
      if (start.year == now.year &&
          start.month == now.month &&
          start.day == now.day) {
        return '今日';
      } else if (start.year == yesterday.year &&
          start.month == yesterday.month &&
          start.day == yesterday.day) {
        return '昨日';
      } else {
        return startStr;
      }
    } else {
      isOneDay = false;
      return startStr + '-' + endStr;
    }
  }

  //日期加减
  dayChange(bool isAdd) {
    DateTime start = DateTime.parse(resData['sday']);
    DateTime end = DateTime.parse(resData['eday']);

    int syear = start.year;
    int smonth = start.month;
    int sday = start.day;
    int year = end.year;
    int month = end.month;
    int day = end.day;
    if (isAdd)
      dateType == 0
          ? {sday++, day++}
          : dateType == 1 ? {smonth++, month += 2, day = 0} : {syear++, year++};
    else
      dateType == 0
          ? {sday--, day--}
          : dateType == 1 ? {smonth--, day = 0} : {syear--, year--};
    resData['eday'] = DateTime(year, month, day).toString();
    resData['sday'] = DateTime(syear, smonth, sday).toString();
    request();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return ScopedModelDescendant<TopModel>(
    //   builder: (context, child, model) {
    return GMLoadingWidget().GMLoading(
      show: showLoading,
      color: Color.fromRGBO(1, 1, 1, 0.0),
      child: Scaffold(
        appBar: GMAppBar(
          title: widget.userName ?? '统计',
        ),
        body: ListView(
          children: [
            goalList.length != 0
                ? GmListView(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    // height: 1000,
                    title: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
                        child: Text("目标",
                            style: TextStyle(
                                color: Color.fromRGBO(77, 117, 156, 1),
                                fontSize: 17))),
                    childrens: goalList.map((goal) {
                      return GoalUI(goal, showName: false);
                    }).toList(),
                  )
                : Container(),
            Column(
              children: datas.keys.map((key) {
                if (datas[key] == null) return Container();
                return _main(context, detailModel.showName[key], datas[key]);
              }).toList(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: SafeArea(
            child: Container(
              height: 50,
              padding: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(width: 0.1, color: Colors.grey))),
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet<Null>(
                          context: context,
                          builder: (BuildContext context) {
                            return GmDateChoose(
                              startDateTime: DateTime.parse(resData['sday']),
                              endDateTime: DateTime.parse(resData['eday']),
                              dateType: dateType,
                              dateConfirmed: (start, end, type) {
                                if (start.compareTo(end) > 0) {
                                  GmToast.showToast('结束时间大于起始时间');
                                  return;
                                }
                                dateType = type;
                                resData['sday'] = start.toString();
                                resData['eday'] = end.toString();
                                request();
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(241, 245, 249, 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateShow(),
                                style: TextStyle(
                                  color: GlobalConstant.themeColor,
                                  fontSize: 13,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_up,
                                  color: GlobalConstant.themeColor, size: 15)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  isOneDay
                      ? Positioned(
                          left: 10,
                          child: GestureDetector(
                            onTap: () {
                              dayChange(false);
                            },
                            child: Icon(
                              Icons.arrow_left,
                              color: GlobalConstant.themeColor,
                            ),
                          ),
                        )
                      : Container(),
                  isOneDay
                      ? Positioned(
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              dayChange(true);
                            },
                            child: Icon(
                              Icons.arrow_right,
                              color: GlobalConstant.themeColor,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _main(
      BuildContext context, String name, Map<String, dynamic> childData) {
    int index = 0;
    return GmListView(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      title: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
          child: Text(name,
              style: TextStyle(
                  color: Color.fromRGBO(77, 117, 156, 1), fontSize: 17))),
      childrens: <Widget>[
        Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Wrap(
              children: childData.keys.map((key) {
            ++index;

            return _detail(context, detailModel.showName[key], childData[key],
                showLine: index % 3 != 0);
          }).toList()),
        ),
      ],
    );
  }

  Widget _detail(BuildContext context, String name, Map value,
      {showLine: true}) {
    //处理百分比
    double per = double.tryParse(value['percent'].toString()) * 100;
    String percent =
        per > 0 ? "+${per.toStringAsFixed(1)}" : per.toStringAsFixed(1);
    //处理值
    double v = double.tryParse(value['value'].toString());
    // double v = 2923234.23;
    String round = v.floor().toString();
    round = round.replaceAll(new RegExp(r"(?=(\B)(\d{3})+$)"), ",");
    String last = v.toStringAsFixed(3).split('.')[1];
    last = int.tryParse(last) == 0 ? '' : '.' + last;
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      padding: EdgeInsets.only(left: 12),
      height: 70,
      margin: EdgeInsets.fromLTRB(0, 8, 0, 5),
      decoration: BoxDecoration(
        border: showLine
            ? Border(right: BorderSide(width: 0.5, color: Colors.grey))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(106, 106, 106, 1),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                round,
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromRGBO(51, 51, 51, 1),
                ),
              ),
              Text(
                last,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(51, 51, 51, 1),
                ),
              ),
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  child: CustomPaint(
                    painter:
                        new TriangleCustomPainter(context, color: Colors.red),
                  ),
                ),
                Text(
                  '$percent%',
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///画个三角形组件
class TriangleCustomPainter extends CustomPainter {
  Paint _paint = new Paint(); //画笔富含各种属性方法。仔细查看源码
  final BuildContext context;

  final Color color;

  TriangleCustomPainter(this.context, {this.color});

  @override
  void paint(Canvas canvas, Size size) {
    List spots = new List(3);
    spots[0] = Coordinate(cx: 3, cy: -7);
    spots[1] = Coordinate(cx: 6, cy: 7);
    spots[2] = Coordinate(cx: 0, cy: 7);

    Path path = new Path()..moveTo(spots[0].cx, spots[0].cy);
    path.lineTo(spots[1].cx, spots[1].cy);
    path.lineTo(spots[2].cx, spots[2].cy);
    canvas.drawPath(
        path,
        _paint
          ..style = PaintingStyle.fill
          ..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Coordinate {
  final double cx;
  final double cy;
  Coordinate({this.cx, this.cy});
}
