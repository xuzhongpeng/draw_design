import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// import 'package:scoped_model/scoped_model.dart';
import 'package:gm_uikit/gm_uikit.dart';
import 'package:gm_platform_channels/gm_platform_channels.dart';

// import 'package:staff_performance/model/top_model.dart';
// import 'package:staff_performance/model/dataSource_model.dart';
import 'package:staff_performance/model/entities/tab_entity.dart';
import 'package:staff_performance/pages/setting_performance.dart';
import 'package:staff_performance/pages/shop_performance.dart';
import 'package:staff_performance/utils/center_util.dart';
import 'package:staff_performance/stores/index.dart';

class PerformanceMain extends StatefulWidget {
  @override
  _PerformanceMainState createState() => _PerformanceMainState();
}

//存储页面的信息
class PageInfo {
  final String tableTites;
  final String tabImagesH;
  final String tabImagesN;
  final Widget pages;
  PageInfo(this.tableTites, this.tabImagesH, this.tabImagesN, this.pages);
}

class _PerformanceMainState extends State<PerformanceMain>
    with TickerProviderStateMixin {
  void registerService() {
    ChannelUtil.registerMethodCallHandler((MethodCall call) async {
      if (call.method == "pushReplace") {
        Navigator.pushReplacementNamed(context, call.arguments['routeName']);
      } else if (call.method == 'setState') {
        setState(() {});
      }
    });
  }

  List<TabEntity> _tabs = new List();
  List<PageInfo> _pagesInfo = new List();

  List<Widget> _pages = new List();

  PageController _pageController;
  bool isSingle = CenterUtils().isSingle;
  // TopModel get _topModel => TopModel.of(context);
  ShopDataModel get _model =>
      Store.value<ShopDataModel>(context, listen: false);
  StaffDataModel get _staffModel =>
      Store.value<StaffDataModel>(context, listen: false);
  @override
  void initState() {
    super.initState();
    registerService();
    initData();
  }

  void initData() async {
    await CenterUtils().initialCenterConfig(context: context);
    //设置三个页面的信息
    PageInfo shop = PageInfo('店铺', 'tab_store_h.png', "tab_store_n.png",
        ShopPerformance.withData(_model, type: TableType('shop', '店铺')));
    PageInfo staff = PageInfo('员工', "tab_staff_h.png", "tab_staff_n.png",
        ShopPerformance.withData(_staffModel, type: TableType('staff', '员工')));
    PageInfo settings = PageInfo(
        '设置', "tab_settings_h.png", "tab_settings_n.png", SettingPerformance());
    if (CenterUtils().isManager) _pagesInfo.add(shop);
    _pagesInfo.add(staff);
    _pagesInfo.add(settings);

    // _indexPage = 0;
    _tabs = List.generate(_pagesInfo.length, (index) {
      return TabEntity(
          title: _pagesInfo[index].tableTites,
          highImage: Image.asset(
            'lib/assets/tab/${_pagesInfo[index].tabImagesH}',
            scale: 3.0,
            package: CenterUtils.getImagePackage(),
          ),
          normalImage: Image.asset(
            'lib/assets/tab/${_pagesInfo[index].tabImagesN}',
            scale: 3.0,
            package: CenterUtils.getImagePackage(),
          ));
    });
    _pages = _pagesInfo.map((item) => item.pages).toList();
    _pageController = PageController(initialPage: CenterUtils.pageIndex);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _pages.length > 0
        ? Scaffold(
            appBar: GMAppBar(
              title: '业绩',
              leading: GMCommonWidget.barButton(Icons.arrow_back_ios,
                  color: Colors.white, callBack: _centerBack),
            ),
            body: PageView(
              physics: NeverScrollableScrollPhysics(),
              children: _pages,
              controller: _pageController,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: _buildTabs(_tabs),
              currentIndex: CenterUtils.pageIndex,
              selectedFontSize: 13,
              unselectedFontSize: 13,
              unselectedItemColor: Color.fromRGBO(77, 117, 156, 0.6),
              onTap: (index) {
                setState(() {
                  CenterUtils.pageIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
            ),
          )
        : Scaffold(
            body: GMLoadingWidget().GMLoading(
            show: true,
            color: Color.fromRGBO(1, 1, 1, 0.0),
            child: Container(),
          ));
  }

  void _centerBack() {
    ChannelUtil.invokeBack();
  }
}

List<BottomNavigationBarItem> _buildTabs(List<TabEntity> tabs) {
  return tabs.map((tab) {
    return BottomNavigationBarItem(
        title: Text(tab.title),
        activeIcon: tab.highImage,
        icon: tab.normalImage);
  }).toList();
}
