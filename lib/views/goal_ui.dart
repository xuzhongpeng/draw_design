import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:gm_uikit/gm_uikit.dart';

import 'package:staff_performance/constant/constant.dart';
import 'package:staff_performance/utils/center_util.dart';
import 'package:staff_performance/model/entities/goal_entity.dart';

class GoalUI extends StatelessWidget {
  final GoalEntity goalEntity;
  final bool showName;
  GoalUI(this.goalEntity, {this.showName = true});

  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(goalEntity.title,
                      style: GMCommonWidget.black14TextStyle),
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 3),
                    child: Text(goalEntity.getSecond(),
                        style: GMCommonWidget.grey12TextStyle),
                  ),
                  Text(goalEntity.getDate() ?? "",
                      style: GMCommonWidget.grey12TextStyle)
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          child: Image.asset(
                              'lib/assets/performance/target_icon_15.png',
                              width: 13,
                              height: 13,
                              package: CenterUtils.getImagePackage()),
                        ),
                        Text(goalEntity.getPercentWithSymbol(),
                            style: TextStyle(
                                color: ColorRes.orange,
                                fontSize: 17,
                                fontWeight: FontWeight.w500))
                      ],
                    ),
                    showName
                        ? Text(
                            "${goalEntity.getStaffName()}",
                            softWrap: false,
                            maxLines: 1,
                            style: GMCommonWidget.black17TextStyle,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Container()
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 3),
            child: Container(
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: ColorRes.lineGrey,
                value: goalEntity.getPercent(),
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          )
        ],
      ),
    );
  }
}
