import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ailink_food_probe_platform_interface.dart';

/// An implementation of [AilinkFoodProbePlatform] that uses method channels.
class MethodChannelAilinkFoodProbe extends AilinkFoodProbePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ailink_food_probe');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
