
import 'ailink_food_probe_platform_interface.dart';

class AilinkFoodProbe {
  Future<String?> getPlatformVersion() {
    return AilinkFoodProbePlatform.instance.getPlatformVersion();
  }
}
