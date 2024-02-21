import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ailink_food_probe_method_channel.dart';

abstract class AilinkFoodProbePlatform extends PlatformInterface {
  /// Constructs a AilinkFoodProbePlatform.
  AilinkFoodProbePlatform() : super(token: _token);

  static final Object _token = Object();

  static AilinkFoodProbePlatform _instance = MethodChannelAilinkFoodProbe();

  /// The default instance of [AilinkFoodProbePlatform] to use.
  ///
  /// Defaults to [MethodChannelAilinkFoodProbe].
  static AilinkFoodProbePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AilinkFoodProbePlatform] when
  /// they register themselves.
  static set instance(AilinkFoodProbePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
