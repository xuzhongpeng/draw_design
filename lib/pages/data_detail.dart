import 'package:flutter/material.dart';
import 'package:gm_uikit/gm_uikit.dart';

import './shop_detail.dart';

class DataMessage {
  ///表头名称，例如'日期'
  String headerName;

  ///表格展示的数据类型，例如'营业额'
  String showType;

  ///type为0表示店铺，为1表示员工
  int type = 0;
  DataMessage(this.headerName, this.showType, {this.type});
}

class DataDetail extends StatefulWidget {
  DataDetail(this.datas, this.message,
      {this.ownerableName = 'shop', this.color = false});
  final Map<String, dynamic> datas;
  final DataMessage message;
  final String ownerableName;
  final bool color;
  @override
  _DataDetail createState() => _DataDetail();
}

class _DataDetail extends State<DataDetail> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //转化数据
    String name = '详情';
    List<Map<String, dynamic>> header = [];
    List<Map<String, dynamic>> dataSource = [];
    //转化名称
    name = widget.datas.values.first;

    //转化头部
    header = [
      {
        'prop': widget.message.headerName,
        'label': widget.message.headerName,
        'sortable': true,
        'fixed': 'left'
      },
      {
        'prop': widget.message.showType,
        'label': widget.message.showType,
        'sortable': true,
      }
    ];
    //转化展示数据
    widget.datas.keys.forEach((data) {
      if (data != 'id' && data != 'color') {
        var source = {
          widget.message.headerName: data,
          widget.message.showType: widget.datas[data]
        };

        dataSource.add(source);
      }
    });
    if (widget.color)
      dataSource[1]['color'] =
          Color.fromRGBO(251, 248, 227, 1).value.toString();
    return Scaffold(
      appBar: GMAppBar(
        title: name,
        trailing: widget.datas['id'] != null
            ? Padding(
                padding: EdgeInsets.only(right: 5),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ShopDetail(
                              ownerableId: widget.datas['id'],
                              ownerableType: widget.ownerableName,
                              userName: name,
                            )));
                  },
                  child: Text(widget.ownerableName == 'shop' ? '店铺详情' : '员工详情',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ))
            : Container(),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListView(children: <Widget>[
            GmTable(
              header,
              dataSource.sublist(1),
              key: Key(
                dataSource.toString(),
              ),
            ),
          ])
        ],
      ),
    );
  }

  void _centerBack() {
    //ChannelUtil.invokeBack();
    Navigator.of(context).pop();
  }
}
