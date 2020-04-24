import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gm_uikit/gm_uikit.dart';
import 'package:staff_performance/constant/constant.dart';
import 'package:staff_performance/model/entities/goal_entity.dart';
// import 'package:staff_performance/model/setting_model.dart';
import 'package:staff_performance/utils/log.dart';
import 'package:staff_performance/utils/number_format_util.dart';
import 'package:staff_performance/stores/index.dart';

const int CREATE = 0;
const int EDIT = 1;

class SettingNewGoalPage extends StatefulWidget {
  final int pageStatus;
  final GoalEntity goalEntity;
  SettingNewGoalPage(this.pageStatus, {this.goalEntity}) {}

  @override
  _SettingNewGoalPageState createState() => _SettingNewGoalPageState();
}

class _SettingNewGoalPageState extends State<SettingNewGoalPage> {
  TextEditingController _textEditingController = TextEditingController();
  bool isCreate = false;
  GoalEntity goalEntity;
  List<Staff> allStaffs;
  List<IndicatorClass> indicatorClazz = List();
  SettingModel settingModel;
  @override
  void initState() {
    super.initState();
    isCreate = widget.pageStatus == CREATE;
    if (isCreate) {
      goalEntity = GoalEntity();
      // goalEntity.staffs = new List<Staff>()..add(Staff()..id = 0..name = "史蒂夫");
    } else {
      goalEntity = widget.goalEntity;
    }
    settingModel = Store.value<SettingModel>(context, listen: false);

    //获取指标数据 并默认获取第一个指标分类的第一个指标
    getSellItemGroups();
    getStaffs();
  }

  getStaffs() async {
    await settingModel.getStaffs();
    allStaffs = settingModel.staffs;
    L.p("allStaffs${allStaffs}");
  }

  getSellItemGroups() async {
    // GMLoadingWidget().show(context: context);
    await settingModel.getSellItemGroupsInGoalCreatePage();
    if (isCreate) {
      var indicator = settingModel.indicatorClazz[0].indicators[0];
      setState(() {
        goalEntity.indicator = indicator;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GMAppBar(
        title: isCreate ? '新建目标' : "目标详情",
        leading: GMCommonWidget.textButton("取消", callBack: () {
          Navigator.of(context).pop();
        }),
        trailing: isCreate
            ? GMCommonWidget.textButton("完成", callBack: _onDoneClick)
            : Container(),
      ),
      body: _buildContent(settingModel),
    );
  }

  Widget _buildContent(SettingModel settingModel) {
    return ListView(
      children: <Widget>[
        buildCardWidget(NewGoalInputType.INPUT_TYPE_TITLE),
        buildCardWidget(NewGoalInputType.INPUT_TYPE_DATE),
        buildCardWidget(NewGoalInputType.INPUT_TYPE_INDICATOR),
        buildCardWidget(NewGoalInputType.INPUT_TYPE_GOAL_VALUE),
        buildCardWidget(NewGoalInputType.INPUT_TYPE_STAFFS),
      ],
    );
  }

  _onDoneClick() {
    if (!goalEntity.isValidGoalValue()) {
      showToast("请输入目标值\n输入结果禁止为输入零或负数,最多2位小数");
      return;
    }
    if (goalEntity.staffs.length == 0) {
      showToast("请选择员工");
      return;
    }

    if (goalEntity.indicator == null || goalEntity.indicator.id == null) {
      L.p("指标为空");
      return;
    }

    if (!(goalEntity.title?.isNotEmpty ?? false)) {
      goalEntity.title = "目标";
    }

    // GMLoadingWidget().show(context: context);
    settingModel.setSellTargets(goalEntity).then((isSuccess) {
      if (isSuccess) {
        //回到上一页要刷新吧
        Navigator.of(context).pop(true);
      }
    });
    L.p("goal$goalEntity");
  }

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 17.0);
  }

  Widget buildCardWidget(NewGoalInputType newGoalInputType) {
    EdgeInsets edgeInsets = EdgeInsets.only(left: 10, right: 10, top: 10);
    Widget titleHint;
    Widget inputContentWidget;
    Widget rightIcon = Container();
    GestureTapCallback callBack;
    switch (newGoalInputType) {
      case NewGoalInputType.INPUT_TYPE_TITLE:
        titleHint = _titleHintWidget("名称", false);
        inputContentWidget = isCreate
            ? TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "xxx的业绩目标",
                    hintStyle: GMCommonWidget.grey24TextStyle),
                style: GMCommonWidget.black24TextStyle,
                onChanged: (value) {
                  goalEntity.title = value;
                },
              )
            : Text(
                goalEntity.title,
                style: GMCommonWidget.black24TextStyle,
              );
        break;
      case NewGoalInputType.INPUT_TYPE_DATE:
        titleHint = _titleHintWidget("日期", isCreate);
        String date;
        if (isCreate) {
          date = goalEntity.getDate();
          L.p("date$date");
          if (date == null) {
            date = goalEntity.getDefaultDate();
          }
        } else {
          date = goalEntity.getNetDate();
        }
        inputContentWidget = Text(
          date,
          style: GMCommonWidget.black24TextStyle,
        ); //默认填写本年的下个月
        rightIcon = isCreate ? GMCommonWidget.forwardIcon() : Container();
        callBack = isCreate
            ? () {
                showModalBottomSheet<Null>(
                    context: context,
//                    backgroundColor: Colors.transparent,
//                    isScrollControlled: true,
                    // shape: RoundedRectangleBorder (borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
                    builder: (BuildContext context) {
                      return GmDateChoose(
                          // dateType: goalEntity.dateType,
                          // startDateTime: goalEntity.startDateTime,
                          // endDateTime: goalEntity.endDateTime,
                          MAX_DATETIME: "2030-12-12",
                          dateConfirmed: (start, end, type) {
                            if (start.compareTo(end) > 0) {
                              showToast("开始时间不能大于结束时间");
                              return;
                            }
                            print("type$type start$start end$end");
                            setState(() {
                              goalEntity.startDateTime = start;
                              goalEntity.endDateTime = end;
                              goalEntity.dateType = type;
                            });
                          });
                    });
              }
            : null;
        break;
      case NewGoalInputType.INPUT_TYPE_INDICATOR:
        titleHint = _titleHintWidget("指标", isCreate);
        inputContentWidget = Text(
          goalEntity.indicator?.name ?? "",
          style: GMCommonWidget.black24TextStyle,
        ); //默认获取第一个指标分类的第一个指标
        rightIcon = isCreate ? GMCommonWidget.forwardIcon() : Container();
        callBack = isCreate
            ? () {
                if (indicatorClazz.length < 2) {
                  return;
                }
                showModalBottomSheet<Null>(
                    context: context,
//                    backgroundColor: Colors.transparent,
//                    isScrollControlled: true,
                    // shape: RoundedRectangleBorder (borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
                    builder: (BuildContext context) {
                      return IndicatorSelectorBottomSheet(
                        indicatorClazz: indicatorClazz,
                        indicatorConfirmed: (indicator) {
                          setState(() {
                            _textEditingController.text = "";
                            goalEntity.indicator = indicator;
                          });
                        },
                      );
                    });
              }
            : null;
        break;
      case NewGoalInputType.INPUT_TYPE_GOAL_VALUE:
        if (!isCreate) {
          _textEditingController.text = "${goalEntity.goalValue * 100}%";
        }
        titleHint = _titleHintWidget("目标值", isCreate);
        inputContentWidget = isCreate
            ? TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "请输入数字",
                  hintStyle: GMCommonWidget.grey24TextStyle,
                ),
                controller: _textEditingController,
                style: GMCommonWidget.black24TextStyle,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  NumScale2TextInputFormatter(
                      goalEntity.indicator?.isPercent ?? false)
                ],
                onChanged: (value) {
                  var finalValue = value.replaceAll("%", "");
                  goalEntity.goalValue = NumberFormatUtil.strToDou(finalValue);
                },
                onEditingComplete: () {
                  L.p("value:${_textEditingController.text}");
                },
                onSubmitted: (value) {
                  L.p("value1:${value}");
                },
              )
            : Text(
                goalEntity.getGoalValue(),
                style: GMCommonWidget.black24TextStyle,
              );
        break;
      case NewGoalInputType.INPUT_TYPE_STAFFS:
        titleHint = _titleHintWidget("员工", isCreate);
        Widget staffContainer = Padding(
          padding: EdgeInsets.only(top: 8),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //每行2个
                mainAxisSpacing: 10.0, //主轴(竖直)方向间距
                crossAxisSpacing: 10.0, //纵轴(水平)方向间距
                childAspectRatio: 3.6 //纵轴缩放比例
                ),
            shrinkWrap: true,
            itemCount: isCreate
                ? ((goalEntity.staffs?.length ?? 0) + 1)
                : (goalEntity.staffs?.length ?? 0),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == (goalEntity.staffs?.length ?? 0) && isCreate) {
                return Container(
                  decoration: BoxDecoration(
                    border: new Border.all(
                        color: ColorRes.primeryColor, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Center(
                    child: GMCommonWidget.customIconWithGest(Icons.add),
                  ),
                );
              }
              var staff = goalEntity.staffs[index];
              return Container(
                decoration: BoxDecoration(
                    border: new Border.all(
                        color: ColorRes.primeryColor, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: ColorRes.primeryColor),
                child: Center(
                  child: Text(
                    staff?.name ?? 'null',
                    style: GMCommonWidget.whiteTextStyle,
                  ),
                ),
              );
            },
          ),
        );

        inputContentWidget = GestureDetector(
          child: staffContainer,
          onTap: isCreate
              ? () {
                  L.p("staffContainer");
                  showModalBottomSheet<Null>(
                      context: context,
//                      backgroundColor: Colors.transparent,
//                      isScrollControlled: true,
                      // shape: RoundedRectangleBorder (borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
                      builder: (BuildContext context) {
                        for (var item in goalEntity.staffs) {
                          for (var itemAll in allStaffs) {
                            if (itemAll.id == item.id) {
                              itemAll.selected = true;
                              break;
                            }
                          }
                        }
                        return StaffSelectorBottomSheet(
                          staffs: allStaffs,
                          staffsConfirmed: (staffs) {
                            setState(() {
                              goalEntity.staffs = staffs;
                            });
                          },
                        );
                      });
                }
              : null,
        );
        break;
      default:
    }
    return GestureDetector(
      onTap: callBack,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: edgeInsets,
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                titleHint,
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: inputContentWidget,
                      ),
                      rightIcon
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleHintWidget(String title, bool isRequired) {
    return Text.rich(TextSpan(
        text: title,
        style: GMCommonWidget.grey12TextStyle,
        children: isRequired
            ? <TextSpan>[
                TextSpan(
                    text: "(必填)", style: GMCommonWidget.blackRed12TextStyle)
              ]
            : null));
  }
}

enum NewGoalInputType {
  INPUT_TYPE_TITLE,
  INPUT_TYPE_DATE,
  INPUT_TYPE_INDICATOR,
  INPUT_TYPE_GOAL_VALUE,
  INPUT_TYPE_STAFFS
}

typedef IndicatorConfirmed = void Function(Indicator indicator);
typedef StaffsConfirmed = void Function(List<Staff> staffs);

class StaffSelectorBottomSheet extends StatefulWidget {
  final List<Staff> staffs;
  final StaffsConfirmed staffsConfirmed;
  StaffSelectorBottomSheet({this.staffs, this.staffsConfirmed}) {}
  @override
  _StaffSelectorBottomSheetState createState() =>
      _StaffSelectorBottomSheetState();
}

class _StaffSelectorBottomSheetState extends State<StaffSelectorBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3 * 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 14, top: 10),
            child: Text("员工", style: GMCommonWidget.black17TextStyle),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: _buildContent(),
            ),
          ),
          _buildConfirmButton()
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xFF4D759C),
      child: SafeArea(
        child: FlatButton(
          child: Text(
            "完成",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            if (widget.staffsConfirmed != null) {
              List<Staff> staff = List();
              widget.staffs.forEach((selectStaff) {
                if (selectStaff.selected) {
                  staff.add(selectStaff);
                }
              });
              widget.staffsConfirmed(staff);
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, //每行2个
          mainAxisSpacing: 10.0, //主轴(竖直)方向间距
          crossAxisSpacing: 10.0, //纵轴(水平)方向间距
          childAspectRatio: 4 //纵轴缩放比例
          ),
      shrinkWrap: true,
      itemCount: widget.staffs?.length ?? 0,
      itemBuilder: (context, index) {
        var staff = widget.staffs[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              staff.selected = !(staff.selected ?? false);
            });
          },
          child: Container(
            decoration: BoxDecoration(
                border:
                    new Border.all(color: ColorRes.primeryColor, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: (staff.selected ?? false)
                    ? ColorRes.primeryColor
                    : Colors.white),
            child: Center(
              child: Text(
                staff.name,
                style: (staff.selected ?? false)
                    ? GMCommonWidget.whiteTextStyle
                    : GMCommonWidget.greyTextStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class IndicatorSelectorBottomSheet extends StatefulWidget {
  final List<IndicatorClass> indicatorClazz;
  final IndicatorConfirmed indicatorConfirmed;
  IndicatorSelectorBottomSheet(
      {Key key, this.indicatorClazz, this.indicatorConfirmed})
      : super(key: key) {}

  @override
  _IndicatorSelectorBottomSheetState createState() =>
      _IndicatorSelectorBottomSheetState();
}

class _IndicatorSelectorBottomSheetState
    extends State<IndicatorSelectorBottomSheet> {
  var selectItem = 0;
  Map<int, Widget> segChildren;
  int sharedValue = 0;

  @override
  void initState() {
    super.initState();
    segChildren = Map();
    widget.indicatorClazz.asMap().forEach((index, indicatorClass) {
      L.p("index$index indicatorClass${indicatorClass.name}");
      indicatorClass.indicators.asMap().forEach((index, indicator) {
        L.p("index$index indicator${indicator.name}");
      });
      segChildren[index] = Text(indicatorClass.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 14, top: 10),
            child: Text("指标", style: GMCommonWidget.black17TextStyle),
          ),
          _buildSegmentedControl(),
          _buildListSelectView(),
          _buildConfirmButton()
        ],
      ),
    );
  }

  Widget _buildListSelectView() {
    var indicators = widget.indicatorClazz[sharedValue].indicators;

    return Expanded(
      child: ListView.builder(
        itemCount: indicators.length,
        itemBuilder: (context, index) {
          var indicator = indicators[index];
          Widget column = GestureDetector(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(left: 14, top: 5, bottom: 5, right: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(indicator.name,
                            style:
                                TextStyle(color: Colors.black, fontSize: 17)),
                        selectItem == index
                            ? GMCommonWidget.customIconWithGest(Icons.check,
                                size: 18)
                            : Container()
                      ],
                    ),
                  ),
                  Divider(
                    color: ColorRes.lineGrey,
                    height: 0.5,
                  )
                ],
              ),
            ),
            onTap: () {
              setState(() {
                selectItem = index;
                L.p("selectItem:$selectItem");
              });
            },
          );
          return column;
        },
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 9,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: CupertinoSegmentedControl<int>(
              selectedColor: Color(0xFF4D759C),
              borderColor: Color(0xFF4D759C),
              pressedColor: Color(0xFF4D759C),
              children: segChildren,
              onValueChanged: (int newValue) {
                setState(() {
                  sharedValue = newValue;
                  selectItem = 0;
                });
              },
              groupValue: sharedValue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xFF4D759C),
      child: FlatButton(
        child: Text(
          "完成",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          if (widget.indicatorConfirmed != null) {
            widget.indicatorConfirmed(
                widget.indicatorClazz[sharedValue].indicators[selectItem]);
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// 只允许输入小数
class NumScale2TextInputFormatter extends TextInputFormatter {
  final bool usePercent;
  NumScale2TextInputFormatter(this.usePercent) {}
  static const defaultDouble = 0.001;
  static double strToFloat(String str, [double defaultValue = defaultDouble]) {
    try {
      return double.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;
    if (value.contains("%")) {
      value = value.replaceAll("%", "");
    }
    //如果是百分比且是有点的处理为旧的数值  否则走数值类型
    if (usePercent && value.contains(".")) {
      value = oldValue.text;
      selectionIndex = oldValue.selection.end;
    } else {
      if (value == ".") {
        value = "0.";
        selectionIndex++;
      } else if (value != "" &&
          value != defaultDouble.toString() &&
          strToFloat(value, defaultDouble) == defaultDouble) {
        value = oldValue.text;
        selectionIndex = oldValue.selection.end;
      }
    }
    if (usePercent) {
      value = "$value%";
    } else {
      //数值小数点后面不能大于两位数
      int lastIndex = value.lastIndexOf(".");
      if (lastIndex != -1) {
        var temp = value.substring(lastIndex + 1);
        if (temp.length > 2) {
          value = oldValue.text;
          selectionIndex = oldValue.selection.end;
        }
      }
    }
    return new TextEditingValue(
      text: value,
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
