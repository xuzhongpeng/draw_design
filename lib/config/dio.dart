/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-13 17:46:48
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-09-19 15:18:22
 * @Description: 配置dio
 */
import 'package:flutter/foundation.dart';

import 'package:gm_networking/gm_networking.dart';

import 'package:gm_platform_channels/gm_platform_channels.dart';
import 'package:gm_uikit/gm_uikit.dart';
import 'package:staff_performance/utils/log.dart';
export 'package:gm_networking/gm_networking.dart';

final codeMessage = {
  '200': '服务器成功返回请求的数据',
  '201': '新建或修改数据成功。',
  '202': '一个请求已经进入后台排队（异步任务）',
  '204': '删除数据成功。',
  '400': '发出的请求有错误，服务器没有进行新建或修改数据,的操作。',
  '401': 'token已失效, 请重新登录',
  '403': '用户得到授权，但是访问是被禁止的。',
  '404': '请求不存在，请联系技术支持.',
  '406': '请求的格式不可得。',
  '410': '请求的资源被永久删除，且不会再得到的。',
  '500': '服务器发生错误，请检查服务器',
  '502': '网关错误',
  '503': '服务不可用，服务器暂时过载或维护',
  '504': '网关超时',
  '600': '网络不可用，请检查网络设置'
};

class StaffDio {
  //单例模式
  factory StaffDio() => _instance;
  static final _instance = StaffDio._singleTon();
  StaffDio._singleTon();

  DioWrapper dio;
  init() {
    dio = DioWrapper();
    dio.contentType = 'application/json';
    if (!kReleaseMode) {
      dio.extraParam = {'debug': 1};
    }
    dio.interceptorError = (error) {
      L.p("dio error:$error");
      L.p(error.response?.statusCode.toString());
      GMLoadingWidget().dismiss();
      DioError err = error;
      if (err.response?.statusCode != null && err.response.statusCode == 401) {
        ChannelUtil.invokeCommonChannel('invalidToken');
        L.printMap({'userId': "userId", 'token': dio.authorization});
        return false;
      } else if (err.response?.statusCode != null &&
          err.response.statusCode != 200) {
        GmToast.showToast(codeMessage[err.response.statusCode.toString()]);
      }
      return true;
    };
    dio.interceptorSuccess = (options) {
      L.p("dio options:$options");
      GMLoadingWidget().dismiss();
      if (options.data['code'] == 0) {
        return options;
      } else {
        GmToast.showToast(options.data['message']);
        return Dio().reject(options);
      }
    };
  }

  void setRequestToken(String token) {
    dio.authorization = token;
  }

  void setRequestBaseUrl(String baseUrl) {
    dio.baseUrl = baseUrl;
  }
}
