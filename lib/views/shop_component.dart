import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:gm_uikit/gm_uikit.dart';

import 'package:staff_performance/model/peformance_data_manager.dart';

typedef void SegmentCallback(int);

class ShopComponent {
  static Color get normalColor => Color(0xff333333);

  static const double Line_Height = 40;
  static const double Line_Width = 110;

  static TextStyle themeTextStyle(BuildContext context,
          {FontWeight fontWeight = FontWeight.w300}) =>
      TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 14,
          fontWeight: fontWeight);

  static TextStyle greyTextStyle({double size = 14, FontWeight fontWeight}) =>
      TextStyle(color: Colors.grey, fontSize: size, fontWeight: fontWeight);

  static List<String> get bottomTitle => [
        "1. 统计区间: 2018年4月1日 00:00:00 到 2018年11月30日 23:59:59",
        "2. 营业额: 销售金额-退货金额"
      ];

  static Widget buildRichText(
      {String title,
      String subTitle,
      bool autoSize = false,
      VoidCallback callBack}) {
    return GestureDetector(
      onTap: callBack,
      child: FittedBox(
        fit: autoSize ? BoxFit.fitHeight : BoxFit.none,
        child: RichText(
            textAlign: TextAlign.center,
            maxLines: 2,
            text: TextSpan(
              text: '$title\n',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff333333),
              ),
              children: [
                TextSpan(
                  text: subTitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w400),
                )
              ],
            )),
      ),
    );
  }

  static Widget buildCupertinoSegmentedControl(
      {@required BuildContext context,
      List<String> items,
      double size,
      SegmentCallback callBack,
      int selectIndex = 0,
      double width = 50}) {
    return CupertinoSegmentedControl(
      selectedColor: Theme.of(context).primaryColor,
      unselectedColor: Colors.transparent,
      borderColor: Theme.of(context).primaryColor,
      groupValue: selectIndex,
      pressedColor: Colors.transparent,
      onValueChanged: callBack,
      children: segmentElement(
          context: context,
          size: size,
          items: items,
          currentSelect: selectIndex,
          width: width),
    );
  }

  static Map<int, Widget> segmentElement(
      {@required BuildContext context,
      List<String> items,
      double size,
      int currentSelect,
      double width}) {
    final result = Map<int, Widget>();
    items.forEach((item) {
      int index = items.indexOf(item);
      result[index] = segmentItem(
          context: context,
          title: item,
          size: size,
          select: currentSelect == index,
          width: width);
    });
    return result;
  }

  static Widget segmentItem(
      {@required BuildContext context,
      String title,
      double size,
      bool select,
      double width}) {
    return Container(
      width: width,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: select ? Colors.white : Theme.of(context).primaryColor,
            fontSize: size),
      ),
    );
  }

  /// 表格初始化
  static Widget buildDetailList(BuildContext context, TableData items,
      {Function callback}) {
    return GmTable(items.header, items.dataSource,
        key: Key(items.dataSource.toString()), clickRow: callback);
  }
}
