/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-21 14:23:49
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-09-06 16:05:55
 * @Description: 店铺级图表
 */
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:staff_performance/model/peformance_data_manager.dart';

List<charts.TickSpec<num>> _primaryTick = [
  charts.TickSpec(0),
  charts.TickSpec(0.25),
  charts.TickSpec(0.50),
  charts.TickSpec(0.75),
  charts.TickSpec(1),
];

class PercentBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;

  final bool animate;
  final String unit;
  final int type; //判断是柱状图（0）还是百分比图（1）
  static int isTimeChart = 0; //判断是时间为坐标的图（0）还是字符串为纵坐标的图（1）
  static List<charts.TickSpec<DateTime>> staticTicks;
  static int offset = 0;
  PercentBarChart(this.seriesList, {this.animate, this.unit, this.type});

  factory PercentBarChart.withData(
      List<Map<String, List>> datas, String type, int _selectPercentage,
      {bool animate, String unit = '万'}) {
    return new PercentBarChart(_createData(datas, type),
        animate: false, unit: unit, type: _selectPercentage);
  }

  String _formatter(num value) {
    String formater =
        value.abs() > 10000 ? '${value / 10000}$unit' : value.toString();
    return formater;
  }

  String _formatterPercent(num value) {
    return (value * 100).toString() + '%';
  }

  double _setHeight() {
    double height = 220.0 + ((seriesList.length / 4).ceil() * 30);
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return type == 0 ? commonChart(context) : percentChart(context);
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, DateTime>> _createData(
      List<Map<String, List>> datas, String type) {
    staticTicks = [];
    if (type == 'day') {
      offset = -20;
    } else if (type == 'month') {
      offset = -10;
    } else {
      offset = -20;
    }
    // datas = datas.length > 30 ? datas.sublist(25, 26) : datas;
    List<charts.Series<OrdinalSales, DateTime>> result = new List();
    Function getColor = PeformanceDataHandle.getColor();
    datas.forEach((element) {
      String title = element.keys.first;
      int length = element[title].length;
      //计算纵坐标有多少个 太多就隐藏
      int width = 1; //度量尺
      int all = 20; //最多显示的个数
      if (length > all && length <= 2 * all)
        width = 2;
      else if (length > 2 * all && length < 3 * all)
        width = 3;
      else if (length >= 3 * all && length <= 4 * all) width = 4;
      List<OrdinalSales> data = element[title].map((item) {
        int index = element[title].indexOf(item);
        // try {
        String time = item['domain'];
        int year = int.tryParse(time.substring(0, 4));

        int month = type != 'year'
            ? int.tryParse(time.length > 5 ? time.substring(5, 7) : '1')
            : 0;

        int day = type == 'day'
            ? int.tryParse(time.length > 8 ? time.substring(8, 10) : '1')
            : 0;

        DateTime date = type == 'year'
            ? new DateTime(year)
            : (type == 'month'
                ? new DateTime(year, month)
                : new DateTime(year, month, day));
        String unit = type == 'year'
            ? '$year年'
            : (type == 'month' ? '$month月' : '$month月$day日');
        if (datas.first == element) {
          if (index == 0 || index % width == 0) {
            staticTicks.add(new charts.TickSpec(date, label: '$unit'));
          }
        }

        return OrdinalSales(date, num.tryParse(item['measure'] ?? '0'));
      }).toList();
      //防止数据太长 超出屏幕宽度
      if (title.length > 6) {
        title =
            title.substring(0, 3) + '...' + title.substring(title.length - 3);
      }
      num update = 0;
      for (OrdinalSales item in data) {
        if (item.measureValue != 0) {
          update = item.measureValue;
        }
      }
      if (update != 0) {
        var color = getColor();
        result.add(charts.Series(
          id: title,
          domainFn: (OrdinalSales sales, _) => sales.domainValue,
          measureFn: (OrdinalSales sales, _) {
            return sales?.measureValue ?? 0;
          },
          data: data,
          colorFn: (OrdinalSales sales, _) => charts.Color.fromHex(code: color),
          fillColorFn: (OrdinalSales sales, _) =>
              charts.Color.fromHex(code: color), //'#0000EE'
        ));
      }
    });
    return datas.length > 0 && datas.first.values.first.length > 0
        ? result
        : [
            charts.Series(
              id: '',
              domainFn: (OrdinalSales sales, _) => sales.domainValue,
              measureFn: (OrdinalSales sales, _) {
                return sales?.measureValue ?? 0;
              },
              data: [OrdinalSales(DateTime.now(), 0)],
              // colorFn: (OrdinalSales sales, _) =>
              //     charts.Color.fromHex(code: sales.color),
              // fillColorFn: (OrdinalSales sales, _) =>
              //     charts.Color.fromHex(code: sales.color), //'#0000EE'
            )
          ];
  }

//柱状图
  Widget commonChart(context) {
    final simpleCurrencyFormatter =
        new charts.BasicNumericTickFormatterSpec(_formatter);
    final ticks = new charts.StaticDateTimeTickProviderSpec(staticTicks);
    print((staticTicks.length / 2).ceil());
    return Center(
        key: Key(staticTicks.length > 0
            ? staticTicks[0].label.toString() + '2'
            : '2'),
        child: new Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5),
          height: _setHeight(),
          child: charts.TimeSeriesChart(
            seriesList,
            animate: animate,
            // barGroupingType: charts.BarGroupingType.stacked,
            primaryMeasureAxis: new charts.NumericAxisSpec(
                tickFormatterSpec: simpleCurrencyFormatter,
                showAxisLine: true,
                renderSpec: charts.GridlineRendererSpec(
                    minimumPaddingBetweenLabelsPx: 2,
                    axisLineStyle: charts.LineStyleSpec(),
                    lineStyle: charts.LineStyleSpec(
                      dashPattern: [4, 4],
                    ))),
            domainAxis: new charts.DateTimeAxisSpec(
              showAxisLine: true,
              tickProviderSpec: ticks,
              renderSpec: charts.SmallTickRendererSpec(
                  labelRotation: -60,
                  labelAnchor: charts.TickLabelAnchor.before,
                  labelOffsetFromAxisPx: 0,
                  labelOffsetFromTickPx: offset,
                  labelStyle: charts.TextStyleSpec(fontSize: 10)),
            ),
            behaviors: staticTicks.length > 0
                ? [
                    new charts.SeriesLegend(
                      position: charts.BehaviorPosition.bottom,
                      entryTextStyle: charts.TextStyleSpec(
                          fontSize: 8, color: charts.Color.black),
                      desiredMaxColumns: 4,
                      horizontalFirst: true,
                      cellPadding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                    ),
                    new charts.SelectNearest(),
                    new charts.DomainHighlighter()
                  ]
                : [],
            defaultRenderer: new charts.BarRendererConfig(
                groupingType: charts.BarGroupingType.stacked,
                strokeWidthPx: 2.0),
            defaultInteractions: false,
          ),
        ));
  }

  //百分比图
  Widget percentChart(context) {
    final simpleCurrencyFormatter =
        new charts.BasicNumericTickFormatterSpec(_formatterPercent);
    final ticks = new charts.StaticDateTimeTickProviderSpec(staticTicks);
    final primaryTicks = new charts.StaticNumericTickProviderSpec(_primaryTick);

    return Center(
        key: Key(staticTicks.length > 0
            ? staticTicks[0].label.toString() + '1'
            : '1'),
        child: new Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5),
          height: _setHeight(),
          child: charts.TimeSeriesChart(
            seriesList,
            animate: animate,
            primaryMeasureAxis: new charts.NumericAxisSpec(
                showAxisLine: true,
                tickFormatterSpec: simpleCurrencyFormatter,
                tickProviderSpec: primaryTicks),
            domainAxis: new charts.DateTimeAxisSpec(
              showAxisLine: true,
              tickProviderSpec: ticks,
              renderSpec: charts.SmallTickRendererSpec(
                labelRotation: -60,
                labelAnchor: charts.TickLabelAnchor.before,
                labelOffsetFromAxisPx: 0,
                labelOffsetFromTickPx: offset,
                labelStyle: charts.TextStyleSpec(fontSize: 10),
              ),
            ),
            behaviors: staticTicks.length > 0
                ? [
                    new charts.PercentInjector(
                        totalType: charts.PercentInjectorTotalType.domain),
                    new charts.SeriesLegend(
                      position: charts.BehaviorPosition.bottom,
                      entryTextStyle: charts.TextStyleSpec(
                          fontSize: 8, color: charts.Color.black),
                      desiredMaxColumns: 4,
                      horizontalFirst: true,
                      cellPadding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                      outsideJustification:
                          charts.OutsideJustification.middleDrawArea,
                    ),
                    new charts.SelectNearest(),
                    new charts.DomainHighlighter()
                  ]
                : null,
            defaultRenderer: new charts.BarRendererConfig(
                groupingType: charts.BarGroupingType.stacked,
                strokeWidthPx: 2.0),
            // series chart.
            defaultInteractions: false,
          ),
        ));
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final DateTime domainValue;
  final num measureValue;

  OrdinalSales(this.domainValue, this.measureValue);
}
