import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';
import 'package:flutter/foundation.dart';

class ElinkProbeBoxWithScreenParseCallback {
  final OnGetVersion? onGetVersion;
  final VoidCallback? onRequestSyncTime;
  final OnSetResult? onSetResult;
  final OnSyncTimeResult? onSyncTimeResult;
  final OnSwitchUnit? onSwitchUnit;
  final OnGetProbeBoxInfo? onGetProbeChargingBoxInfo;
  final OnGetProbeInfo? onGetProbeInfo;
  final OnGetProbeInfoFailure? onGetProbeInfoFailure;
  final OnCancelAmbientAlarm? onCancelAmbientAlarm;
  final OnEndWorkByBox? onEndWorkByBox;

  ElinkProbeBoxWithScreenParseCallback({
    this.onGetVersion,
    this.onRequestSyncTime,
    this.onSetResult,
    this.onSyncTimeResult,
    this.onSwitchUnit,
    this.onGetProbeChargingBoxInfo,
    this.onGetProbeInfo,
    this.onGetProbeInfoFailure,
    this.onCancelAmbientAlarm,
    this.onEndWorkByBox,
  });
}
