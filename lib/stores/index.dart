/*
 * @Author: xuzhongpeng
 * @email: xuzhongpeng@foxmail.com
 * @Date: 2019-08-15 16:25:01
 * @LastEditors: xuzhongpeng
 * @LastEditTime: 2019-08-16 10:14:12
 * @Description: Store封装
 */
import 'package:provider/provider.dart'
    show ChangeNotifierProvider, MultiProvider, Consumer, Provider;
import './top_model.dart';
import 'package:staff_performance/config/dio.dart';
import './module/index.dart';
export './module/index.dart';

class Store {
  static init({context, child}) {
    StaffDio().init();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => TopModel()),
        ChangeNotifierProvider(builder: (_) => ShopDataModel()),
        ChangeNotifierProvider(builder: (_) => StaffDataModel()),
        ChangeNotifierProvider(builder: (_) => DetailModel()),
        ChangeNotifierProvider(builder: (_) => SettingModel())
      ],
      child: child,
    );
  }

  //  通过Provider.value<T>(context)获取状态数据
  static T value<T>(context, {listen: true}) {
    return Provider.of<T>(context, listen: listen);
  }

  /// 通过Consumer获取状态数据
  static Consumer connect<T>({builder, child}) {
    return Consumer<T>(builder: builder, child: child);
  }
}
