/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-13 17:58:12
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-08-21 10:00:48
 * 配置页面所有请求
 */

import './dio.dart';

class Services {
  static var _dio = StaffDio().dio;

  ///获取统计数据
  static Future requestSellList(param) =>
      _dio.post('/api/sells/list', data: param);

  ///首页统计数据
  static Future requestSell(param) => _dio.post('/api/sells', data: param);

  ///获取业绩目标详情
  static Future requestSelltargetList({param}) =>
      _dio.post('/api/selltarget/list', data: param);

  ///创建业绩目标详情
  static Future requestSelltargets(param) =>
      _dio.post('/api/selltargets', data: param);

  ///根据员工获取业绩目标详情
  static Future requestSellTargetByStaff(id, data) =>
      _dio.get('/api/selltargets/${id}', queryParameters: data);

  ///获取指标分组
  static Future requestSellitemGroup() => _dio.get('/api/sellitemgroups');

  ///获取员工列表
  static Future requestGetStaff() => _dio.get('/api/staffs');

  ///配置业绩指标
  static Future requestSellItems(data) =>
      _dio.put('/api/sellitems', data: data);
}
