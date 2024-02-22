import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';
import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';
import 'package:flutter/foundation.dart';

/// 探针和探针盒子A6数据处理工具类(Probe and probe box A6 data processing tools)
class ElinkProbeA6DataParseUtils {
  static ElinkProbeA6DataParseUtils? _instance;

  ElinkProbeA6DataParseUtils._() {
    _instance = this;
  }

  factory ElinkProbeA6DataParseUtils() =>
      _instance ?? ElinkProbeA6DataParseUtils._();

  void parseData(
    List<int> mac,
    List<int> data, {
    OnGetVersion? onGetVersion,
    VoidCallback? onRequestSyncTime,
    OnSetResult? onSetResult,
    OnSyncTimeResult? onSyncTimeResult,
    OnGetBattery? onGetBattery,
    OnGetProbeInfo? onGetProbeInfo,
    OnGetProbeInfoFailure? onGetProbeInfoFailure,
  }) {
    final payload = ElinkCmdUtils.formatA6Data(data);
    switch (payload[0]) {
      case 0x28: //获取电量
        final state = ElinkChargingState.values[payload[1]];
        int battery = payload[2] & 0xFF;
        onGetBattery?.call(state, battery);
        break;
      case 0x35: //设置设备信息
        final result = ElinkSetResult.values[payload[1]];
        onSetResult?.call(result);
        break;
      case 0x37: //同步时间给mcu
        final result = ElinkSetResult.values[payload[1]];
        onSyncTimeResult?.call(result);
        break;
      case 0x36:
        if (payload[1] == 0x01) {
          if (payload.length >= 38) {
            int index = 2;
            final version = payload[index++] & 0xFF;
            final id = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 4)) * 1000;
            final foodType = payload[index++] & 0xFF;
            final foodRawness = payload[index++] & 0xFF;
            final targetTempCelsius = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 2));
            final targetTempFahrenheit = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 2));
            final lowerTempLimitCelsius = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 2));
            final lowerTempLimitFahrenheit = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 2));
            final upperTempLimitCelsius = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 2));
            final upperTempLimitFahrenheit = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 2));
            final alarmTempPercent = ElinkCmdUtils.bytesToDouble(payload.sublist(index, index += 8));
            final timerStart = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 4)) * 1000;
            final timerEnd = ElinkCmdUtils.bytesToInt(payload.sublist(index, index += 4)) * 1000;
            final currentUnit = payload[index++] & 0xFF;
            final probeInfo = ElinkProbeInfo(
              mac: mac,
              id: id,
              foodType: foodType,
              foodRawness: foodRawness,
              targetTempCelsius: targetTempCelsius,
              targetTempFahrenheit: targetTempFahrenheit,
              lowerTempLimitCelsius: lowerTempLimitCelsius,
              lowerTempLimitFahrenheit: lowerTempLimitFahrenheit,
              upperTempLimitCelsius: upperTempLimitCelsius,
              upperTempLimitFahrenheit: upperTempLimitFahrenheit,
              alarmTempPercent: alarmTempPercent,
              timerStart: timerStart,
              timerEnd: timerEnd,
              currentUnit: currentUnit,
            );
            onGetProbeInfo?.call(probeInfo);
          }
        } else if (payload[1] == 0x00) {
          onGetProbeInfoFailure?.call(mac);
        }
        break;
      case 0x38: //mcu请求同步时间
        if (payload[1] == 0x01) {
          onRequestSyncTime?.call();
        }
        break;
      case 0x46: //获取模块版本号
        final versionArr = payload.sublist(2);
        final version = String.fromCharCodes(versionArr);
        onGetVersion?.call(version);
        break;
    }
  }
}
