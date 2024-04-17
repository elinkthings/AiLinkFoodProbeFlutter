import 'package:ailink_food_probe/utils/elink_probe_base_cmd_utils.dart';

abstract class ElinkProbeBoxBaseCmdUtils extends ElinkProbeBaseCmdUtils {

  /// 盒子取消环境温度报警
  /// 使用UUID(elinkWriteUuid: FFE1)的特征值写入
  /// Write using the characteristic value of UUID(elinkWriteUuid: FFE1)
  Future<List<int>> cancelAmbientAlarm(List<int> probeMac) {
    final payload = List.filled(8, 0xFF);
    payload[0] = 0x07;
    payload.insertAll(1, probeMac);
    return getElinkA7Data(payload);
  }
}
