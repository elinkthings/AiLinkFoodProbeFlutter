import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';

class ElinkProbeParseCallback {
  final OnGetVersion? onGetVersion;
  final OnGetBattery? onGetBattery;
  final OnSetResult? onSetResult;
  final OnSwitchUnit? onSwitchUnit;
  final OnGetRealTimeData? onGetRealTimeData;
  final OnGetProbeInfo? onGetProbeInfo;
  final OnGetProbeInfoFailure? onGetProbeInfoFailure;

  ElinkProbeParseCallback({
    this.onGetVersion,
    this.onGetBattery,
    this.onSetResult,
    this.onSwitchUnit,
    this.onGetRealTimeData,
    this.onGetProbeInfo,
    this.onGetProbeInfoFailure,
  });
}
