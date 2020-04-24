/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-21 14:23:49
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-09-06 16:20:19
 * @Description: 日期级图表
 */
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:staff_performance/model/peformance_data_manager.dart';

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final String unit;
  final int type; //判断是柱状图（0）还是百分比图（1）
  static List<charts.TickSpec<String>> staticTicks;
  final Map requestMap;
  SimpleBarChart(this.seriesList,
      {this.animate, this.unit, this.type, this.requestMap});

  factory SimpleBarChart.withData(
      List<Map<String, List>> datas, int type, Map requestMap,
      {bool animate, String unit = '万'}) {
    return new SimpleBarChart(_createData(datas),
        animate: false, unit: unit, type: type, requestMap: requestMap);
  }

  String _formatter(num value) {
    String formater =
        value.abs() > 10000 ? '${value / 10000}$unit' : value.toString();
    return formater;
  }

  String _formatterPercent(num value) {
    return (value * 100).toString() + '%';
  }

  int getLength() {
    return requestMap['groupBy'] == 'day' ? 3 : 4;
  }

  double _setHeight() {
    double height = 220.0 + ((seriesList.length / getLength()).ceil() * 30);
    return height;
  }

  List<charts.TickSpec<num>> _primaryTick = [
    charts.TickSpec(0),
    charts.TickSpec(0.25),
    charts.TickSpec(0.50),
    charts.TickSpec(0.75),
    charts.TickSpec(1),
  ];
  @override
  Widget build(BuildContext context) {
    return type == 0 ? _barChar(context) : _percentChar(context);
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createData(
      List<Map<String, List>> datas) {
    staticTicks = [];
    List<charts.Series<OrdinalSales, String>> result = new List();
    Function getColor = PeformanceDataHandle.getColor();
    datas.forEach((element) {
      int index = 0; //用于定义纵坐标，让名字重复的纵坐标分开
      String title = element.keys.first;

      int length = element[title].length;
      int width = 1; //度量尺
      int all = 20; //最多显示的个数
      if (length > all && length <= 2 * all)
        width = 2;
      else if (length > 2 * all && length < 3 * all)
        width = 3;
      else if (length >= 3 * all && length <= 4 * all) width = 4;
      // int width = 1;
      // if (length > 6) width = length ~/ 7;
      //筛选出为0的数据
      num update = 0;
      var data = element[title].map((item) {
        index++;
        if (datas.first == element) {
          if (index == 0 || index % width == 0) {
            //防止数据太长 超出屏幕宽度
            String domian = item['domain'];

            if (domian.length > 4) {
              domian = domian.substring(0, 2) +
                  '..' +
                  domian.substring(domian.length - 2);
            }
            staticTicks
                .add(new charts.TickSpec(index.toString(), label: domian));
          }
        }
        num measure = num.tryParse(item['measure']);
        //筛选为0的数据
        if (measure != 0) {
          update = measure;
        }
        return OrdinalSales(index.toString(), measure);
      }).toList();
      if (update != 0) {
        var color = getColor();
        result.add(charts.Series<OrdinalSales, String>(
          id: title,
          domainFn: (OrdinalSales sales, _) => sales.domainValue,
          measureFn: (OrdinalSales sales, _) => sales.measureValue,
          data: data,
          colorFn: (OrdinalSales sales, _) => charts.Color.fromHex(code: color),
          fillColorFn: (OrdinalSales sales, _) =>
              charts.Color.fromHex(code: color), //'#0000EE'
        ));
      }
    });
    //当数据为空时也展示框架
    if (result.length == 0) {
      result.add(charts.Series<OrdinalSales, String>(
        id: '',
        domainFn: (OrdinalSales sales, _) => sales.domainValue,
        measureFn: (OrdinalSales sales, _) => sales.measureValue,
        data: [OrdinalSales('', 0)],
      ));
    }
    return result;
  }

//柱状图
  Widget _barChar(BuildContext context) {
    final simpleCurrencyFormatter =
        new charts.BasicNumericTickFormatterSpec(_formatter);
    final ticks = new charts.StaticOrdinalTickProviderSpec(staticTicks);
    return Center(
        key: Key(staticTicks.length > 0
            ? staticTicks[0].label.toString() + '4'
            : '4'),
        child: new Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5),
          height: _setHeight(),
          child: charts.BarChart(
            seriesList,
            animate: animate,
            defaultRenderer: new charts.BarRendererConfig(minBarLengthPx: 2),
            barGroupingType: charts.BarGroupingType.stacked,
            primaryMeasureAxis: new charts.NumericAxisSpec(
                tickFormatterSpec: simpleCurrencyFormatter,
                showAxisLine: true,
                renderSpec: charts.GridlineRendererSpec(
                    minimumPaddingBetweenLabelsPx: 5,
                    axisLineStyle: charts.LineStyleSpec(),
                    lineStyle: charts.LineStyleSpec(dashPattern: [4, 4]))),
            domainAxis: new charts.OrdinalAxisSpec(
                showAxisLine: true,
                tickProviderSpec: ticks,
                renderSpec: charts.SmallTickRendererSpec(
                  labelStyle: charts.TextStyleSpec(fontSize: 9),
                  labelRotation: -60,
                  tickLengthPx: 5,
                  labelAnchor: charts.TickLabelAnchor.before,
                  labelOffsetFromAxisPx: 0,
                  labelOffsetFromTickPx: -15,
                )),
            behaviors: staticTicks.length > 0
                ? [
                    new charts.SeriesLegend(
                      position: charts.BehaviorPosition.bottom,
                      entryTextStyle: charts.TextStyleSpec(
                          fontSize: 8, color: charts.Color.black),
                      desiredMaxColumns: getLength(),
                      // horizontalFirst: false,
                      cellPadding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                      outsideJustification:
                          charts.OutsideJustification.middleDrawArea,
                    )
                  ]
                : [],
          ),
        ));
  }

  //百分图
  Widget _percentChar(BuildContext context) {
    final simpleCurrencyFormatter =
        new charts.BasicNumericTickFormatterSpec(_formatterPercent);
    final ticks = new charts.StaticOrdinalTickProviderSpec(staticTicks);
    final primaryTicks = new charts.StaticNumericTickProviderSpec(_primaryTick);
    return Center(
        key: Key(staticTicks.length > 0
            ? staticTicks[0].label.toString() + '5'
            : '5'),
        child: new Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5),
          height: _setHeight(),
          child: charts.BarChart(
            seriesList,
            animate: animate,
            barGroupingType: charts.BarGroupingType.stacked,
            primaryMeasureAxis: new charts.NumericAxisSpec(
                showAxisLine: true,
                tickFormatterSpec: simpleCurrencyFormatter,
                tickProviderSpec: primaryTicks),
            domainAxis: new charts.OrdinalAxisSpec(
                showAxisLine: true,
                tickProviderSpec: ticks,
                renderSpec: charts.SmallTickRendererSpec(
                  labelStyle: charts.TextStyleSpec(fontSize: 9),
                  labelRotation: -60,
                  tickLengthPx: 5,
                  labelAnchor: charts.TickLabelAnchor.before,
                  labelOffsetFromAxisPx: 0,
                  labelOffsetFromTickPx: -15,
                )),
            behaviors: staticTicks.length > 0
                ? [
                    new charts.PercentInjector(
                        totalType: charts.PercentInjectorTotalType.domain),
                    new charts.SeriesLegend(
                      position: charts.BehaviorPosition.bottom,
                      entryTextStyle: charts.TextStyleSpec(
                          fontSize: 8, color: charts.Color.black),
                      desiredMaxColumns: getLength(),
                      cellPadding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                      // horizontalFirst: false,
                      outsideJustification:
                          charts.OutsideJustification.middleDrawArea,
                    )
                  ]
                : [],
          ),
        ));
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String domainValue;
  final num measureValue;

  OrdinalSales(this.domainValue, this.measureValue);
}
