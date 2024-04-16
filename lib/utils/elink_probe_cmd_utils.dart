import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/utils/elink_probe_base_cmd_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';

/// 探针命令工具类(Probe command tool class)
class ElinkProbeCmdUtils extends ElinkProbeBaseCmdUtils {

  static ElinkProbeCmdUtils? _instance;

  ElinkProbeCmdUtils._() {
    _instance = this;
  }

  factory ElinkProbeCmdUtils(
    List<int> mac, {
    List<int> cid = ElinkProbeConfig.cidProbe,
  }) {
    _instance ??= ElinkProbeCmdUtils._();
    _instance!.initialize(mac, cid: cid);
    return _instance!;
  }

  /// 获取电量
  /// 使用UUID(elinkWriteAndNotifyUuid: FFE3)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteAndNotifyUuid: FFE3)
  List<int> getBattery() {
    final payload = [0x28];
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /// 获取设备信息
  /// 使用UUID(elinkWriteAndNotifyUuid: FFE3)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteAndNotifyUuid: FFE3)
  List<int> getProbeInfo() {
    final payload = List.filled(2, 0x01);
    payload[0] = 0x36;
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /// 开始工作(设置信息)
  /// 使用UUID(elinkWriteAndNotifyUuid: FFE3)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteAndNotifyUuid: FFE3)
  List<int> setProbeInfo(ElinkProbeInfo probeInfo) {
    final payload = List.filled(128, 0x00);
    payload[0] = 0x35;
    int index = 1;
    payload[index++] = 0x01;
    payload[index++] = 0x01;
    final id = ElinkCmdUtils.intToBytes(probeInfo.id ~/ 1000);
    payload.setAll(index, id);
    index += id.length;
    payload[index++] = probeInfo.foodType;
    payload[index++] = probeInfo.foodRawness;
    final targetTempCelsius = ElinkCmdUtils.intToBytes(probeInfo.targetTempCelsius, length: 2);
    payload.setAll(index, targetTempCelsius);
    index += targetTempCelsius.length;
    final targetTempFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.targetTempFahrenheit, length: 2);
    payload.setAll(index, targetTempFahrenheit);
    index += targetTempFahrenheit.length;
    final lowerTempLimitCelsius = ElinkCmdUtils.intToBytes(probeInfo.lowerTempLimitCelsius, length: 2);
    payload.setAll(index, lowerTempLimitCelsius);
    index += lowerTempLimitCelsius.length;
    final lowerTempLimitFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.lowerTempLimitFahrenheit, length: 2);
    payload.setAll(index, lowerTempLimitFahrenheit);
    index += lowerTempLimitFahrenheit.length;
    final upperTempLimitCelsius = ElinkCmdUtils.intToBytes(probeInfo.upperTempLimitCelsius, length: 2);
    payload.setAll(index, upperTempLimitCelsius);
    index += upperTempLimitCelsius.length;
    final upperTempLimitFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.upperTempLimitFahrenheit, length: 2);
    payload.setAll(index, upperTempLimitFahrenheit);
    index += upperTempLimitFahrenheit.length;
    final alarmTempPercent = ElinkCmdUtils.doubleToBytes(probeInfo.alarmTempPercent ?? 0.8);
    payload.setAll(index, alarmTempPercent);
    index += alarmTempPercent.length;
    final timerStart = ElinkCmdUtils.intToBytes((probeInfo.timerStart ?? 0) ~/ 1000);
    payload.setAll(index, timerStart);
    index += timerStart.length;
    final timerEnd = ElinkCmdUtils.intToBytes((probeInfo.timerEnd ?? 0) ~/ 1000);
    payload.setAll(index, timerEnd);
    index += timerEnd.length;
    payload[index++] = probeInfo.currentUnit;
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /// 结束工作
  /// 使用UUID(elinkWriteAndNotifyUuid: FFE3)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteAndNotifyUuid: FFE3)
  List<int> clearProbeInfo() {
    final payload = List.filled(2, 0x00);
    payload[0] = 0x35;
    return ElinkCmdUtils.getElinkA6Data(payload);
  }
}
