# ailink_food_probe

##[中文](README_CN.md)

AiLink probe and probe box protocol data processing Flutter library.

## Necessary condition

1. Acquired AILink Bluetooth communication protocol
2. Have smart devices that support AILink Bluetooth module
3. Have knowledge of Flutter development and debugging

## UUID Description
1. FFE1: Write A7 data
2. FFE2: Monitor A7 data changes
3. FFE3: Write A6 data and monitor A6 data changes

## Android

1. Add ```maven { url 'https://jitpack.io' }``` in android/build.gradle file
``` groovy
    allprojects {
        repositories {
            google()
            mavenCentral()
            //add
            maven { url 'https://jitpack.io' }
        }
    }
```

2. Modify ```minSdkVersion 21``` in the android/app/build.gradle file
```groovy
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId "com.elinkthings.ailink_food_probe_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdkVersion 21 //flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
```

3. To use the flutter_blue_plus library, you need to add the required permissions to android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Tell Google Play Store that your app uses Bluetooth LE
         Set android:required="true" if bluetooth is necessary -->
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />

    <!-- New Bluetooth permissions in Android 12
    https://developer.android.com/about/versions/12/features/bluetooth-permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <!-- legacy for Android 11 or lower -->
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30"/>

    <!-- legacy for Android 9 or lower -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />
</manifest>
```

## iOS
1. When using the flutter_blue_plus library, you need to add the required permissions to ios/Runner/Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>NSBluetoothAlwaysUsageDescription</key>
        <string>This app always needs Bluetooth to function</string>
        <key>NSBluetoothPeripheralUsageDescription</key>
        <string>This app needs Bluetooth Peripheral to function</string>
        <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
        <string>This app always needs location and when in use to function</string>
        <key>NSLocationAlwaysUsageDescription</key>
        <string>This app always needs location to function</string>
        <key>NSLocationWhenInUseUsageDescription</key>
        <string>This app needs location when in use to function</string>
    </dict>
</plist>
```

## Flutter
### Probe Command Related
#### ElinkProbeCmdUtils
```dart
    import 'package:ailink_food_probe/utils/elink_probe_cmd_utils.dart';

    List<int> probeMac;
    final elinkProbeCmdUtils = ElinkProbeCmdUtils(probeMac);
```
1. Get version information:
```dart
    final cmd = elinkProbeCmdUtils.getVersion();
```
2. Get battery level:
```dart
  final cmd = elinkProbeCmdUtils.getBattery();
```
3. Switch unit:
```dart
    final cmd = elinkProbeCmdUtils.switchUnit(unit); //0: °C, 1: °F
```
4. Set data:
```dart
  import 'package:ailink_food_probe/model/elink_probe_info.dart';

  ElinkProbeInfo probeInfo;
  final cmd = elinkProbeCmdUtils.setProbeInfo(probeInfo);
```
5. Get data:
```dart
    final cmd = elinkProbeCmdUtils.getProbeInfo();
```
6. Clear data:
```dart
    final cmd = elinkProbeCmdUtils.clearProbeInfo();
```

### Probe Command callback
##### ElinkProbeParseCallback
```dart
    import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';
    import 'package:ailink_food_probe/utils/elink_probe_parse_callback.dart';

    List<int> probeMac;
    final elinkProbeDataParseUtils = ElinkProbeDataParseUtils(probeMac);
    final probeCallback = ElinkProbeParseCallback(
        onGetVersion: (version) {}, 
        onGetBattery: (state, battery) {}, 
        onSetResult: (setResult) {}, 
        onSwitchUnit: (setResult) {}, 
        onGetRealTimeData: (realTimeModel) {}, 
        onGetProbeInfo: (probeInfo) {}, 
        onGetProbeInfoFailure: (mac) {}
    );
    elinkProbeDataParseUtils.setProbeCallback(probeCallback);

    ///After discovering the service, determine the characteristic value UUID to be ElinkBleCommonUtils.elinkWriteAndNotifyUuid or ElinkBleCommonUtils.elinkNotifyUuid
    characteristic.onValueReceived.listen((data) {
      elinkProbeDataParseUtils.parseElinkData(data);
    }
```

### Probe Box Command Related
#### ElinkProbeBoxCmdUtils
```dart
    import 'package:ailink_food_probe/utils/elink_probe_box_cmd_utils.dart';
    List<int> probeBoxMac;
    final elinkProbeBoxCmdUtils = ElinkProbeBoxCmdUtils(probeBoxMac);
```
1. Get version information:
```dart
    final cmd = elinkProbeBoxCmdUtils.getVersion();
```
2. Sync time:
```dart 
    final cmd = elinkProbeBoxCmdUtils.syncTime(dateTime);
```
3. Switch unit:
```dart
    final cmd = elinkProbeBoxCmdUtils.switchUnit(unit); //0: °C, 1: °F
```
4. Get probe data (based on the probe's MAC address):
```dart
    List<int> probeMac;
    final cmd = elinkProbeBoxCmdUtils.getBoxProbeInfo(probeMac);
```
5. Set probe data (only the alarm temperature in the probe data is processed by the device, other data is not processed):
```dart
    import 'package:ailink_food_probe/model/elink_probe_info.dart';

    ElinkProbeInfo probeInfo;
    final cmd = elinkProbeBoxCmdUtils.setBoxProbeInfo(probeInfo);
```
6. Clear probe data (based on the probe's MAC address):
```dart
    List<int> probeMac;
    final cmd = elinkProbeBoxCmdUtils.clearBoxProbeInfo(probeMac);
```

### Probe box command callback
##### ElinkProbeBoxParseCallback
```dart
    import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';
    import 'package:ailink_food_probe/utils/elink_probe_box_parse_callback.dart';

    List<int> probeBoxMac;
    final elinkProbeDataParseUtils = ElinkProbeDataParseUtils(probeBoxMac);
    
    final boxCallback = ElinkProbeBoxParseCallback(
        onGetVersion: (version) {},
        onRequestSyncTime: () {},
        onSetResult: (setResult) {},
        onSyncTimeResult: (syncResult) {},
        onSwitchUnit: (setResult) {},
        onGetProbeChargingBoxInfo: (supportNum, currentNum, boxChargingState, boxBattery, boxUnit, probeList) {},
        onGetProbeInfo: (probeInfo) {}
    );
    elinkProbeDataParseUtils.setProbeBoxCallback(boxCallback);

    ///After discovering the service, determine the characteristic value UUID to be ElinkBleCommonUtils.elinkWriteAndNotifyUuid or ElinkBleCommonUtils.elinkNotifyUuid
    characteristic.onValueReceived.listen((data) {
      elinkProbeDataParseUtils.parseElinkData(data);
    }
```

### Probe Box With Screen Command Related
##### ElinkProbeBoxWithScreenCmdUtils
```dart
    import 'package:ailink_food_probe/utils/elink_probe_box_with_screen_cmd_utils.dart';
    List<int> probeBoxMac;
    final elinkProbeBoxWithScreenCmdUtils = ElinkProbeBoxWithScreenCmdUtils(probeBoxMac);
```
1. Get version information:
```dart
    final cmd = elinkProbeBoxWithScreenCmdUtils.getVersion();
```
2. Sync time:
```dart 
    final cmd = elinkProbeBoxWithScreenCmdUtils.syncTime(dateTime);
```
3. Switch unit:
```dart
    final cmd = elinkProbeBoxWithScreenCmdUtils.switchUnit(unit); //0: °C, 1: °F
```
4. Get probe data:
```dart
    List<int> probeMac;
    final cmd = elinkProbeBoxWithScreenCmdUtils.getProbeInfo();
```
5. Set probe data (only the alarm temperature in the probe data is processed by the device, other data is not processed):
```dart
    import 'package:ailink_food_probe/model/elink_probe_info.dart';

    ElinkProbeInfo probeInfo;
    final cmd = elinkProbeBoxWithScreenCmdUtils.setBoxProbeInfo(probeInfo);
```
6. Clear probe data (based on the probe's MAC address):
```dart
    List<int> probeMac;
    final cmd = elinkProbeBoxWithScreenCmdUtils.clearBoxProbeInfo(probeMac);
```

### Probe box with screen command callback
##### ElinkProbeBoxWithScreenParseCallback
```dart
    import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';
    import 'package:ailink_food_probe/utils/elink_probe_box_with_screen_parse_callback.dart';

    List<int> probeBoxMac;
    final elinkProbeDataParseUtils = ElinkProbeDataParseUtils(probeBoxMac);
    
    final boxCallback = ElinkProbeBoxWithScreenParseCallback(
        onGetVersion: (version) {}, 
        onRequestSyncTime: () {}, 
        onSetResult: (setResult) {}, 
        onSyncTimeResult: (syncResult) {}, 
        onSwitchUnit: (setResult) {}, 
        onGetProbeChargingBoxInfo: (supportNum, connectNum, boxChargingState, boxBattery, boxUnit, probeList) {}, 
        onGetProbeInfo: (probeInfo) {}, 
        onGetProbeInfoFailure: (mac) {}, 
        onCancelAmbientAlarm: (mac, cancel) {}, 
        onEndWorkByBox: (mac) {},
    );
    elinkProbeDataParseUtils.setProbeBoxCallback(boxCallback);

    ///发现服务后判断特征值UUID为ElinkBleCommonUtils.elinkWriteAndNotifyUuid或ElinkBleCommonUtils.elinkNotifyUuid
    characteristic.onValueReceived.listen((data) {
      elinkProbeDataParseUtils.parseElinkData(data);
    }
```
For specific usage, please see example
