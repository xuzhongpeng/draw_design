// ///此文件作废
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/painting.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:gm_uikit/gm_uikit.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:flutter/material.dart';
// import 'package:staff_performance/model/entities/performance_entity.dart';
// import 'package:staff_performance/model/entities/sell_group_entity.dart';
// import 'package:staff_performance/model/peformance_data_manager.dart';
// import 'package:staff_performance/model/top_model.dart';
// import 'package:staff_performance/views/custom_barchart.dart';
// import 'package:staff_performance/views/custom_barpercent.dart';
// import 'package:staff_performance/views/custom_linechart.dart';
// import 'package:staff_performance/views/shop_component.dart';
// // import 'package:staff_performance/views/gm_table.dart';
// import 'package:staff_performance/pages/data_detail.dart';

// const String sql =
//     'id INTEGER PRIMARY KEY, ownerable_id TEXT, ownerable_type TEXT, owner_name TEXT, sellitem_id INTEGER, sellitem_code TEXT, sellitem_name TEXT, sellitemgroup_id TEXT, sellitemgroup_code TEXT, sellitemgroup_name TEXT, value TEXT, transaction_date TEXT, transaction_year TEXT, transaction_month TEXT, transaction_day TEXT, transaction_week TEXT, transaction_time INTEGER';

// class StaffPerformance extends StatefulWidget {
//   @override
//   _StaffPerformance createState() => _StaffPerformance();
// }

// class _StaffPerformance extends State<StaffPerformance>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   //数据处理类
//   PeformanceDataHandle _dataHandle;
//   ScrollController _controller;
//   // ScrollController _singleController;
//   TabController _tabController;
//   AnimationController _animationController;
//   CurvedAnimation _curved;

//   //图标是明细还是汇总
//   int _selectIndex = 0;

// //动画是否前进执行
//   bool _forward = true;

// //默认展示时间还是店铺
//   PresentState _option = PresentState.PresentStateOwer;

//   TopModel get _model => TopModel.of(context);

// //请求接口所需要的参数
//   final requestMap = <String, dynamic>{};

// //当前界面展示的数据选项
//   final presentParamMap = <String, dynamic>{};
//   //缓存查询出来的所有有效数据（由它解析成其它数据）
//   List<Map<String, List<PerformanceEntity>>> performances;
// // 分类名称集合
//   var _sellGroups = <String>[];
// //
//   SellGroupEntity _selectEntity = SellGroupEntity();

//   //数据明细
//   var _detailDatas = <Map<String, dynamic>>[];

//   //数据明细
//   var _chartData = <Map<String, List>>[];

//   //数据汇总
//   var _summaryData = <Map<String, dynamic>>[];
//   //绝对值百分比
//   var _selectPercentage = 0;
//   //数据明细展示的数据
//   var _dataDetail;
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _dataHandle = PeformanceDataHandle(tableName: 'staff', sql: sql);
//     _controller = ScrollController();
//     _animationController =
//         AnimationController(duration: Duration(milliseconds: 250), vsync: this)
//           ..addListener(() {
//             if (_animationController.status == AnimationStatus.completed ||
//                 _animationController.status == AnimationStatus.dismissed) {
//               _option = _option == PresentState.PresentStateDate
//                   ? PresentState.PresentStateOwer
//                   : PresentState.PresentStateDate;
//               assembleData();
//               // setState(() {});
//             }
//           });
//     _curved =
//         CurvedAnimation(parent: _animationController, curve: Curves.linear);

//     List<String> date = PeformanceDataHandle.getCurrentTimeSpan();
//     requestMap.addAll({
//       'type': 'staff',
//       'groupBy': 'month',
//       'sday': '2019-02-01', //'${date.first}',
//       'eday': '2019-02-05', //'${date.last}',
//       'date_type': 'custom',
//     });

//     _model.requestPeformanceData(requestMap).then((entitys) async {
//       await _dataHandle.bathInsert(entitys);
//       _sellGroups = _model.sellGroupEntitys.map((entity) {
//         return entity.name;
//       }).toList();
//       _selectEntity = _model.sellGroupEntitys?.first;
//       _selectEntity.currentItem = _selectEntity.sellItems?.first;
//       quetyDataFromDataBase();
//       setState(() {
//         initialTabController(0, _selectEntity.sellItems.length);
//       });
//     });
//     initialTabController(0, 0);
//   }

//   void initialTabController(int initialIndex, int length) {
//     _tabController = TabController(
//         initialIndex: initialIndex,
//         length: _selectEntity != null ? _selectEntity.sellItems.length : 0,
//         vsync: this);
//   }

//   void quetyDataFromDataBase() async {
//     performances = await _dataHandle.queryPerforDatas(_option,
//         sellItemgroupId: '${_selectEntity.id}',
//         sellItemId: _selectEntity.currentItem.id,
//         requestMap: requestMap);
//     //获取汇总数据
//     _summaryData = await _dataHandle.queryWithDate(
//         sellItemgroupId: '${_selectEntity.id}',
//         sellItemId: _selectEntity.currentItem.id,
//         requestMap: requestMap);
//     assembleData();
//   }

//   //组装展示的数据
//   void assembleData() async {
//     //组装明细的 表格数据
//     //传requestMap是需要根据时间确定店铺
//     // var detailData =
//     //     await _dataHandle.detailDatas(_option, performances, requestMap);
//     _detailDatas = _selectIndex == 1
//         ? await _dataHandle.assembleTotal(performances, requestMap)
//         : await _dataHandle.detailDatas(_option, performances, requestMap,
//             type: _selectPercentage);

//     _chartData =
//         _dataHandle.chartData(_option, requestMap['groupBy'], performances);
//     // _chartData =
//     //     _dataHandle.chartData(_option, requestMap['groupBy'], performances);
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     //  _controller.dispose();
//   }

//   void doValue() {
//     // _singleController.attach(_controller.position);
//     //  print(_controller.offset.toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return ScopedModelDescendant<TopModel>(
//       builder: (context, child, model) {
//         return CustomScrollView(
//           controller: _controller,
//           slivers: <Widget>[
//             SliverToBoxAdapter(child: buildTop()),
//             SliverToBoxAdapter(child: buildSort()),
//             SliverToBoxAdapter(child: buildChartSection()),
//             SliverToBoxAdapter(child: buildPresentDataList(_detailDatas)),
//             // SliverToBoxAdapter(child: TableTest.test()),
//           ],
//         );
//       },
//     );
//   }

//   Widget buildTop() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 15),
//       decoration: BoxDecoration(
//           color: Colors.white, border: GMCommonWidget.bottomBorderSide()),
//       height: 60,
//       child: Row(
//         children: _topChildren(_option),
//       ),
//     );
//   }

//   List<Widget> _topChildren(PresentState option) {
//     final children = <Widget>[];
//     option == PresentState.PresentStateDate
//         ? children.add(buildTopDateWidget())
//         : children.add(buildTopShopWidget());
//     children.add(buildTopSwithButton());
//     option == PresentState.PresentStateDate
//         ? children.add(buildTopShopWidget())
//         : children.add(buildTopDateWidget());
//     return children;
//   }

//   Widget buildTopDateWidget() {
//     String begin = PeformanceDataHandle.translationDateFormatter(
//         requestMap['sday'],
//         formatKey: requestMap['groupBy']);
//     String end = PeformanceDataHandle.translationDateFormatter(
//         requestMap['eday'],
//         formatKey: requestMap['groupBy']);
//     String time = '$begin~$end';
//     if (begin == end) {
//       time = end;
//     }
//     return Expanded(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           ShopComponent.buildRichText(
//               title: '日期',
//               subTitle: time,
//               autoSize: true,
//               callBack: () {
//                 showModalBottomSheet<Null>(
//                     context: context,
//                     backgroundColor: Colors.transparent,
//                     isScrollControlled: true, //requestMap['sday']
//                     // shape: RoundedRectangleBorder (borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
//                     builder: (BuildContext context) {
//                       return GmDateChoose(
//                           startDateTime: DateTime.parse(requestMap['sday']),
//                           endDateTime: DateTime.parse(requestMap['eday']),
//                           dateType: requestMap['groupBy'] == 'day'
//                               ? 0
//                               : requestMap['groupBy'] == 'month' ? 1 : 2,
//                           dateConfirmed: (start, end, type) {
//                             if (start.compareTo(end) > 0) {
//                               Fluttertoast.showToast(msg: '结束时间大于起始时间');
//                               return;
//                             }

//                             // setState(() {
//                             requestMap['sday'] =
//                                 PeformanceDataHandle.dateToString(start);
//                             requestMap['eday'] =
//                                 PeformanceDataHandle.dateToString(end);
//                             requestMap['groupBy'] = (type == 0
//                                 ? 'day'
//                                 : (type == 1 ? 'month' : 'year'));
//                             // });
//                             quetyDataFromDataBase();
//                           });
//                     });
//               }),
//           Image.asset(
//             'lib/assets/performance/hint_tap_triangle.png',
//             width: 7,
//             height: 7,
//           )
//         ],
//       ),
//     );
//   }

//   Widget buildTopShopWidget() {
//     return Expanded(
//       child: ShopComponent.buildRichText(
//           title: '店铺', subTitle: '所有店铺', autoSize: false, callBack: () {}),
//     );
//   }

//   Widget buildTopSwithButton() {
//     return Stack(
//       alignment: Alignment.center,
//       children: <Widget>[
//         Container(height: 60, color: Colors.black54, width: 0.1),
//         _selectIndex == 0
//             ? RotationTransition(
//                 turns: Tween(begin: 0.0, end: 0.5).animate(_curved),
//                 child: GMCommonWidget.customButton(
//                     image: Image.asset(
//                         'lib/assets/performance/analysis_switch.png'),
//                     callBack: () {
//                       if (_forward) {
//                         _animationController.forward();
//                       } else {
//                         _animationController.reverse();
//                       }
//                       _forward = !_forward;
//                     }),
//               )
//             : Container()
//       ],
//     );
//   }

//   Widget buildSort() {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//           color: Colors.white, border: GMCommonWidget.bottomBorderSide()),
//       child: Row(
//         children: <Widget>[
//           GestureDetector(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                   border: Border(
//                 right: BorderSide(color: Colors.black45, width: 0.2),
//               )),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   GMCommonWidget.normalText(_selectEntity.name ?? '-----',
//                       textstyle: TextStyle(
//                           color: ShopComponent.normalColor,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500)),
//                   Image.asset(
//                     'lib/assets/performance/hint_tap_triangle.png',
//                     width: 7,
//                     height: 7,
//                   )
//                 ],
//               ),
//             ),
//             onTap: () {
//               GMAlertDilog.showSheetPopup(_sellGroups, context,
//                   callback: (item) {
//                 setState(() {
//                   _selectEntity = _model.sellGroupEntitys.where((entity) {
//                     return item == entity.name;
//                   })?.first;
//                   _selectEntity.currentItem =
//                       _selectEntity.sellItems.length == 0
//                           ? null
//                           : _selectEntity.sellItems.first;
//                   initialTabController(0, _selectEntity.sellItems.length);
//                 });
//                 quetyDataFromDataBase();
//                 if (!Platform.isIOS) {
//                   Navigator.of(context).pop();
//                 }
//                 //
//               });
//             },
//           ),
//           Expanded(
//             child: buildSortChildren(_selectEntity.sellItems.map((item) {
//               return item.name;
//             }).toList()),
//           )
//         ],
//       ),
//     );
//   }

//   Widget buildSortChildren(List<String> items) {
//     return TabBar(
//       indicatorSize: TabBarIndicatorSize.label,
//       labelColor: Theme.of(context).primaryColor,
//       unselectedLabelColor: Colors.grey,
//       labelStyle: ShopComponent.themeTextStyle(context),
//       unselectedLabelStyle: ShopComponent.greyTextStyle(),
//       indicatorColor: Theme.of(context).primaryColor,
//       isScrollable: true,
//       controller: _tabController,
//       tabs: items.map((item) {
//         return Tab(
//           text: item,
//         );
//       }).toList(),
//       onTap: (index) {
//         _tabController.animateTo(index);
//         refreshSelect(index);
//         quetyDataFromDataBase();
//       },
//     );
//   }

//   void refreshSelect(int index) {
//     setState(() {
//       _selectEntity.currentItem = _selectEntity.sellItems[index];
//     });
//   }

//   Widget buildChartSection() {
//     return Container(
//       decoration: BoxDecoration(color: Colors.white),
//       padding: EdgeInsets.symmetric(horizontal: 10),
//       child: Column(
//         children: <Widget>[
//           buildSegmentButton(['明细', '汇总'],
//               selectIndex: _selectIndex, width: 100, callBack: (index) {
//             _selectIndex = index;
//             assembleData();
//           }),
//           buildBarChart(_selectIndex),
//         ],
//       ),
//     );
//   }

//   Widget buildSegmentButton(
//     List<String> items, {
//     int selectIndex,
//     double width,
//     SegmentCallback callBack,
//   }) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 20),
//       child: Center(
//         child: ShopComponent.buildCupertinoSegmentedControl(
//             context: context,
//             items: items,
//             callBack: callBack,
//             selectIndex: selectIndex,
//             width: width),
//       ),
//     );
//   }

//   Widget buildBarChart(int index) {
//     print(_option == PresentState.PresentStateOwer);
//     return index == 0
//         ? (_option == PresentState.PresentStateOwer
//             ? PercentBarChart.withData(
//                 _chartData, requestMap['groupBy'], _selectPercentage)
//             : SimpleBarChart.withData(_chartData, _selectPercentage))
//         : CustomLineChart.withData(
//             _summaryData, requestMap, _selectEntity.name);
//   }

//   Widget buildPresentDataList(List<Map<String, dynamic>> items) {
//     String begin = PeformanceDataHandle.translationDateFormatter(
//         requestMap['sday'],
//         formatKey: requestMap['groupBy']);
//     String end = PeformanceDataHandle.translationDateFormatter(
//         requestMap['eday'],
//         formatKey: requestMap['groupBy']);
//     return GmListView(
//       title: GMListViewItem(
//         height: 42,
//         padding: EdgeInsets.only(left: 10),
//         leading: Text('数据明细',
//             style: TextStyle(
//                 color: ShopComponent.normalColor,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w500)),
//         trailing: _selectIndex == 0
//             ? ShopComponent.buildCupertinoSegmentedControl(
//                 context: context,
//                 size: 10,
//                 items: ['绝对值', '百分比'],
//                 selectIndex: _selectPercentage,
//                 callBack: (index) {
//                   _selectPercentage = index;
//                   assembleData();
//                 })
//             : Container(),
//       ),
//       childrens: [
//         ShopComponent.buildDetailList(context, items, callback: (value) {
//           print(value);
//           String headerName =
//               _option == PresentState.PresentStateDate ? '店铺' : '日期';
//           String valueType = _selectEntity.name;
//           DataMessage message = new DataMessage(headerName, valueType);
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => DataDetail(value, message)));
//         })
//       ],
//       bottom: GmListView(
//         backgroundColor: Colors.white,
//         padding: EdgeInsets.all(10),
//         title: Text('数据说明',
//             style: TextStyle(
//                 color: ShopComponent.normalColor,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w500)),
//         childrens: [
//           '1. 统计区间: $begin 到 $end',
//           '2. ${_selectEntity.currentItem?.name ?? ''} : ${_selectEntity.currentItem?.remark ?? ''}'
//         ].map((title) {
//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             child: Text(title, style: ShopComponent.greyTextStyle(size: 13)),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
