/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-07-15 14:56:09
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-12-16 15:14:16
 */
/// Example of a simple line chart.
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:staff_performance/model/peformance_data_manager.dart';

class CustomLineChart extends StatefulWidget {
  final Map<String, dynamic> all; //包含折线图需要的数据及纵坐标的数据，放一起是因为纵坐标需要动态渲染
  static List<charts.TickSpec<DateTime>> staticTicks = [];
  final Map<String, dynamic> requestMap;
  final sellName;
  String change;
  CustomLineChart(this.all, this.requestMap, this.sellName);

  factory CustomLineChart.withData(List<Map<String, List>> datas,
      Map<String, dynamic> requestMap, String name) {
    var custom = new CustomLineChart(
        _createData(datas, requestMap['groupBy']), requestMap, name);
    //创建一个随机数用来更新视图
    custom.change = createRomdom();
    return custom;
  }
  static String createRomdom() {
    String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    int strlenght = 10;

    /// 生成的字符串固定长度
    String left = '';
    for (var i = 0; i < strlenght; i++) {
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }

  static Map<String, dynamic> _createData(
      List<Map<String, List>> datas, String type) {
    List<LinearSales> data = [];
    int length = datas.length;
    int width = 1;
    if (length > 5 && type != 'day')
      width = length ~/ 5;
    else if (type == 'day') width = length - 1;
    staticTicks = [];
    datas.forEach((item) {
      int index = datas.indexOf(item);
      String time = item.keys.first;
      try {
        int year = int.parse(time.substring(0, 4));

        int month = type != 'year' ? int.parse(time.substring(5, 7)) : 0;

        int day = type == 'day' ? int.parse(time.substring(8, 10)) : 0;

        DateTime date = type == 'year'
            ? new DateTime(year)
            : (type == 'month'
                ? new DateTime(year, month)
                : new DateTime(year, month, day));
        String unit = type == 'year'
            ? '$year年'
            : (type == 'month' ? '$month月' : '$month月$day日');
        data.add(LinearSales(date, double.parse(item.values.first[0].value)));
        if (index == 0 || index % width == 0) {
          staticTicks.add(new charts.TickSpec(
            date,
            label: '$unit',
          ));
        }
      } catch (e) {
        // print(e);
      }
    });
    return {
      'seriesList': [
        new charts.Series<LinearSales, DateTime>(
          id: 'Sales',
          colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
          domainFn: (LinearSales sales, _) => sales.time,
          measureFn: (LinearSales sales, _) => sales.sales,
          data: data,
        )..setAttribute(charts.rendererIdKey, 'customArea')
      ],
      'ticks': staticTicks
    };
  }

  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  //详情是否展示
  bool show = false;
  //日期
  String clickTime = '';
  //类型
  String type = '';
  //金额
  double cost = 0;
  //详情显示位置是左边还是右边
  bool left = true;
  var simpleCurrencyFormatter;
  var ticks;
  CustomLineChart oldWidget;
  Timer timer;
  String _formatter(num value) {
    String res = value.abs() > 10000 ? '${value / 10000}万' : value.toString();
    return res;
  }

  var chart;
  @override
  initState() {
    oldWidget = widget;
    _changeDependies();
  }

  double _setHeight() {
    double height = 250.0;
    return height;
  }

  void _changeDependies() {
    simpleCurrencyFormatter =
        new charts.BasicNumericTickFormatterSpec(_formatter);
    ticks = new charts.StaticDateTimeTickProviderSpec(widget.all['ticks']);
    chart = _chartArea();
  }

  @override
  Widget build(BuildContext context) {
    if (oldWidget.change != widget.change) {
      _changeDependies();
      oldWidget = widget;
    }
    return Center(
      child: GestureDetector(
        onTap: () => {
          setState(() {
            show = false;
          })
        },
        child: new Container(
            key: Key(widget.all['ticks'].length > 0
                ? widget.all['ticks'][0].label.toString()
                : '3'),
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(5),
            height: _setHeight(),
            child: Stack(overflow: Overflow.visible, children: [
              chart,
              show
                  ? ShowDetail(
                      time: clickTime,
                      type: type,
                      number: cost,
                      left: left,
                    )
                  : Container()
            ])),
      ),
    );
  }

  Widget _chartArea() {
    return charts.TimeSeriesChart(widget.all['seriesList'],
        animate: false, //widget.animate,
        domainAxis: new charts.DateTimeAxisSpec(
          showAxisLine: true,
          renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(fontSize: 12)),
          tickProviderSpec: ticks,
        ),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickFormatterSpec: simpleCurrencyFormatter,
            showAxisLine: true,
            renderSpec: charts.GridlineRendererSpec(
                minimumPaddingBetweenLabelsPx: 2,
                axisLineStyle: charts.LineStyleSpec(),
                lineStyle: charts.LineStyleSpec(
                  dashPattern: [4, 4],
                ))),
        selectionModels: [
          new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
        customSeriesRenderers: [
          new charts.LineRendererConfig(
              customRendererId: 'customArea', includeArea: true, stacked: true),
        ]);
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if (model.selectedSeries == null || model.selectedSeries.length == 0) {
      return;
    }
    int dataLength = model.selectedSeries.first.data.length;
    int nowIndex = selectedDatum.first.index;
    String time;
    final measures = <String, num>{};
    if (selectedDatum.isNotEmpty) {
      time = PeformanceDataHandle.translationDateFormatter(
          selectedDatum.first.datum.time.toString(),
          formatKey: widget.requestMap['groupBy']);
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum.sales;
      });
    }
    bool isleft = true;
    if ((nowIndex + 1) / dataLength < 0.5) {
      isleft = false;
    }
    timer?.cancel();
    setState(() {
      clickTime = time;
      type = widget.sellName;
      cost = num.tryParse(measures['Sales'].toStringAsFixed(2));
      left = isleft;
      show = true;
    });
    timer = new Timer(const Duration(milliseconds: 7000), () {
      setState(() {
        show = false;
      });
    });
  }
}

/// Sample linear data type.
class LinearSales {
  final DateTime time;
  final double sales;

  LinearSales(this.time, this.sales);
}

//点击折线提示框
class ShowDetail extends StatelessWidget {
  final String time;
  final String type;
  final double number;
  final bool left;
  ShowDetail({this.time, this.type, this.number, this.left = true});
  @override
  Widget build(BuildContext context) {
    var style = TextStyle(color: Colors.white, fontSize: 10);
    // var position = left ? {'left': 0} : {'right': -10};
    return Positioned(
      right: left ? null : -10,
      left: left ? 50 : null,
      child: Container(
          width: 125,
          // height: 35,
          color: Color.fromRGBO(0, 0, 0, 0.7),
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                time,
                style: style,
              ),
              Container(
                width: 165,
                height: 15,
                child: Stack(
                  children: [
                    Positioned(
                      child: new CustomPaint(
                          size: new Size(13, 13), painter: new MyPainter()),
                    ),
                    Positioned(
                        left: 10,
                        child: Text(
                          type,
                          style: style,
                        )),
                    Positioned(
                      right: 1,
                      child: Text(
                        number.toString(),
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

//小点点
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..colorFilter = ColorFilter.mode(
          Color.fromARGB(243, 190, 35, 1), BlendMode.srcATop) //颜色渲染模式
      ..filterQuality = FilterQuality.high; //颜色渲染模式的质量
    canvas.drawCircle(new Offset(6, 8), 4, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
