import 'package:flutter_test/flutter_test.dart';
import 'package:ailink_food_probe/ailink_food_probe.dart';
import 'package:ailink_food_probe/ailink_food_probe_platform_interface.dart';
import 'package:ailink_food_probe/ailink_food_probe_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAilinkFoodProbePlatform
    with MockPlatformInterfaceMixin
    implements AilinkFoodProbePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AilinkFoodProbePlatform initialPlatform = AilinkFoodProbePlatform.instance;

  test('$MethodChannelAilinkFoodProbe is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAilinkFoodProbe>());
  });

  test('getPlatformVersion', () async {
    AilinkFoodProbe ailinkFoodProbePlugin = AilinkFoodProbe();
    MockAilinkFoodProbePlatform fakePlatform = MockAilinkFoodProbePlatform();
    AilinkFoodProbePlatform.instance = fakePlatform;

    expect(await ailinkFoodProbePlugin.getPlatformVersion(), '42');
  });
}
