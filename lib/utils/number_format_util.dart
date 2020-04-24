class NumberFormatUtil{
  static double strToDou(String str){
    try {
      return double.parse(str);
    } catch (e) {
    }
    return 0.00;
  }

  static String strToDouStrAsFixed2(String str){
    try {
      return double.parse(str).toStringAsFixed(2);
    } catch (e) {
    }
    return 0.00.toString();
  }

  static int strToInt(String str){
    try {
      return int.parse(str);
    } catch (e) {
    }
    return 0;
  }

  static int dynamicToInt(dynamic num,{int defaultValue}){
    if (num is int) {
      return num;
    }else if (num is String) {
      return NumberFormatUtil.strToInt(num);
    }else{
      return defaultValue?? 0;
    }
  }

  static String dynamicToString(dynamic str, {String defaultValue}){
    if (str is int) {
      return str.toString();
    }else if (str is String) {
      return str;
    }else{
      return defaultValue?? "";
    }
  }



}