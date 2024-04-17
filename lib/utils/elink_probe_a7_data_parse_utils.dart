import 'dart:typed_data';

import 'package:ailink/ailink.dart';
import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_box_info.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/model/elink_probe_real_time.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';
import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';

/// 探针和探针盒子A7数据处理工具类(Probe and probe box A& data processing tools)
class ElinkProbeA7DataParseUtils {
  static ElinkProbeA7DataParseUtils? _instance;

  ElinkProbeA7DataParseUtils._() {
    _instance = this;
  }

  factory ElinkProbeA7DataParseUtils() =>
      _instance ?? ElinkProbeA7DataParseUtils._();

  void parseData(
    List<int> mac,
    List<int> data, {
    OnSwitchUnit? onSwitchUnit,
    OnGetRealTimeData? onGetRealTimeData,
    OnGetProbeBoxInfo? onGetProbeChargingBoxInfo,
    OnGetProbeInfo? onGetProbeInfo,
    OnAlarmResult? onAlarmResult,
    OnCancelAmbientAlarm? onCancelAmbientAlarm,
    OnGetProbeInfoFailure? onGetProbeInfoFailure,
    OnEndWorkByBox? onEndWorkByBox,
  }) async {
    final cid = data.sublist(1, 3);
    // print('cid: $cid');
    if (ElinkProbeConfig.isProbeAndBox(cid)) {
      // print('isProbeAndBox');
      final decrypted = await Ailink().mcuDecrypt(Uint8List.fromList(mac), Uint8List.fromList(data));
      switch (decrypted[0]) {
        case 0x02:  ///mcu上报设备状态数据
          final isBox = ElinkProbeConfig.isCidProbeBox(cid);
          final version = decrypted[1] & 0xFF;
          final supportNum = decrypted[2] & 0xFF;
          final connectNum = decrypted[3] & 0xFF;
          final boxChargingState = (decrypted[4] >> 7) & 0x01;
          final boxBattery = decrypted[4] & 0x7F;
          final boxUnit = decrypted[5] & 0xFF;
          final probeList = <ElinkProbeBoxInfo>[];
          if (connectNum > 0) {
            for (int i = 0; i < connectNum; i++) {
              //探针编号
              final num = decrypted[9 + i * 15] & 0xFF;
              //盒子连接的探针Mac地址
              final mac = List.filled(6, 0x00);
              mac[0] = decrypted[10 + i * 15];
              mac[1] = decrypted[11 + i * 15];
              mac[2] = decrypted[12 + i * 15];
              mac[3] = decrypted[13 + i * 15];
              mac[4] = decrypted[14 + i * 15];
              mac[5] = decrypted[15 + i * 15];
              // 食物温度单位
              int foodUnit = isBox ? (decrypted[16 + i * 15] & 0xFF) >> 7 : (decrypted[17 + i * 15] & 0x80) >> 7;
              // 食物温度正负
              int foodPositive = isBox ? decrypted[16 + i * 15] & 0x40 : ((decrypted[17 + i * 15] & 0x40) >> 6) & 0x01;
              // 食物温度绝对值
              int foodTemperature = isBox ? (decrypted[17 + i * 15] & 0xFF) + ((decrypted[16 + i * 15] & 0x3F) << 8) : (decrypted[16 + i * 15] & 0xFF) + ((decrypted[17 + i * 15] & 0x3F) << 8);
              // 环境温度单位
              int ambientUnit = isBox ? (decrypted[18 + i * 15] & 0xFF) >> 7 : (decrypted[19 + i * 15] & 0x80) >> 7;
              // 环境温度正负
              int ambientPositive = isBox ? decrypted[18 + i * 15] & 0x40 : ((decrypted[19 + i * 15] & 0x40) >> 6) & 0x01;
              // 环境温度绝对值
              int ambientTemperature = isBox ? (decrypted[19 + i * 15] & 0xFF) + ((decrypted[18 + i * 15] & 0x3F) << 8) : (decrypted[18 + i * 15] & 0xFF) + ((decrypted[19 + i] & 0x3F) << 8);
              // 探针充电状态
              int probeChargingState = (decrypted[20 + i * 15] & 0xFF) >> 7;
              // 探针电量
              int probeBattery = decrypted[20 + i * 15] & 0x7F;
              // 探针插入食物状态 插入1 未插入0 不支持255
              int probeState = decrypted[21 + i * 15] & 0xFF;
              //数据类赋值
              final model = ElinkProbeBoxInfo(num, mac, foodUnit, foodPositive, foodTemperature, ambientUnit, ambientPositive, ambientTemperature, ElinkChargingState.values[probeChargingState], probeBattery, probeState);
              probeList.add(model);
            }
            onGetProbeChargingBoxInfo?.call(supportNum, connectNum, ElinkChargingState.values[boxChargingState], boxBattery, ElinkTemperatureUnit.values[boxUnit], probeList);
          } else {
            onGetProbeChargingBoxInfo?.call(supportNum, connectNum, ElinkChargingState.values[boxChargingState], boxBattery, ElinkTemperatureUnit.values[boxUnit], probeList);
          }
          break;
        case 0x03:  ///探针数据
          if (ElinkProbeConfig.isCidProbe(cid)) {
            _parseElinkProbeRealTimeData(
              decrypted,
              onGetRealTimeData: onGetRealTimeData,
            );
          } else if (ElinkProbeConfig.isCidProbeBox(cid)) {
            _parseElinkBoxProbeData(decrypted, onGetProbeInfo: onGetProbeInfo);
          } else {
            if (decrypted.length < 2) return;
            final unit = decrypted[1] & 0x01;
            onSwitchUnit?.call(ElinkSetResult.values[unit]);
          }
          break;
        case 0x04:  ///mcu上报单位切换结果
          onSwitchUnit?.call(ElinkProbeConfig.isCidProbe(cid) ? ElinkSetResult.values[decrypted[1]]: ElinkSetResult.success);
          break;
        case 0x05:  ///mcu上报报警状态数据
          if (ElinkProbeConfig.isCidProbeBox(cid)) {
            if (decrypted.length < 8) return;
            final mac = List.filled(6, 0x00);
            mac[0] = decrypted[1];
            mac[1] = decrypted[2];
            mac[2] = decrypted[3];
            mac[3] = decrypted[4];
            mac[4] = decrypted[5];
            mac[5] = decrypted[6];
            final timeout = (decrypted[7] & 0x04) >> 2;
            final ambientTempHigh = (decrypted[7] & 0x02) >> 1;
            final targetReached = decrypted[7] & 0x01;
            onAlarmResult?.call(mac, timeout == 1, ambientTempHigh == 1, targetReached == 1);
          }
          break;
        case 0x06:  ///mcu回复报警状态成功或失败 0->成功 1->失败 2->不支持
          if (ElinkProbeConfig.isCidProbeBoxWithScreen(cid)) {
            if (decrypted.length < 8) return;
            final mac = List.filled(6, 0x00);
            mac[0] = decrypted[1];
            mac[1] = decrypted[2];
            mac[2] = decrypted[3];
            mac[3] = decrypted[4];
            mac[4] = decrypted[5];
            mac[5] = decrypted[6];
            final targetReached = decrypted[7] & 0x01;
            onAlarmResult?.call(mac, false, false, targetReached == 1);
          }
          break;
        case 0x07:  ///mcu发送取消报警
          break;
        case 0x08:  ///mcu回复取消报警 0->成功 1->失败 2->不支持
          if (ElinkProbeConfig.isCidProbeBoxWithScreen(cid)) {
            if (decrypted.length < 8) return;
            final mac = List.filled(6, 0x00);
            mac[0] = decrypted[1];
            mac[1] = decrypted[2];
            mac[2] = decrypted[3];
            mac[3] = decrypted[4];
            mac[4] = decrypted[5];
            mac[5] = decrypted[6];
            final cancelAlarmState = decrypted[7] & 0xFF;
            onCancelAmbientAlarm?.call(mac, cancelAlarmState == 0xFF);
          }
          break;
        case 0x0A:
          if (ElinkProbeConfig.isCidProbeBoxWithScreen(cid)) {
            _parseElinkBoxWithScreenProbeData(decrypted, onGetProbeInfo: onGetProbeInfo, onGetProbeInfoFailure: onGetProbeInfoFailure, onEndWorkByBox: onEndWorkByBox);
          }
          break;
      }
    }
  }

  _parseElinkProbeRealTimeData(
    List<int> decrypted, {
    OnGetRealTimeData? onGetRealTimeData,
  }) {
    final id = decrypted[1];
    final realTimeUnit = (decrypted[3] >> 7) & 0x01;
    final realTimePositive = (decrypted[3] >> 6) & 0x01;
    final realTimeTemp = (decrypted[4] & 0xFF) + ((decrypted[3] & 0x3F) << 8);
    final ambientUnit = (decrypted[5] >> 7) & 0x01;
    final ambientPositive = (decrypted[5] >> 6) & 0x01;
    final int ambientTemp;
    if ((decrypted[6] & 0xFF) == 255 && (decrypted[5] & 0xFF) == 255) {
      ambientTemp = 0xFFFF;
    } else {
      ambientTemp = (decrypted[6] & 0xFF) + ((decrypted[5] & 0x3F) << 8);
    }
    final targetUnit = (decrypted[7] >> 7) & 0x01;
    final targetPositive = (decrypted[7] >> 6) & 0x01;
    final int targetTemp;
    if ((decrypted[8] & 0xFF) == 255 && (decrypted[7] & 0xFF) == 255) {
      targetTemp = 0xFFFF;
    } else {
      targetTemp = (decrypted[8] & 0xFF) + ((decrypted[7] & 0x3F) << 8);
    }
    // 探针状态 0->未插入 1->已插入 3->设备无该功能
    final probeState = decrypted[9] & 0x03;
    onGetRealTimeData?.call(ElinkProbeRealTimeInfo(id, realTimeUnit, realTimePositive, realTimeTemp, ambientUnit, ambientPositive, ambientTemp, targetUnit, targetPositive, targetTemp, probeState,));
  }

  _parseElinkBoxProbeData(
    List<int> decrypted, {
    OnGetProbeInfo? onGetProbeInfo,
  }) {
    final hasData = decrypted[1];
    if(hasData == 0x01 && decrypted.length >= 48) {
      int index = 2;
      final mac = decrypted.sublist(index, index += 6);
      final version = decrypted[index++] & 0xFF;
      final id = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 4)) * 1000;
      final foodType = decrypted[index++] & 0xFF;
      final foodRawness = decrypted[index++] & 0xFF;
      final targetTempCelsius = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final targetTempFahrenheit = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final lowerTempLimitCelsius = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final lowerTempLimitFahrenheit = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final upperTempLimitCelsius = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final upperTempLimitFahrenheit = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final alarmTempPercent = ElinkCmdUtils.bytesToDouble(decrypted.sublist(index, index += 8));
      final timerStart = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 4)) * 1000;
      final timerEnd = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 4)) * 1000;
      final currentUnit = decrypted[index++] & 0xFF;
      final alarmTempCelsius = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final alarmTempFahrenheit = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 2));
      final model = ElinkProbeInfo(
          mac: mac, id: id, foodType: foodType, foodRawness: foodRawness, targetTempCelsius: targetTempCelsius,
          targetTempFahrenheit: targetTempFahrenheit, lowerTempLimitCelsius: lowerTempLimitCelsius,
          lowerTempLimitFahrenheit: lowerTempLimitFahrenheit, upperTempLimitCelsius: upperTempLimitCelsius,
          upperTempLimitFahrenheit: upperTempLimitFahrenheit, currentUnit: currentUnit,
          alarmTempPercent: alarmTempPercent, timerStart: timerStart, timerEnd: timerEnd,
          alarmTempCelsius: alarmTempCelsius, alarmTempFahrenheit: alarmTempFahrenheit
      );
      onGetProbeInfo?.call(model);
    }
  }

  _parseElinkBoxWithScreenProbeData(
    List<int> decrypted, {
    OnGetProbeInfo? onGetProbeInfo,
    OnGetProbeInfoFailure? onGetProbeInfoFailure,
    OnEndWorkByBox? onEndWorkByBox,
  }) {
    if (decrypted.length < 72) return;
    print('_parseElinkBoxWithScreenProbeData decrypted: ${decrypted.toHex()}');
    int index = 3;
    final mac = decrypted.sublist(index, index += 6);
    if (decrypted[1] == 0x02 || decrypted[9] == 0x00) {
      if (decrypted[1] == 0x00 && decrypted[9] == 0x00 && (decrypted[10] & 0xFF) != 255) {
        onEndWorkByBox?.call(mac);
      } else {
        onGetProbeInfoFailure?.call(mac);
      }
    } else {
      final workState = decrypted[index++] & 0xFF;
      final foodType = decrypted[index++] & 0xFF;
      int targetTempCelsius = (decrypted[index++] & 0xFF) + ((decrypted[index] & 0x7F) << 8);
      final targetTempCelsiusPositive = ((decrypted[index++] & 0x40) >> 6) & 0x01;
      targetTempCelsius = targetTempCelsiusPositive == 0 ? targetTempCelsius : -targetTempCelsius;
      int targetTempFahrenheit = (decrypted[index++] & 0xFF) + ((decrypted[index] & 0x7F) << 8);
      final targetTempFahrenheitPositive = ((decrypted[index++] & 0x40) >> 6) & 0x01;
      targetTempFahrenheit = targetTempFahrenheitPositive == 0 ? targetTempFahrenheit : -targetTempFahrenheit;
      int upperTempLimitCelsius = (decrypted[index++] & 0xFF) + ((decrypted[index] & 0x7F) << 8);
      final upperTempLimitCelsiusPositive = ((decrypted[index++] & 0x40) >> 6) & 0x01;
      upperTempLimitCelsius = upperTempLimitCelsiusPositive == 0 ? upperTempLimitCelsius : -upperTempLimitCelsius;
      int upperTempLimitFahrenheit = (decrypted[index++] & 0xFF) + ((decrypted[index] & 0x7F) << 8);
      final upperTempLimitFahrenheitPositive = ((decrypted[index++] & 0x40) >> 6) & 0x01;
      upperTempLimitFahrenheit = upperTempLimitFahrenheitPositive == 0 ? upperTempLimitFahrenheit : -upperTempLimitFahrenheit;
      int lowerTempLimitCelsius = (decrypted[index++] & 0xFF) + ((decrypted[index] & 0x7F) << 8);
      final lowerTempLimitCelsiusPositive = ((decrypted[index++] & 0x40) >> 6) & 0x01;
      lowerTempLimitCelsius = lowerTempLimitCelsiusPositive == 0 ? lowerTempLimitCelsius : -lowerTempLimitCelsius;
      int lowerTempLimitFahrenheit = (decrypted[index++] & 0xFF) + ((decrypted[index] & 0x7F) << 8);
      final lowerTempLimitFahrenheitPositive = ((decrypted[index++] & 0x40) >> 6) & 0x01;
      lowerTempLimitFahrenheit = lowerTempLimitFahrenheitPositive == 0 ? lowerTempLimitFahrenheit : -lowerTempLimitFahrenheit;
      final cookId = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 4)) * 1000;
      final workTime = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 4));
      final countDown = ElinkCmdUtils.bytesToInt(decrypted.sublist(index, index += 4));
      int timeStart = 0;
      int timeEnd = 0;
      if (countDown > 0) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        timeStart = currentTime;
        timeEnd = currentTime + countDown * 1000;
      }
      double alarmTempPercent = ElinkProbeConfig.bytes4ToDouble(decrypted.sublist(index, index += 4));
      if (alarmTempPercent > 1) {
        alarmTempPercent = 0.95;
      }
      final alarmTempCelsius = (targetTempCelsius * alarmTempPercent).round();
      final alarmTempFahrenheit = (targetTempFahrenheit * alarmTempPercent).round();
      final foodRawness = decrypted[index++] & 0xFF;
      final remark = String.fromCharCodes(decrypted.sublist(index, index += 32));
      final model = ElinkProbeInfo(
        mac: mac,
        id: cookId,
        foodType: foodType,
        foodRawness: foodRawness,
        targetTempCelsius: targetTempCelsius,
        targetTempFahrenheit: targetTempFahrenheit,
        lowerTempLimitCelsius: lowerTempLimitCelsius,
        lowerTempLimitFahrenheit: lowerTempLimitFahrenheit,
        upperTempLimitCelsius: upperTempLimitCelsius,
        upperTempLimitFahrenheit: upperTempLimitFahrenheit,
        alarmTempPercent: alarmTempPercent,
        timerStart: timeStart,
        timerCountDown: countDown,
        timerEnd: timeEnd,
        currentUnit: 0,
        alarmTempCelsius: alarmTempCelsius,
        alarmTempFahrenheit: alarmTempFahrenheit,
        remark: remark,
        workTime: workTime,
        workState: workState,
      );
      onGetProbeInfo?.call(model);
    }
  }
}
