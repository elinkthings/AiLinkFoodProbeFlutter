import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ailink_food_probe/ailink_food_probe_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAilinkFoodProbe platform = MethodChannelAilinkFoodProbe();
  const MethodChannel channel = MethodChannel('ailink_food_probe');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
