import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_box_info.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/model/elink_probe_real_time.dart';
import 'package:ailink_food_probe/utils/elink_probe_a6_data_parse_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_a7_data_parse_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_box_parse_callback.dart';
import 'package:ailink_food_probe/utils/elink_probe_box_with_screen_parse_callback.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';
import 'package:ailink_food_probe/utils/elink_probe_parse_callback.dart';
import 'package:flutter/foundation.dart';

typedef OnGetVersion = Function(String version);
typedef OnSetResult = Function(ElinkSetResult result);
typedef OnSyncTimeResult = Function(ElinkSetResult result);
typedef OnGetBattery = Function(ElinkChargingState state, int battery);
typedef OnSwitchUnit = Function(ElinkSetResult unit);
typedef OnGetRealTimeData = Function(ElinkProbeRealTimeInfo realTimeModel);
typedef OnGetProbeInfo = Function(ElinkProbeInfo probeInfo);
typedef OnGetProbeInfoFailure = Function(List<int> mac);
typedef OnGetProbeBoxInfo = Function(
  int supportNum,
  int connectNum,
  ElinkChargingState boxChargingState,
  int boxBattery,
  ElinkTemperatureUnit boxUnit,
  List<ElinkProbeBoxInfo> chargingBox,
);
typedef OnAlarmResult = Function(
  List<int> mac,
  bool isTimeout,
  bool isAmbientTempHigh,
  bool isTargetTempReached,
);
typedef OnCancelAmbientAlarm = Function(List<int> mac, bool cancel);
typedef OnEndWorkByBox = Function(List<int> mac);

/// 探针和探针盒子数据处理工具类(Probe and probe box data processing tool class)
class ElinkProbeDataParseUtils {
  static ElinkProbeDataParseUtils? _instance;

  List<int>? _mac;

  ElinkProbeDataParseUtils._() {
    _instance = this;
  }

  factory ElinkProbeDataParseUtils(List<int> mac) {
    _instance ??= ElinkProbeDataParseUtils._();
    _instance!.initialize(mac);
    return _instance!;
  }

  void initialize(List<int> mac) {
    _mac = mac;
  }

  OnGetVersion? onGetVersion;
  VoidCallback? onRequestSyncTime;
  OnSetResult? onSetResult;
  OnSyncTimeResult? onSyncTimeResult;
  OnGetBattery? onGetBattery;
  OnSwitchUnit? onSwitchUnit;
  OnGetRealTimeData? onGetRealTimeData;
  OnGetProbeInfo? onGetProbeInfo;
  OnGetProbeInfoFailure? onGetProbeInfoFailure;
  OnGetProbeBoxInfo? onGetProbeChargingBoxInfo;
  OnCancelAmbientAlarm? onCancelAmbientAlarm;
  OnEndWorkByBox? onEndWorkByBox;

  void setProbeCallback(
    ElinkProbeParseCallback callback
  ) {
    onGetVersion = callback.onGetVersion;
    onGetBattery = callback.onGetBattery;
    onSetResult = callback.onSetResult;
    onSwitchUnit = callback.onSwitchUnit;
    onGetRealTimeData = callback.onGetRealTimeData;
    onGetProbeInfo = callback.onGetProbeInfo;
    onGetProbeInfoFailure = callback.onGetProbeInfoFailure;
  }

  void setProbeBoxCallback(
    ElinkProbeBoxParseCallback callback
  ) {
    onGetVersion = callback.onGetVersion;
    onRequestSyncTime = callback.onRequestSyncTime;
    onSetResult = callback.onSetResult;
    onSyncTimeResult = callback.onSyncTimeResult;
    onSwitchUnit = callback.onSwitchUnit;
    onGetProbeChargingBoxInfo = callback.onGetProbeChargingBoxInfo;
    onGetProbeInfo = callback.onGetProbeInfo;
  }

  void setProbeBoxWithScreenCallback(
    ElinkProbeBoxWithScreenParseCallback callback
  ) {
    onGetVersion = callback.onGetVersion;
    onRequestSyncTime = callback.onRequestSyncTime;
    onSetResult = callback.onSetResult;
    onSyncTimeResult = callback.onSyncTimeResult;
    onSwitchUnit = callback.onSwitchUnit;
    onGetProbeChargingBoxInfo = callback.onGetProbeChargingBoxInfo;
    onGetProbeInfo = callback.onGetProbeInfo;
    onCancelAmbientAlarm = callback.onCancelAmbientAlarm;
    onEndWorkByBox = callback.onEndWorkByBox;
    onGetProbeInfoFailure = callback.onGetProbeInfoFailure;
  }

  @Deprecated('Please use setProbeCallback & setProbeBoxCallback instead')
  void setCallback({
    OnGetVersion? onGetVersion,
    VoidCallback? onRequestSyncTime,
    OnSetResult? onSetResult,
    OnSyncTimeResult? onSyncTimeResult,
    OnGetBattery? onGetBattery,
    OnSwitchUnit? onSwitchUnit,
    OnGetRealTimeData? onGetRealTimeData,
    OnGetProbeInfo? onGetProbeInfo,
    OnGetProbeInfoFailure? onGetProbeInfoFailure,
    OnGetProbeBoxInfo? onGetProbeChargingBoxInfo,
  }) {
    this.onGetVersion = onGetVersion;
    this.onRequestSyncTime = onRequestSyncTime;
    this.onSetResult = onSetResult;
    this.onSyncTimeResult = onSyncTimeResult;
    this.onGetBattery = onGetBattery;
    this.onSwitchUnit = onSwitchUnit;
    this.onGetRealTimeData = onGetRealTimeData;
    this.onGetProbeInfo = onGetProbeInfo;
    this.onGetProbeInfoFailure = onGetProbeInfoFailure;
    this.onGetProbeChargingBoxInfo = onGetProbeChargingBoxInfo;
  }

  void parseElinkData(List<int> data) {
    if (ElinkCmdUtils.checkElinkCmdSum(data)) {
      if (ElinkCmdUtils.isElinkA6Data(data)) {
        ElinkProbeA6DataParseUtils().parseData(
          _mac ?? [],
          data,
          onGetVersion: onGetVersion,
          onRequestSyncTime: onRequestSyncTime,
          onSetResult: onSetResult,
          onSyncTimeResult: onSyncTimeResult,
          onGetBattery: onGetBattery,
          onGetProbeInfo: onGetProbeInfo,
          onGetProbeInfoFailure: onGetProbeInfoFailure,
        );
      } else if (ElinkCmdUtils.isElinkA7Data(data)) {
        ElinkProbeA7DataParseUtils().parseData(
          _mac ?? [],
          data,
          onSwitchUnit: onSwitchUnit,
          onGetRealTimeData: onGetRealTimeData,
          onGetProbeChargingBoxInfo: onGetProbeChargingBoxInfo,
          onGetProbeInfo: onGetProbeInfo,
          onGetProbeInfoFailure: onGetProbeInfoFailure,
          onCancelAmbientAlarm: onCancelAmbientAlarm,
          onEndWorkByBox: onEndWorkByBox,
        );
      }
    } else {
      if (kDebugMode) {
        print('parseElinkData: checkElinkCmdSum error');
      }
    }
  }
}
