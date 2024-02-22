import 'package:ailink/utils/elink_broadcast_data_utils.dart';

/// 探针数据(Probe data)
class ElinkProbeInfo {
  /// 探针mac
  List<int> mac = List.filled(5, 0x00);

  /// 探针id
  int id = -1;

  /// 食物类型
  int foodType = -1;

  /// 食物烤熟成都
  int foodRawness = -1;

  /// 目标温度(°C)
  int targetTempCelsius = 0;

  /// 目标温度(°F)
  int targetTempFahrenheit = 0;

  /// 下限温度(°C)
  int lowerTempLimitCelsius = 0;

  /// 下限温度(°F)
  int lowerTempLimitFahrenheit = 0;

  /// 上限温度(°C)
  int upperTempLimitCelsius = 0;

  /// 上限温度(°F)
  int upperTempLimitFahrenheit = 0;

  /// 提醒温度对目标温度百分比0.8~1 如果获取到的小于0.8则等于0.8，大于1则等于1
  double? alarmTempPercent = 0.95;

  /// 定时开始时间
  int? timerStart = 0;

  /// 定时结束时间
  int? timerEnd = 0;

  /// 当前温度单位
  int currentUnit = 0;

  /// 报警温度(°C)
  int? alarmTempCelsius = 0;

  /// 报警温度(°F)
  int? alarmTempFahrenheit = 0;

  ElinkProbeInfo({
    required this.mac,
    required this.id,
    required this.foodType,
    required this.foodRawness,
    required this.targetTempCelsius,
    required this.targetTempFahrenheit,
    required this.lowerTempLimitCelsius,
    required this.lowerTempLimitFahrenheit,
    required this.upperTempLimitCelsius,
    required this.upperTempLimitFahrenheit,
    this.alarmTempPercent,
    this.timerStart,
    this.timerEnd,
    required this.currentUnit,
    this.alarmTempCelsius,
    this.alarmTempFahrenheit,
  });

  @override
  String toString() {
    return 'ElinkSetProbeInfoModel{mac: ${ElinkBroadcastDataUtils.littleBytes2MacStr(mac)}, id: $id, foodType: $foodType, foodRawness: $foodRawness, targetTempCelsius: $targetTempCelsius, targetTempFahrenheit: $targetTempFahrenheit, lowerTempLimitCelsius: $lowerTempLimitCelsius, lowerTempLimitFahrenheit: $lowerTempLimitFahrenheit, upperTempLimitCelsius: $upperTempLimitCelsius, upperTempLimitFahrenheit: $upperTempLimitFahrenheit, alarmTempPercent: $alarmTempPercent, timerStart: $timerStart, timerEnd: $timerEnd, currentUnit: $currentUnit, alarmTempCelsius: $alarmTempCelsius, alarmTempFahrenheit: $alarmTempFahrenheit}';
  }

  int get alarmTempC => alarmTempCelsius ?? 0;

  int get alarmTempF => alarmTempFahrenheit ?? 0;
}
