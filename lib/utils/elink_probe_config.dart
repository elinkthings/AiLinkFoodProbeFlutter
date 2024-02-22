class ElinkProbeConfig {
  static const List<int> cidProbe = [0x00, 0x3F];
  static const List<int> cidProbeBox = [0x00, 0x55];

  static isCidProbe(List<int> cid) {
    return cid[0] == cidProbe[0] && cid[1] == cidProbe[1];
  }

  static isCidProbeBox(List<int> cid) {
    return cid[0] == cidProbeBox[0] && cid[1] == cidProbeBox[1];
  }

  static isProbeAndBox(List<int> cid) {
    return isCidProbe(cid) || isCidProbeBox(cid);
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
