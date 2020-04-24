import 'package:gm_networking/gm_networking.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:staff_performance/model/entities/sell_item_group_entity.dart';

import 'entities/goal_entity.dart';

class DetailModel extends Model {
  DioWrapper _dio;
  // List<GoalEntity> goalList = <GoalEntity>[];
  DetailModel(this._dio);

  //页面数据的配置
  Map<String, dynamic> showName = {
    "customers": "客户相关",
    "customer_deal_count": "成交客户数",
    "customer_deal_percent": "成交率",
    "items": "商品相关",
    "sku_sale_percent": "SKU动销率",
    "item_sale_percent": "货号动销率",
    "payments": "流水相关",
    "abs_payment_fee": "净流水金额",
    "payment_fee": "正流水金额",
    "minus_payment_fee": "负流水金额",
    "payment_count": "正流水笔数",
    "minus_payment_count": "负流水笔数",
    "avg_payment_value": "流水客单价",
    "sales": "销售相关",
    "salesorder_due_fee": "营业额",
    "salesorder_fee": "销售金额",
    "salesorder_return_fee": "退货金额",
    "return_percent": "退销比",
    "abs_salesorder_quantity": "净销售件数",
    "salesorder_quantity": "销售件数",
    "return_quantity": "退货件数",
    "salesorder_count": "销售笔数",
    "return_count": "退货笔数",
    "unit_price": "交易客单价",
    "band_rate": "连带率",
  };
//重写of方法
  static DetailModel of(context) => ScopedModel.of<DetailModel>(context);

  Future<Map<String, dynamic>> getData(Map<String, String> data) async {
    final response = await _dio.post('/api/sells', data: data);
    Map<String, dynamic> reslut =
        Map.from(response.data['result'].values.first);
    return reslut;
  }

  Future<List<GoalEntity>> getTargetData(Map<String, String> data) async {
    final response = await _dio.post('/api/selltarget/list', data: data);
    if (response.data['code'] == 0) {
      List<SellTargetsEntity> sellTargetsList =
          (response.data['result']['data'] as List)
              .map((item) => SellTargetsEntity.fromJson(item))
              .toList();
      List<GoalEntity> goalList = GoalEntity.getGoalEntity(sellTargetsList);
      return goalList;
    }
    return [];
  }
}
