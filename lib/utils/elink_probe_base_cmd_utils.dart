import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';

abstract class ElinkProbeBaseCmdUtils {
  List<int>? _mac;
  List<int> _cid = ElinkProbeConfig.cidProbe;

  void initialize(
    List<int> mac, {
    required List<int> cid,
  }) {
    _cid = cid;
    _mac = mac;
  }

  List<int>? getMac() => _mac;

  List<int> getCid() => _cid;

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

  /// 切换单位
  /// unit 0: °C, 1: °F
  Future<List<int>> switchUnit(int unit) {
    if (_mac == null) return Future.value([]);
    final payload = [0x04, unit];
    return getElinkA7Data(payload);
  }

  Future<List<int>> getElinkA7Data(List<int> payload) {
    if (_mac == null) return Future.value([]);
    return ElinkCmdUtils.getElinkA7Data(_cid, _mac!, payload);
  }
}
