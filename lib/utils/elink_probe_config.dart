import 'dart:typed_data';

class ElinkProbeConfig {
  static const List<int> cidProbe = [0x00, 0x3F];
  static const List<int> cidProbeBox = [0x00, 0x55];
  static const List<int> cidProbeBoxWithScreen = [0x00, 0x62];

  static isCidProbe(List<int> cid) {
    return cid[0] == cidProbe[0] && cid[1] == cidProbe[1];
  }

  static isCidProbeBox(List<int> cid) {
    return cid[0] == cidProbeBox[0] && cid[1] == cidProbeBox[1];
  }

  static isCidProbeBoxWithScreen(List<int> cid) {
    return cid[0] == cidProbeBoxWithScreen[0] && cid[1] == cidProbeBoxWithScreen[1];
  }

  static isProbeAndBox(List<int> cid) {
    return isCidProbe(cid) || isCidProbeBox(cid) || isCidProbeBoxWithScreen(cid);
  }

  static List<int> doubleTo4Bytes(double value, {bool littleEndian = true}) {
    var buffer = ByteData(4);
    buffer.setFloat32(0, value, littleEndian ? Endian.little : Endian.big);
    return buffer.buffer.asUint8List();
  }

  static double bytes4ToDouble(List<int> bytes, {bool littleEndian = true}) {
    var buffer = ByteData.sublistView(Uint8List.fromList(bytes));
    return buffer.getFloat32(0, littleEndian ? Endian.little : Endian.big);
  }

  static List<int> intToBytes(int num) {
    List<int> b = List<int>.filled(2, 0);
    for (int i = 0; i < 2; i++) {
      b[i] = (num & 0xFF);
      num = num >> 8;
    }
    // 反转数组
    b = b.reversed.toList();
    return b;
  }
}

extension ElinkTemperatureUnitExtension on ElinkTemperatureUnit {
  String get name {
    switch (this) {
      case ElinkTemperatureUnit.celsius:
        return '°C';
      case ElinkTemperatureUnit.fahrenheit:
        return '°F';
    }
  }
}

enum ElinkSetResult {
  success,
  fail,
  unSupport,
}

enum ElinkChargingState {
  notCharging,
  charging,
  full,
  abnormal,
}

enum ElinkTemperatureUnit {
  celsius,
  fahrenheit,
}

enum ElinkProbeState {
  notInserted,
  inserted,
  unknown,
  unSupport,
}
