# ailink

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
        <uses-permission android:name="android.permission.BLUETOOTH" />
        <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
```

## iOS
1. When using the flutter_blue_plus library, you need to add the required permissions to ios/Runner/Info.plist
```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
        <dict>
            <key>NSBluetoothAlwaysUsageDescription</key>
            <string>Need BLE permission</string>
            <key>NSBluetoothPeripheralUsageDescription</key>
            <string>Need BLE permission</string>
            <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
            <string>Need Location permission</string>
            <key>NSLocationAlwaysUsageDescription</key>
            <string>Need Location permission</string>
            <key>NSLocationWhenInUseUsageDescription</key>
            <string>Need Location permission</string>
        </dict>
    </plist>
```

## Flutter
### ElinkProbeCmdUtils
##### Probe Command Related
1. Get version information:
```dart
    final cmd = getVersion();
```
2. Sync time:
```dart 
    syncTime({DateTime? dateTime})
```
3. Get battery level:
```dart
  final cmd = getBattery();
```
4. Switch unit:
```dart
    final cmd = switchUnit(unit); //0: °C, 1: °F
```
5. Set data:
```dart
  import 'package:ailink_food_probe/model/elink_probe_info.dart';

  ElinkProbeInfo probeInfo;
  final cmd = setProbeInfo(probeInfo);
```
6. Get data:
```dart
    final cmd = getProbeInfo();
```
7. Clear data:
```dart
    final cmd = clearProbeInfo();
```

##### Probe Box Command Related
1. Switch unit:
```dart
    final cmd = switchUnitBox(unit); //0: °C, 1: °F
```
2. Get probe data (based on the probe's MAC address):
```dart
    List<int> probeMac;
    final cmd = getBoxProbeInfo(probeMac);
```
3. Set probe data (only the alarm temperature in the probe data is processed by the device, other data is not processed):
```dart
    import 'package:ailink_food_probe/model/elink_probe_info.dart';

    ElinkProbeInfo probeInfo;
    final cmd = setBoxProbeInfo(probeInfo);
```
4. Clear probe data (based on the probe's MAC address):
```dart
    List<int> probeMac;
    final cmd = clearBoxProbeInfo(probeMac);
```

For specific usage, please see example
