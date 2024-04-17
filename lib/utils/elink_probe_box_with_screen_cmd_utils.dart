import 'dart:convert';

import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/utils/elink_probe_box_base_cmd_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';

class ElinkProbeBoxWithScreenCmdUtils extends ElinkProbeBoxBaseCmdUtils {
  static ElinkProbeBoxWithScreenCmdUtils? _instance;

  ElinkProbeBoxWithScreenCmdUtils._() {
    _instance = this;
  }

  factory ElinkProbeBoxWithScreenCmdUtils(
    List<int> mac, {
    List<int> cid = ElinkProbeConfig.cidProbeBoxWithScreen,
  }) {
    _instance ??= ElinkProbeBoxWithScreenCmdUtils._();
    _instance!.initialize(mac, cid: cid);
    return _instance!;
  }

  /// 切换单位
  /// unit 0: °C, 1: °F
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  @override
  Future<List<int>> switchUnit(int unit) {
    if (getMac() == null) return Future.value([]);
    final payload = [0x03, unit];
    return getElinkA7Data(payload);
  }

  /// 盒子设置报警
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> setAmbientAlarm(List<int> probeMac) {
    final payload = List.filled(8, 0x00);
    payload[0] = 0x05;
    payload.insertAll(1, probeMac);
    payload[7] = 0x01;
    return getElinkA7Data(payload);
  }

  Future<List<int>> getProbeInfo() {
    final payload = List.filled(2, 0x01);
    payload[0] = 0x09;
    return getElinkA7Data(payload);
  }

  /// 盒子清除探针信息
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> clearBoxProbeInfo(List<int> probeMac) {
    final payload = List.filled(72, 0x00);
    payload[0] = 0x09;
    payload[2] = 0x01; //支持的探针数量 目前固定为1
    payload.setAll(3, probeMac);
    payload[9] = 0x00; //任务状态 0x00-未开始 0x01-已开始
    payload[10] = 0xFF;
    final alarmTempPercent = ElinkProbeConfig.doubleTo4Bytes(0.95);
    payload.setAll(35, alarmTempPercent);
    payload[39] = 0xFF;
    return getElinkA7Data(payload);
  }

  /// 盒子设置探针信息
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> setBoxProbeInfo(ElinkProbeInfo probeInfo) {
    final payload = List.filled(72, 0x00);
    int index = 0;
    payload[index++] = 0x09;
    payload[index++] = 0x00;
    payload[index++] = 0x01; //支持的探针数量 目前固定为1
    payload.setAll(index, probeInfo.mac);
    index += probeInfo.mac.length;
    payload[index++] = 0x01; //任务状态 0x00-未开始 0x01-已开始
    payload[index++] = probeInfo.foodType;
    final targetTempCelsius = ElinkCmdUtils.intToBytes(probeInfo.targetTempCelsius, length: 2, littleEndian: false);
    payload.setAll(index, targetTempCelsius.reversed);
    index += targetTempCelsius.length;
    final targetTempFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.targetTempFahrenheit, length: 2, littleEndian: false);
    payload.setAll(index, targetTempFahrenheit.reversed);
    index += targetTempFahrenheit.length;
    final upperTempLimitCelsius = ElinkCmdUtils.intToBytes(probeInfo.upperTempLimitCelsius, length: 2, littleEndian: false);
    payload.setAll(index, upperTempLimitCelsius.reversed);
    index += upperTempLimitCelsius.length;
    final upperTempLimitFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.upperTempLimitFahrenheit, length: 2, littleEndian: false);
    payload.setAll(index, upperTempLimitFahrenheit.reversed);
    index += upperTempLimitFahrenheit.length;
    final lowerTempLimitCelsius = ElinkCmdUtils.intToBytes(probeInfo.lowerTempLimitCelsius, length: 2, littleEndian: false);
    payload.setAll(index, lowerTempLimitCelsius.reversed);
    index += lowerTempLimitCelsius.length;
    final lowerTempLimitFahrenheit = ElinkCmdUtils.intToBytes(probeInfo.lowerTempLimitFahrenheit, length: 2, littleEndian: false);
    payload.setAll(index, lowerTempLimitFahrenheit.reversed);
    index += lowerTempLimitFahrenheit.length;
    final cookingId = ElinkCmdUtils.intToBytes(probeInfo.id ~/ 1000);
    payload.setAll(index, cookingId);
    index += cookingId.length;
    final workTime = ElinkCmdUtils.intToBytes(probeInfo.workTime ?? 0);
    payload.setAll(index, workTime);
    index += workTime.length;
    final countDown = ElinkCmdUtils.intToBytes(probeInfo.timerCountDown ?? 0);
    payload.setAll(index, countDown);
    index += countDown.length;
    final alarmTempPercent = ElinkProbeConfig.doubleTo4Bytes(probeInfo.alarmTempPercent ?? 0.95);
    payload.setAll(index, alarmTempPercent);
    index += alarmTempPercent.length;
    payload[index++] = probeInfo.foodRawness;

    if (!probeInfo.remark.isNullOrEmpty) {
      String remark = probeInfo.remark!;
      List<int> remarkBytes = utf8.encode(remark);
      if (remarkBytes.length > 32) {
        while (remarkBytes.length > 29) {
          remark = remark.substring(0, remark.length - 1);
          remarkBytes = utf8.encode(remark);
        }
        remark = "$remark...";
        remarkBytes = utf8.encode(remark);
      }
      payload.setAll(index, remarkBytes);
      index += remarkBytes.length;
    }
    return getElinkA7Data(payload);
  }
}
