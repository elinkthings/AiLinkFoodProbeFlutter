import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/utils/elink_probe_base_cmd_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_box_base_cmd_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';

/// 探针盒子命令工具类(Probe box command tool class)
class ElinkProbeBoxCmdUtils extends ElinkProbeBoxBaseCmdUtils {
  static ElinkProbeBoxCmdUtils? _instance;

  ElinkProbeBoxCmdUtils._() {
    _instance = this;
  }

  factory ElinkProbeBoxCmdUtils(
    List<int> mac, {
    List<int> cid = ElinkProbeConfig.cidProbeBox,
  }) {
    _instance ??= ElinkProbeBoxCmdUtils._();
    _instance!.initialize(mac, cid: cid);
    return _instance!;
  }

  /// 获取盒子信息
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> getBoxDeviceInfo() {
    final payload = List.filled(2, 0x01);
    return getElinkA7Data(payload);
  }

  /// 盒子获取探针信息
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> getBoxProbeInfo(List<int> probeMac) {
    final payload = List.filled(8, 0x00);
    payload[0] = 0x03;
    payload[1] = 0x02;
    payload.setAll(2, probeMac);
    return getElinkA7Data(payload);
  }

  /// 盒子清除探针信息
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> clearBoxProbeInfo(List<int> probeMac) {
    final payload = List.filled(8, 0x00);
    payload[0] = 0x03;
    payload.setAll(2, probeMac);
    return getElinkA7Data(payload);
  }

  /// 盒子设置探针信息
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> setBoxProbeInfo(ElinkProbeInfo probeInfo) {
    final payload = List.filled(136, 0x00);
    int index = 0;
    payload[index++] = 0x03;
    payload[index++] = 0x01;
    payload.setAll(index, probeInfo.mac);
    index += probeInfo.mac.length;
    payload[index++] = 0x02;
    final id = ElinkCmdUtils.intToBytes(probeInfo.id ~/ 1000);
    payload.setAll(index, id);
    index += id.length;
    payload[index++] = probeInfo.foodType;
    payload[index++] = probeInfo.foodRawness;
    final targetTempCelsius = ElinkCmdUtils.intToBytes(probeInfo.targetTempCelsius.abs(), length: 2);
    if (probeInfo.targetTempCelsius >= 0) {
      payload[index++] = targetTempCelsius[0];
    } else {
      payload[index++] = targetTempCelsius[0] | 0x80;
    }
    payload[index++] = targetTempCelsius[1];
    final targetTempFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.targetTempFahrenheit.abs(), length: 2);
    if (probeInfo.targetTempFahrenheit >= 0) {
      payload[index++] = targetTempFahrenheit[0];
    } else {
      payload[index++] = targetTempFahrenheit[0] | 0x80;
    }
    payload[index++] = targetTempFahrenheit[1];
    final lowerTempLimitCelsius = ElinkCmdUtils.intToBytes(probeInfo.lowerTempLimitCelsius.abs(), length: 2);
    if (probeInfo.lowerTempLimitCelsius >= 0) {
      payload[index++] = lowerTempLimitCelsius[0];
    } else {
      payload[index++] = lowerTempLimitCelsius[0] | 0x80;
    }
    payload[index++] = lowerTempLimitCelsius[1];
    final lowerTempLimitFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.lowerTempLimitFahrenheit.abs(), length: 2);
    if (probeInfo.lowerTempLimitFahrenheit >= 0) {
      payload[index++] = lowerTempLimitFahrenheit[0];
    } else {
      payload[index++] = lowerTempLimitFahrenheit[0] | 0x80;
    }
    payload[index++] = lowerTempLimitFahrenheit[1];
    final upperTempLimitCelsius = ElinkCmdUtils.intToBytes(probeInfo.upperTempLimitCelsius.abs(), length: 2);
    if (probeInfo.upperTempLimitCelsius >= 0) {
      payload[index++] = upperTempLimitCelsius[0];
    } else {
      payload[index++] = upperTempLimitCelsius[0] | 0x80;
    }
    payload[index++] = upperTempLimitCelsius[1];
    final upperTempLimitFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.upperTempLimitFahrenheit.abs(), length: 2);
    if (probeInfo.upperTempLimitFahrenheit >= 0) {
      payload[index++] = upperTempLimitFahrenheit[0];
    } else {
      payload[index++] = upperTempLimitFahrenheit[0] | 0x80;
    }
    payload[index++] = upperTempLimitFahrenheit[1];
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
    final alarmTempCelsius = ElinkCmdUtils.intToBytes(probeInfo.alarmTempC.abs(), length: 2);
    if (probeInfo.alarmTempC >= 0) {
      payload[index++] = alarmTempCelsius[0];
    } else {
      payload[index++] = alarmTempCelsius[0] | 0x80;
    }
    payload[index++] = alarmTempCelsius[1];
    final alarmTempFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.alarmTempF.abs(), length: 2);
    if (probeInfo.alarmTempF >= 0) {
      payload[index++] = alarmTempFahrenheit[0];
    } else {
      payload[index++] = alarmTempFahrenheit[0] | 0x80;
    }
    payload[index++] = alarmTempFahrenheit[1];
    return getElinkA7Data(payload);
  }

  /// 盒子设置报警
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> setAmbientAlarm(List<int> probeMac, {
    bool? isTimerExpired = true,
    bool? isHighAmbientTemp = true,
    bool? isTargetTempReached = true,
  }) {
    final payload = List.filled(8, 0x00);
    payload[0] = 0x05;
    payload.insertAll(1, probeMac);
    final alarmState = ((isTimerExpired == true ? 0x01 : 0x00) | ((isHighAmbientTemp == true ? 0x01 : 0x00) << 1) | ((isTargetTempReached == true ? 0x01 : 0x00) << 2)) & 0xFF;
    payload[7] = alarmState;
    return getElinkA7Data(payload);
  }
}
