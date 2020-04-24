import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:gm_uikit/gm_uikit.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:staff_performance/model/setting_model.dart';
// import 'package:staff_performance/model/top_model.dart';
import 'package:staff_performance/pages/setting_goal_create.dart';
import 'package:staff_performance/utils/log.dart';
import 'package:staff_performance/views/goal_ui.dart';
import 'package:staff_performance/stores/index.dart';

class SettingGoalPage extends StatefulWidget {
  @override
  _SettingGoalPageState createState() => _SettingGoalPageState();
}

class _SettingGoalPageState extends State<SettingGoalPage> {
  @override
  void initState() {
    super.initState();
    request();
  }

  request() {
    // Future.delayed(Duration.zero, () {
    Store.value<SettingModel>(context, listen: false).getSelltargetsList();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Store.connect<SettingModel>(builder: (context, settingModel, child) {
      return Scaffold(
        appBar: GMAppBar(
          title: '目标设置',
          leading: GMCommonWidget.barButton(Icons.arrow_back_ios,
              color: Colors.white, callBack: _backClick),
          trailing: GMCommonWidget.customIcon(
            Icons.add,
            color: Colors.white,
            callBack: _newGoalClick,
          ),
        ),
        body: _buildContent(settingModel),
      );
    });
  }

  //新建目标
  void _newGoalClick() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return SettingNewGoalPage(CREATE);
    })).then((needRefresh) {
      if (needRefresh ?? false) {
        request();
      }
    });
  }

  Widget _buildContent(SettingModel model) {
    L.p("model.goalList:${model.goalList}");
    if (model == null || model.goalList == null) {
      return Container();
    }
    return ListView.separated(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: model.goalList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              L.p("目标item点击${model.goalList[index]}");
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                return SettingNewGoalPage(EDIT,
                    goalEntity: model.goalList[index]);
              }));
            },
            child: GoalUI(model.goalList[index]),
          );
        },
        separatorBuilder: (context, index) => Divider(
              color: Colors.grey,
              height: 0.2,
            ));
  }

  void _backClick() {
    Navigator.of(context).pop();
  }
}
