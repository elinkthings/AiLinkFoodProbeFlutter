import 'package:ailink_food_probe/utils/elink_probe_config.dart';

/// 探针实时数据(Probe real-time data)
class ElinkProbeRealTimeInfo {
  /// 探针编号
  final int id;

  /// 实时温度单位 0->℃ 1->℉
  final int realTimeUnit;

  /// 实时温度正负值 0->温度为正 1->温度为负
  final int realTimePositive;

  /// 实时温度值
  final int realTimeTemp;

  /// 环境温度单位 0->℃ 1->℉
  final int ambientUnit;

  /// 环境温度正负值 0->温度为正 1->温度为负
  final int ambientPositive;

  /// 环境温度值
  final int ambientTemp;

  /// 目标温度单位 0->℃ 1->℉
  final int targetUnit;

  /// 目标温度正负值 0->温度为正 1->温度为负
  final int targetPositive;

  /// 目标温度值
  final int targetTemp;

  /// 探针状态 0->未插入 1->已插入 3->设备无该功能
  final int probeState;

  ElinkProbeRealTimeInfo(
    this.id,
    this.realTimeUnit,
    this.realTimePositive,
    this.realTimeTemp,
    this.ambientUnit,
    this.ambientPositive,
    this.ambientTemp,
    this.targetUnit,
    this.targetPositive,
    this.targetTemp,
    this.probeState,
  );


  @override
  String toString() {
    return 'ElinkProbeRealTimeInfo{id: $id, realTimeUnit: $realTimeUnit, realTimePositive: $realTimePositive, realTimeTemp: $realTimeTemp, ambientUnit: $ambientUnit, ambientPositive: $ambientPositive, ambientTemp: $ambientTemp, targetUnit: $targetUnit, targetPositive: $targetPositive, targetTemp: $targetTemp, probeState: $probeState}';
  }

  String toFormatString() {
    return 'ElinkProbeRealTimeModel{id: $id, '
        'realTimeTemp: $realTimeTempStr, '
        'ambientTemp: $ambientTempStr, '
        'targetTemp: $targetTempStr, '
        'probeState: ${ElinkProbeState.values[probeState].name}}';
  }

  String get realTimeTempStr => '${realTimePositive == 0 ? '' : '-'}$realTimeTemp${ElinkTemperatureUnit.values[realTimeUnit].name}';
  String get ambientTempStr => '${ambientPositive == 0 ? '' : '-'}$ambientTemp${ElinkTemperatureUnit.values[ambientUnit].name}';
  String get targetTempStr => '${targetPositive == 0 || isTargetTempUnSupport ? '' : '-'}${isTargetTempUnSupport ? 'unSupport' : targetTemp}${isTargetTempUnSupport ? '' : ElinkTemperatureUnit.values[targetUnit].name}';

  bool get isTargetTempUnSupport => targetTemp == 0xFFFF;
}
