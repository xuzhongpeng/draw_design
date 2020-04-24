import 'package:flutter/foundation.dart';
import 'package:gm_networking/gm_networking.dart';

import 'package:gm_platform_channels/gm_platform_channels.dart';
import 'package:gm_uikit/gm_uikit.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:staff_performance/model/detail_model.dart';
import 'package:staff_performance/model/peformance_data_manager.dart';
import 'package:staff_performance/model/setting_model.dart';
import 'package:staff_performance/utils/log.dart';
import 'package:staff_performance/model/entities/performance_entity.dart';
import 'entities/performance_entity.dart';
import 'entities/sell_group_entity.dart';
import 'package:staff_performance/model/dataSource_model.dart';

class TopModel extends Model {
  //userdata
  int userId;
  int entranceUser = 0; //账号管理入口权限
  int companyId = 0; //公司id,由原生传入 329
  bool isAdmin = false; //是否是法人
  bool isManager = false; //是否是管理员或者合伙人

  DioWrapper dio;
  SettingModel settingModel;
  DetailModel detailModel; //详情页的model
  PeformanceRequestManager get _peformanceRM =>
      PeformanceRequestManager(dio: dio);

  static TopModel of(context) => ScopedModel.of<TopModel>(context);

  ///成员变量
  ///shop_performance
  //缓存查询出来的所有有效数据（由它解析成其它数据）
  List<Map<String, List<PerformanceEntity>>> performances;

  TopModel() {
    dio = DioWrapper();
    dio.contentType = 'application/json';
    if (!kReleaseMode) {
      dio.extraParam = {'debug': 1};
    }
    dio.interceptorError = (error) {
      L.p("dio error:$error");
      GMLoadingWidget().dismiss();
      DioError err = error;
      if (err.response?.statusCode != null && err.response.statusCode == 401) {
        ChannelUtil.invokeCommonChannel('invalidToken');
        L.printMap({'userId': "userId", 'token': dio.authorization});
        return false;
      }
      return true;
    };
    dio.interceptorSuccess = (options) {
      L.p("dio options:$options");
      GMLoadingWidget().dismiss();
      return true;
    };
  }

  void setRequestToken(String token) {
    dio.authorization = token;
  }

  void setRequestBaseUrl(String baseUrl) {
    dio.baseUrl = baseUrl;
  }

  SettingModel getSettingModel() {
    if (settingModel == null) {
      settingModel = SettingModel(dio);
    }
    return settingModel;
  }

  DetailModel getDetailModel() {
    if (detailModel == null) {
      detailModel = DetailModel(dio);
    }
    return detailModel;
  }

  ///拿所有数据的接口
  // Future<List<PerformanceEntity>> requestPeformanceData(
  //     Map<String, dynamic> param) async {
  //   Map result = await _peformanceRM.requestPeformanceData(param);
  //   sellGroupEntitys = result['sellGroupEntitys'];
  //   return result['entitys'];
  // }
}
