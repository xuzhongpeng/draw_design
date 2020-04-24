import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:gm_uikit/gm_uikit.dart';
// import 'package:scoped_model/scoped_model.dart';

import 'package:staff_performance/model/peformance_data_manager.dart';
// import 'package:staff_performance/model/top_model.dart';
// import 'package:staff_performance/model/dataSource_model.dart';
import 'package:staff_performance/utils/center_util.dart';
import 'package:staff_performance/views/custom_barchart.dart';
import 'package:staff_performance/views/custom_barpercent.dart';
import 'package:staff_performance/views/custom_linechart.dart';
import 'package:staff_performance/views/shop_component.dart';
import 'package:staff_performance/pages/data_detail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:staff_performance/stores/index.dart';

const String sql =
    'id INTEGER PRIMARY KEY, ownerable_id TEXT, ownerable_type TEXT, owner_name TEXT, sellitem_id INTEGER, sellitem_code TEXT, sellitem_name TEXT, sellitemgroup_id TEXT, sellitemgroup_code TEXT, sellitemgroup_name TEXT, value TEXT, transaction_date TEXT, transaction_year TEXT, transaction_month TEXT, transaction_day TEXT, transaction_week TEXT, transaction_time INTEGER';

// typedef
class TableType {
  ///表名 shop or staff
  final String table;

  ///属性名成 店铺 or 员工
  final String tableName;
  TableType(this.table, this.tableName);
}

class ShopPerformance extends StatefulWidget {
  ///店铺还是员工
  final TableType type;
  ShopPerformance(this.model, {this.type});
  final model;
  factory ShopPerformance.withData(model, {TableType type}) {
    return ShopPerformance(model, type: type);
  }
  @override
  _ShopPerformanceState createState() => _ShopPerformanceState();
}

class _ShopPerformanceState extends State<ShopPerformance>
    with TickerProviderStateMixin {
  DataModel _model;

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = widget.model;

    _model.initState(widget.type.table, sql, this);
  }

  @override
  void dispose() {
    super.dispose();
    //  _controller.dispose();
  }

  void doValue() {
    SpinKitThreeBounce(
      size: 40,
      itemBuilder: (_, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0
                ? Colors.red
                : index == 1 ? Colors.yellow : Colors.blue,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return ScopedModelDescendant<ShopDataModel>(
    //   builder: (context, child, shopModel) {
    //     return ScopedModelDescendant<StaffDataModel>(
    //       builder: (context, child, staffModel) {
    return Store.connect<ShopDataModel>(builder: (context, snapshot, child) {
      return Store.connect<StaffDataModel>(builder: (context, snapshot, child) {
        return GMLoadingWidget().GMLoading(
          show: _model.showLoading,
          color: Color.fromRGBO(1, 1, 1, 0.0),
          child: CustomScrollView(
            controller: _model.controller,
            slivers: <Widget>[
              SliverToBoxAdapter(child: buildTop()),
              SliverToBoxAdapter(child: buildSort()),
              SliverToBoxAdapter(child: buildChartSection()),
              SliverToBoxAdapter(child: buildPresentDataList()),
            ],
          ),
        );
      });
    });
    //       },
    //     );
    //   },
    // );
  }

  Widget buildTop() {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white, border: GMCommonWidget.bottomBorderSide()),
      height: 60,
      child: Row(
        children: _topChildren(_model.option),
      ),
    );
  }

  List<Widget> _topChildren(PresentState option) {
    final children = <Widget>[];
    option == PresentState.PresentStateDate
        ? children.add(buildTopDateWidget())
        : children.add(buildTopShopWidget());
    children.add(buildTopSwithButton());
    option == PresentState.PresentStateDate
        ? children.add(buildTopShopWidget())
        : children.add(buildTopDateWidget());
    return children;
  }

  Widget buildTopDateWidget() {
    String begin = PeformanceDataHandle.translationDateFormatter(
        _model.requestMap['sday'],
        formatKey: _model.requestMap['groupBy']);
    String end = PeformanceDataHandle.translationDateFormatter(
        _model.requestMap['eday'],
        formatKey: _model.requestMap['groupBy']);
    String time = '$begin~$end';
    if (begin == end) {
      time = end;
    }
    return Expanded(
      child: LayoutBuilder(
          builder: (BuildContext excontext, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            Container(
              height: 60,
              alignment: Alignment.center,
              child: ShopComponent.buildRichText(
                  title: '日期',
                  subTitle: time,
                  autoSize: true,
                  callBack: () {
                    showModalBottomSheet<Null>(
                        context: context,
                        builder: (BuildContext context) {
                          return GmDateChoose(
                              startDateTime:
                                  DateTime.parse(_model.requestMap['sday']),
                              endDateTime:
                                  DateTime.parse(_model.requestMap['eday']),
                              dateType: _model.requestMap['groupBy'] == 'day'
                                  ? 0
                                  : _model.requestMap['groupBy'] == 'month'
                                      ? 1
                                      : 2,
                              dateConfirmed: (start, end, type) {
                                if (start.compareTo(end) > 0) {
                                  GmToast.showToast('结束时间大于起始时间');
                                  return;
                                }
                                //判断是否为60个单位
                                Duration startDura = end.difference(start);
                                if (type == 0 && startDura.inDays > 60) {
                                  GmToast.showToast('时间范围最多可选60项');
                                  return;
                                } else if (type == 1 &&
                                    startDura.inDays / 30 > 60) {
                                  GmToast.showToast('时间范围最多可选60项');
                                  return;
                                } else if (type == 2 &&
                                    startDura.inDays / 30 / 12 > 60) {
                                  GmToast.showToast('时间范围最多可选60项');
                                  return;
                                }
                                _model.requestMap['sday'] =
                                    PeformanceDataHandle.dateToString(start);
                                _model.requestMap['eday'] =
                                    PeformanceDataHandle.dateToString(end);
                                _model.requestMap['groupBy'] = (type == 0
                                    ? 'day'
                                    : (type == 1 ? 'month' : 'year'));
                                _model.initAllData(this);
                              });
                        });
                  }),
            ),
            Positioned(
              bottom: 5,
              width: constraints.maxWidth,
              child: Image.asset(
                'lib/assets/performance/hint_tap_triangle.png',
                width: 4,
                height: 4,
                package: CenterUtils.getImagePackage(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildTopShopWidget() {
    return Expanded(
      child: ShopComponent.buildRichText(
          title: widget.type.tableName,
          subTitle: '所有${widget.type.tableName}',
          autoSize: false,
          callBack: () {}),
    );
  }

  Widget buildTopSwithButton() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(height: 60, color: Colors.black54, width: 0.1),
        _model.selectIndex == 0
            ? RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_model.curved),
                child: GMCommonWidget.customButton(
                    image: Image.asset(
                        'lib/assets/performance/analysis_switch.png',
                        package: CenterUtils.getImagePackage()),
                    callBack: () {
                      _model.animatChange();
                    }),
              )
            : Container()
      ],
    );
  }

  Widget buildSort() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white, border: GMCommonWidget.bottomBorderSide()),
      child: Row(
        children: <Widget>[
          GestureDetector(
            child: Stack(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        border: Border(
                      right: BorderSide(color: Colors.black45, width: 0.2),
                    )),
                    height: 50,
                    child: GMCommonWidget.normalText(
                        _model.selectEntity.name ?? ' ------- ',
                        textstyle: TextStyle(
                            color: ShopComponent.normalColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400))),
                Positioned(
                  bottom: 5,
                  width: 70,
                  // top: 40,
                  child: Image.asset(
                    'lib/assets/performance/hint_tap_triangle.png',
                    width: 4,
                    height: 4,
                    package: CenterUtils.getImagePackage(),
                  ),
                ),
              ],
            ),
            onTap: () {
              GMAlertDilog.showSheetPopup(_model.sellGroups, context,
                  callback: (item) {
                setState(() {
                  _model.selectEntity = _model.sellGroupEntitys.where((entity) {
                    return item == entity.name;
                  })?.first;
                  _model.selectEntity.currentItem =
                      _model.selectEntity.sellItems.length == 0
                          ? null
                          : _model.selectEntity.sellItems.first;
                  _model.initialTabController(
                      0, _model.selectEntity.sellItems.length);
                });
                _model.quetyDataFromDataBase();
                // if (!Platform.isIOS) {
                //   Navigator.of(context).pop();
                // }
              });
            },
          ),
          Expanded(
            child: buildSortChildren(_model.selectEntity.sellItems.map((item) {
              return item.name;
            }).toList()),
          )
        ],
      ),
    );
  }

  Widget buildSortChildren(List<dynamic> items) {
    return TabBar(
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      labelStyle:
          ShopComponent.themeTextStyle(context, fontWeight: FontWeight.w500),
      unselectedLabelStyle:
          ShopComponent.greyTextStyle(fontWeight: FontWeight.w500),
      indicatorColor: Theme.of(context).primaryColor,
      isScrollable: true,
      controller: _model.tabController,
      tabs: items.map((item) {
        return Container(
            height: 52,
            child: Tab(
              text: item,
            ));
      }).toList(),
      onTap: (index) {
        _model.tabController.animateTo(index);
        refreshSelect(index);
        _model.quetyDataFromDataBase();
      },
    );
  }

  void refreshSelect(int index) {
    setState(() {
      _model.selectEntity.currentItem = _model.selectEntity.sellItems[index];
    });
  }

  Widget buildChartSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          buildSegmentButton(['明细', '汇总'],
              selectIndex: _model.selectIndex, width: 100, callBack: (index) {
            _model.selectIndex = index;
            _model.assembleData();
          }),
          buildBarChart(_model.selectIndex),
        ],
      ),
    );
  }

  Widget buildSegmentButton(
    List<String> items, {
    int selectIndex,
    double width,
    SegmentCallback callBack,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ShopComponent.buildCupertinoSegmentedControl(
            context: context,
            items: items,
            callBack: callBack,
            selectIndex: selectIndex,
            width: width),
      ),
    );
  }

  Widget buildBarChart(int index) {
    return index == 0
        ? (_model.option == PresentState.PresentStateOwer
            ? PercentBarChart.withData(_model.chartData,
                _model.requestMap['groupBy'], _model.selectPercentage)
            : SimpleBarChart.withData(
                _model.chartData, _model.selectPercentage, _model.requestMap))
        : CustomLineChart.withData(
            _model.summaryData, _model.requestMap, _model.selectEntity.name);
  }

  Widget buildPresentDataList() {
    String begin = PeformanceDataHandle.translationDateFormatter(
        _model.requestMap['sday'],
        formatKey: _model.requestMap['groupBy']);
    String end = PeformanceDataHandle.translationDateFormatter(
        _model.requestMap['eday'],
        formatKey: _model.requestMap['groupBy']);
    return GmListView(
      title: GMListViewItem(
        height: 42,
        padding: EdgeInsets.only(left: 10),
        leading: Text('数据明细',
            style: TextStyle(
                color: ShopComponent.normalColor,
                fontSize: 17,
                fontWeight: FontWeight.w500)),
        trailing: _model.selectIndex == 0
            ? ShopComponent.buildCupertinoSegmentedControl(
                context: context,
                size: 13,
                items: ['绝对值', '百分比'],
                selectIndex: _model.selectPercentage,
                callBack: (index) {
                  _model.selectPercentage = index;
                  _model.assembleData();
                })
            : Container(),
      ),
      childrens: [
        ShopComponent.buildDetailList(context, _model.detailDatas,
            callback: (value) {
          if (_model.selectIndex == 0) {
            String headerName = _model.option == PresentState.PresentStateDate
                ? widget.type.tableName
                : '日期';
            String valueType = _model.selectEntity.name;
            DataMessage message = new DataMessage(headerName, valueType);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DataDetail(
                      value,
                      message,
                      ownerableName: widget.type.table,
                      color: _model.selectPercentage == 0,
                    ),
              ),
            );
          }
        })
      ],
      bottom: GmListView(
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(10),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('数据说明',
              style: TextStyle(
                  color: ShopComponent.normalColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500)),
        ),
        childrens: [
          '1. 统计区间: $begin 到 $end',
          '2. ${_model.selectEntity.currentItem?.name ?? ''} : ${_model.selectEntity.currentItem?.remark ?? ''}',
          '3. 数据更新频率：每隔1小时更新（整点）'
        ].map((title) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(title, style: ShopComponent.greyTextStyle(size: 13)),
          );
        }).toList(),
      ),
    );
  }
}
