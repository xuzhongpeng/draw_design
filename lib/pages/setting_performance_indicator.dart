import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:gm_uikit/gm_uikit.dart';

import 'package:staff_performance/constant/constant.dart';
import 'package:staff_performance/model/entities/sell_item_group_entity.dart';
import 'package:staff_performance/utils/log.dart';
import 'package:staff_performance/stores/index.dart';

class SettingIndicatorPage extends StatefulWidget {
  @override
  _SettingIndicatorPageState createState() => _SettingIndicatorPageState();
}

class _SettingIndicatorPageState extends State<SettingIndicatorPage> {
  SettingModel settingModel;
  int sharedValue = 0;
  Map<int, Widget> segChildren;
  Map<int, List<SellItemEntity>> choiceMap = Map();
  Map<int, List<SellItemEntity>> unChoiceMap = Map();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    segChildren = Map();
    getSellItemGroups();
  }

  getSellItemGroups() async {
    settingModel = Store.value<SettingModel>(context);
    settingModel.getSellItemGroups().then((isSuccess) {
      if (isSuccess) {
        setState(() {
          L.p("setState getSellItemGroups");
          var sellItemGroupsList = settingModel.sellItemGroupsList;
          for (var i = 0; i < sellItemGroupsList.length; i++) {
            SellItemGroupEntity sellItemGroupEntity = sellItemGroupsList[i];
            segChildren[i] = Text(sellItemGroupEntity.name);
            var sellitems = sellItemGroupEntity.sellitems;
            List<SellItemEntity> choiceList = List();
            List<SellItemEntity> unChoiceList = List();
            for (var j = 0; j < (sellitems?.length ?? 0); j++) {
              var sellitem = sellitems[j];
              if (sellitem.status == "1") {
                choiceList.add(sellitem);
              } else {
                unChoiceList.add(sellitem);
              }
            }
            choiceMap[i] = choiceList;
            unChoiceMap[i] = unChoiceList;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GMAppBar(
        title: '常用指标设置',
        leading: GMCommonWidget.textButton("取消", callBack: () {
          Navigator.of(context).pop();
        }),
        trailing: GMCommonWidget.textButton("完成", callBack: () {
          L.p("finish");
          GMLoadingWidget().show(context: context);
          settingModel.setSellitems(choiceMap, unChoiceMap).then((isSuccess) {
            if (isSuccess) {
              Store.value<ShopDataModel>(context).refreshData();
              Store.value<StaffDataModel>(context).refreshData();
              Navigator.of(context).pop();
              //
            }
          });
        }),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    L.p("_buildBody${segChildren.length}");
    if (segChildren.length < 2) {
      return Container();
    }
    return Column(
      children: <Widget>[
        _buildSegment(),
        _buildReorderList(),
        _buildNormalListView()
      ],
    );
  }

  Widget _buildSegment() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 9,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: CupertinoSegmentedControl<int>(
              selectedColor: ColorRes.primeryColor,
              borderColor: ColorRes.primeryColor,
              pressedColor: ColorRes.primeryColor,
              children: segChildren,
              onValueChanged: (int newValue) {
                setState(() {
                  sharedValue = newValue;
                });
              },
              groupValue: sharedValue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReorderList() {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: choiceMap[sharedValue].length * singleHeight + 25),
      child: GMReorderableListView(
        physics: NeverScrollableScrollPhysics(),
        header: Container(
          alignment: Alignment(-0.9, 0),
          height: 25,
          child: GMCommonWidget.smallText('已启用'),
        ),
        children: choiceMap[sharedValue]
            .map((item) => GMListViewItem(
                  key: ValueKey(item.id),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GMCommonWidget.normalText(item.name),
                      GMCommonWidget.smallText(item.remark,
                          textstyle:
                              TextStyle(fontSize: 11, color: Colors.grey))
                    ],
                  ),
                  trailing: Row(
                    children: <Widget>[
                      GMCommonWidget.dragIcon(color: Colors.grey),
                      GMCommonWidget.checkIcon(true, callBack: () {
                        setState(() {
                          item.status = '0';
                          var index = choiceMap[sharedValue].indexOf(item);
                          choiceMap[sharedValue].removeAt(index);
                          unChoiceMap[sharedValue].add(item);
                          L.p("choiceMao${choiceMap[sharedValue]}");
                          L.p("choiceMao${unChoiceMap[sharedValue]}");
                        });
                      })
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: GMCommonWidget.topAndBottomBorderSide()),
                ))
            .toList(),
        onReorder: (int oldIndex, int newIndex) {
          L.p("oldIndex$oldIndex newIndex:$newIndex");
          if (choiceMap[sharedValue].length == 1) {
            return;
          }
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }

          setState(() {
            var item = choiceMap[sharedValue].removeAt(oldIndex);
            choiceMap[sharedValue].insert(newIndex, item);
          });
        },
      ),
    );
  }

  Widget _buildNormalListView() {
    return GmListView(
      title: '未启用',
      childrens: unChoiceMap[sharedValue].map((item) {
        return GMListViewItem(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GMCommonWidget.normalText(item.name),
              GMCommonWidget.smallText(item.remark,
                  textstyle: TextStyle(fontSize: 11, color: Colors.grey))
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              border: true
                  ? GMCommonWidget.topAndBottomBorderSide()
                  : GMCommonWidget.bottomBorderSide()),
          trailing: GMCommonWidget.checkIcon(false, callBack: () {
            setState(() {
              item.status = '1';
              var index = unChoiceMap[sharedValue].indexOf(item);
              unChoiceMap[sharedValue].removeAt(index);
              choiceMap[sharedValue].add(item);
            });
          }),
        );
      }).toList(),
    );
  }
}
