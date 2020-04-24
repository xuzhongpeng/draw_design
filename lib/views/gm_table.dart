import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gm_uikit/gm_uikit.dart';

///测试方法
class TableTest {
  static Widget test() {
    ///定义头部数据
    List<Map<String, dynamic>> header = [
      {
        'prop': 'date',
        'label': '日期',
        'sortable': true,
      },
      {
        'prop': 'name',
        'label': '姓名',
        'sortable': true,
      },
      {
        'prop': 'address',
        'label': '地址',
        'sortable': true,
      },
      {
        'prop': 'cost',
        'label': '金额',
        'fixed': 'left',
        'sortable': true,
      }
    ];

    ///数据源
    List<Map<String, dynamic>> dataSouce = [
      {
        "date": '2016-05-02',
        "address": '上海市普陀区金',
        "name": '王小虎',
        "cost": 100,
      },
      {
        "date": '2016-05-04',
        "name": '王小虎',
        "address": '上海市普陀区金沙江路 1517 弄',
        "cost": 120,
      },
      {
        "date": '2016-05-01',
        "name": '王小虎',
        "address": '上海市普陀区金沙江路 1519 弄',
        "cost": 200,
      },
      {
        "date": '2016-05-03',
        "name": '王小虎',
        "address": '上海市普陀区金沙江路 1516 弄',
        "cost": 1210,
      },
      {
        "date": '2016-05-01',
        "name": '王小虎',
        "address": '上海市普陀区金沙江路 1519 弄',
        "cost": 110,
      },
      {
        "date": '2016-05-03',
        "name": '王小虎',
        "address": '上海市普陀区金沙江路 1516 弄',
        "cost": 300,
      }
    ];

    return GmTable(header, dataSouce);
  }
}

const double Line_Height = 40;
const double Line_Width = 80;
const double HeaderLineWidth = 90;
const double FontSize = 12;

///表格
class GmTable extends StatefulWidget {
  GmTable(
    this.header,
    this.dataSource, {
    this.clickRow,
    Key key,
  }) : super(key: key);

  final header;
  final dataSource;
  final Function clickRow;
  @override
  _GmTable createState() => _GmTable();
}

class _GmTable extends State<GmTable> {
  ///定义表头及每列属性
  List<Map<String, dynamic>> header;
  List<Map<String, dynamic>> dataSouce;
  Map<String, dynamic> fixed = new Map(); //左固定的数据
  /// 排序的数据
  Map<String, int> order = new Map();
  Color get normalColor => Color(0xff333333);
  @override
  void initState() {
    super.initState();
    header = widget.header;
    dataSouce = List.from(widget.dataSource);
    header.forEach((value) {
      if (value['sortable']) {
        order[value['label']] = 0;
      }
    });
  }

  //处理
  void sort(data, sort) {
    setState(() {
      if (sort != 0) {
        List<Map<String, dynamic>> sortData = List.from(widget.dataSource);
        sortData = sortData.sublist(1);
        sortData.sort((pre, next) {
          if (sort == 1) {
            return dataChange(pre[data['prop']], next[data['prop']]);
          } else {
            return dataChange(next[data['prop']], pre[data['prop']]);
          }
        });
        dataSouce = List.from(widget.dataSource);
        dataSouce = dataSouce.sublist(0, 1);
        dataSouce.addAll(sortData);
      } else {
        dataSouce = List.from(widget.dataSource);
      }
    });
  }

  /// 把数据转化为int型再比较
  int dataChange(dynamic pre, dynamic next) {
    //数字类型直接减
    if (pre is int && next is int) {
      return pre - next;
    }
    if (pre is String && next is String) {
      try {
        num a, b;
        a = num.parse(pre);
        b = num.parse(next);
        return a.toInt() - b.toInt();
      } catch (e) {
        try {
          var a = DateTime.parse(pre);
          var b = DateTime.parse(next);
          return a.compareTo(b);
        } catch (e) {
          if (pre.toString().indexOf('年') != -1 &&
              next.toString().indexOf('年') != -1) {
            var pre1 = pre.replaceAll(new RegExp(r'年|月|日'), '');
            var next1 = next.replaceAll(new RegExp(r'年|月|日'), '');
            if (pre1.length != 8) {
              pre1 = pre1.padRight(7, '01');
              next1 = next1.padRight(7, '01');
            }
            var a = DateTime.parse(pre1);
            var b = DateTime.parse(next1);
            return a.compareTo(b);
          } else {
            if (pre.toString().indexOf('汇总') != -1) {
              return 1;
            } else if (next.toString().indexOf('汇总') != -1) {
              return -1;
            } else {
              return 0;
            }
          }
        }
      }
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    //找到fixed的列
    for (var item in header) {
      if (item['fixed'] == 'left') {
        fixed['prop'] = item['prop'];
        fixed['index'] = header.indexOf(item);
        break;
      }
    }

    return GmListView(
      childrens: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //定义靠边内容
            Material(
              // shadowColor: Color.fromRGBO(244, 240, 244, 0.5),
              // elevation: 1.0,
              child: fixed != null && fixed.isNotEmpty
                  ? Column(
                      children: [
                        header.length > 0
                            ? _buildTitle(
                                header[fixed['index']]['label'].toString(),
                                1,
                                header[fixed['index']]['sortable'] == true,
                                callback: (reorder) {
                                  sort(header[fixed['index']], reorder);
                                },
                              )
                            : Container(),
                        ...dataSouce.map((item) {
                          return _buildTitle(item[fixed['prop']].toString(),
                              dataSouce.indexOf(item), false, clickRow: () {
                            widget.clickRow(item);
                          });
                        }).toList()
                      ],
                    )
                  : Container(),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    _buildHeader(context, header, 0, callback: sort),
                    ...dataSouce.map((item) {
                      return _buildItem(context, item, dataSouce.indexOf(item));
                    }).toList()
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  // 表头
  Widget _buildHeader(context, List<Map<String, dynamic>> items, index,
      {Function callback}) {
    var item = [];
    items.forEach((v) {
      if (v['fixed'] != 'left') {
        item.add(v);
      }
    });
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        color: index % 2 != 0 ? Colors.white : Color.fromRGBO(244, 245, 246, 1),
        padding: EdgeInsets.only(left: _setRowPadding(item.length)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: item != null
              ? item.map((value) {
                  return _buildValue(
                    context,
                    value['label'].toString() ?? '',
                    item.length,
                    isHeader: true,
                    callback: (order) {
                      callback(value, order);
                    },
                  );
                }).toList()
              : [],
        ),
      ),
    );
  }

  //每行数据
  Widget _buildItem(context, Map<String, dynamic> items, int index) {
    var item = [];
    header.forEach((head) {
      int i = 0;
      items.keys.forEach((v) {
        if (v != fixed['prop'] && v == head['prop']) {
          item.add(List.from(items.values)[i]);
        }
        i++;
      });
    });
    return GestureDetector(
      onTap: () {
        widget.clickRow(items);
      },
      child: Container(
        color: index % 2 != 0 ? Color.fromRGBO(244, 245, 246, 1) : Colors.white,
        padding: EdgeInsets.only(left: _setRowPadding(item.length)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: item != null
              ? item.map((value) {
                  return _buildValue(
                      context, value.toString() ?? '', item.length);
                }).toList()
              : [],
        ),
      ),
    );
  }

  Widget _buildTitle(String title, int index, bool isSort,
      {Function callback, Function clickRow}) {
    return Container(
        alignment: Alignment.center,
        height: Line_Height,
        color: index % 2 != 0 ? Color.fromRGBO(244, 245, 246, 1) : Colors.white,
        width: HeaderLineWidth,
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: GestureDetector(
          onTap: isSort
              ? () {
                  setStateSort(title, callback);
                }
              : clickRow,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10),
                width: isSort ? null : HeaderLineWidth,
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: normalColor,
                      fontSize: FontSize,
                      fontWeight: FontWeight.w500),
                ),
              ),
              isSort
                  ? SortIcon(
                      order[title],
                      width: 10,
                      callback: (value) {
                        setStateSort(title, callback);
                      },
                    )
                  : Container()
            ],
          ),
        ));
  }

  Widget _buildValue(context, String title, int length,
      {bool isHeader = false, Function callback}) {
    return Container(
      height: Line_Height,
      // width: Line_Width,
      padding: EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: isHeader
            ? () {
                setStateSort(title, callback);
              }
            : null,
        child: Row(children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            width: isHeader ? Line_Width - 10 : null,
            constraints: isHeader
                ? new BoxConstraints(minWidth: Line_Width - 10)
                : new BoxConstraints(minWidth: Line_Width),
            padding: isHeader ? null : EdgeInsets.only(right: 10),
            child: isHeader
                ? Text(
                    title,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      color: normalColor,
                      fontSize: FontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: normalColor,
                        fontSize: FontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
          isHeader
              ? SortIcon(
                  order[title],
                  callback: (value) {
                    setStateSort(title, callback);
                  },
                )
              : Container(),
        ]),
      ),
    );
  }

  ///排序按钮变化
  void setStateSort(String title, Function callback) {
    int now = order[title];
    setState(() {
      order.keys.forEach((f) {
        order[f] = 0;
      });
      order[title] = now == 0 ? 1 : now == 1 ? 2 : 0;
    });
    callback(order[title]);
  }

  ///设置条数据的宽度
  double _setRowPadding(int length) {
    int index = 0;
    double lineWidth = Line_Width + 5;
    double leftWidth = MediaQuery.of(context).size.width - HeaderLineWidth;
    double rowWidth = lineWidth * length;
    for (int i = 1; i <= length; i++) {
      double mainWidth = lineWidth * i;
      if (mainWidth > leftWidth) {
        index = i;
        break;
      }
    }
    if (index == 0) {
      return leftWidth - rowWidth;
    } else {
      return leftWidth - (lineWidth * (index - 1));
    }
  }
}

//排序功能组件
class SortIcon extends StatelessWidget {
  final callback;
  final int sort;
  final double width;
  SortIcon(this.sort, {Key key, this.width, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callback != null ? callback(sort) : null;
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: width ?? 10,
            height: Line_Height,
          ),
          Positioned(
            left: 0,
            top: 10,
            child: Icon(
              Icons.arrow_drop_up,
              size: 15,
              color: sort == 2 ? Color.fromRGBO(77, 177, 156, 1) : Colors.grey,
            ),
          ),
          Positioned(
            left: 0,
            top: 15,
            child: Icon(
              Icons.arrow_drop_down,
              size: 15,
              color: sort == 1 ? Color.fromRGBO(77, 177, 156, 1) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class SortAble {
  final sort;
  SortAble(this.sort);
}
