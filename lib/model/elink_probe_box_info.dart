import 'package:ailink/utils/elink_broadcast_data_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';

/// 探针盒子关联的探针数据 (Probe data associated with the probe box)
class ElinkProbeBoxInfo {
  final int num;
  final List<int> mac;
  final int foodUnit;
  final int foodPositive;
  final int foodTemp;
  final int ambientUnit;
  final int ambientPositive;
  final int ambientTemp;
  final ElinkChargingState chargingState;
  final int battery;
  final int state;

  ElinkProbeBoxInfo(
    this.num,
    this.mac,
    this.foodUnit,
    this.foodPositive,
    this.foodTemp,
    this.ambientUnit,
    this.ambientPositive,
    this.ambientTemp,
    this.chargingState,
    this.battery,
    this.state,
  );

  @override
  String toString() {
    return 'ElinkProbeChargingBoxInfo{num: $num, mac: ${ElinkBroadcastDataUtils.littleBytes2MacStr(mac)}, foodUnit: $foodUnit, foodPositive: $foodPositive, foodTemp: $foodTemp, ambientUnit: $ambientUnit, ambientPositive: $ambientPositive, ambientTemp: $ambientTemp, chargingState: $chargingState, battery: $battery, probeState: $state}';
  }

  String toFormatString() {
    return 'ElinkProbeRealTimeModel{'
        'num: $num, '
        'mac: ${ElinkBroadcastDataUtils.littleBytes2MacStr(mac)}, '
        'foodTemp: $foodTempStr, '
        'ambientTemp: $ambientTempStr, '
        'chargingState: $chargingState, '
        'battery: $battery, '
        'probeState: $probeState}';
  }

  String get foodTempStr =>
      '${foodPositive == 0 ? '' : '-'}$foodTemp${ElinkTemperatureUnit.values[foodUnit].name}';

  String get ambientTempStr =>
      '${ambientPositive == 0 ? '' : '-'}$ambientTemp${ElinkTemperatureUnit.values[ambientUnit].name}';

  ElinkProbeState get probeState => ElinkProbeState.values[state == 255 ? 3 : state];
}
