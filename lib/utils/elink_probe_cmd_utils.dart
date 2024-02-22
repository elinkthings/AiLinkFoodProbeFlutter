import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';

/// 探针和探针盒子命令工具类
class ElinkProbeCmdUtils {
  List<int>? _mac;

  static ElinkProbeCmdUtils? _instance;

  ElinkProbeCmdUtils._() {
    _instance = this;
  }

  factory ElinkProbeCmdUtils(List<int> mac) {
    _instance ??= ElinkProbeCmdUtils._();
    _instance!.initialize(mac);
    return _instance!;
  }

  void initialize(List<int> mac) {
    _mac = mac;
  }

  /*----------------------------------------------探针(Probe)----------------------------------------------*/

  /// 获取版本
  List<int> getVersion() {
    final payload = [0x46];
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /// 同步时间
  List<int> syncTime({DateTime? dateTime}) {
    final payload = ElinkCmdUtils.getElinkDateTime(date: dateTime);
    payload.insert(0, 0x37);
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /// 获取电量
  List<int> getBattery() {
    final payload = [0x28];
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /// 切换单位
  Future<List<int>> switchUnit(int unit) {
    if (_mac == null) return Future.value([]);
    final payload = [0x04, unit];
    return ElinkCmdUtils.getElinkA7Data(ElinkProbeConfig.cidProbe, _mac!, payload);
  }

  /// 获取设备信息
  List<int> getProbeInfo() {
    final payload = List.filled(2, 0x01);
    payload[0] = 0x36;
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /// 开始工作(设置信息)
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
  List<int> clearProbeInfo() {
    final payload = List.filled(2, 0x00);
    payload[0] = 0x35;
    return ElinkCmdUtils.getElinkA6Data(payload);
  }

  /*----------------------------------------------探针充电盒子(ProbeChargingBox)----------------------------------------------*/

  /// 获取盒子信息
  Future<List<int>> getBoxDeviceInfo() {
    final payload = List.filled(2, 0x01);
    return _getProbeChargingBoxCmd(payload);
  }

  /// 盒子切换单位
  Future<List<int>> switchUnitBox(int unit) {
    final payload = [0x04, unit];
    return _getProbeChargingBoxCmd(payload);
  }

  /// 盒子获取探针信息
  Future<List<int>> getBoxProbeInfo(List<int> probeMac) {
    final payload = List.filled(8, 0x00);
    payload[0] = 0x03;
    payload[1] = 0x02;
    payload.setAll(2, probeMac);
    return _getProbeChargingBoxCmd(payload);
  }

  /// 盒子清除探针信息
  Future<List<int>> clearBoxProbeInfo(List<int> probeMac) {
    final payload = List.filled(8, 0x00);
    payload[0] = 0x03;
    payload.setAll(2, probeMac);
    return _getProbeChargingBoxCmd(payload);
  }

  /// 盒子设置探针信息
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
    return _getProbeChargingBoxCmd(payload);
  }

  /// 盒子设置报警
  Future<List<int>> setAmbientAlarm(
    List<int> probeMac, {
    bool? isTimerExpired = true,
    bool? isHighAmbientTemp = true,
    bool? isTargetTempReached = true,
  }) {
    final payload = List.filled(8, 0x00);
    payload[0] = 0x05;
    payload.insertAll(1, probeMac);
    final alarmState = ((isTimerExpired == true ? 0x01 : 0x00) |
            ((isHighAmbientTemp == true ? 0x01 : 0x00) << 1) |
            ((isTargetTempReached == true ? 0x01 : 0x00) << 2)) & 0xFF;
    payload[7] = alarmState;
    return _getProbeChargingBoxCmd(payload);
  }

  /// 盒子取消报警
  Future<List<int>> cancelAmbientAlarm(List<int> probeMac) {
    final payload = List.filled(8, 0xFF);
    payload[0] = 0x07;
    payload.insertAll(1, probeMac);
    return _getProbeChargingBoxCmd(payload);
  }

  Future<List<int>> _getProbeChargingBoxCmd(List<int> payload) {
    if (_mac == null) return Future.value([]);
    return ElinkCmdUtils.getElinkA7Data(ElinkProbeConfig.cidProbeBox, _mac!, payload);
  }
}
