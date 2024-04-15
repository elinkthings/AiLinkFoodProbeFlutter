# ailink

##[English](README.md)

AiLink探针和探针盒子协议数据处理Flutter库.

## 必备条件

1. 已获取AILink蓝牙通讯协议
2. 拥有支持AILink蓝牙模块的智能设备
3. 具备Flutter开发和调试知识

## UUID说明
1. FFE1: 写入A7数据
2. FFE2: 监听A7数据变化
3. FFE3: 写入A6数据和监听A6数据变化

## Android

1. 在android/build.gradle文件中添加```maven { url 'https://jitpack.io' }```
```
    allprojects {
        repositories {
            google()
            mavenCentral()
            //add
            maven { url 'https://jitpack.io' }
        }
    }
```

2. 在android/app/build.gradle文件中设置```minSdkVersion 21```
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

3. 使用flutter_blue_plus库, 需要在android/app/src/main/AndroidManifest.xml文件中添加相关权限
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
1. 使用flutter_blue_plus库, 需要在ios/Runner/Info.plist文件中添加相关权限
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
### 探针指令相关
##### ElinkProbeCmdUtils
```dart
    import 'package:ailink_food_probe/utils/elink_probe_cmd_utils.dart';

    List<int> probeMac;
    final elinkProbeCmdUtils = ElinkProbeCmdUtils(probeMac);
```
1. 获取版本信息: 
```dart
    final cmd = elinkProbeCmdUtils.getVersion();
```
2. 获取电量:
```dart
  final cmd = elinkProbeCmdUtils.getBattery();
```
3. 切换单位:
```dart
    final cmd = elinkProbeCmdUtils.switchUnit(unit); //0: °C, 1: °F
```
4. 设置数据:
```dart
  import 'package:ailink_food_probe/model/elink_probe_info.dart';

  ElinkProbeInfo probeInfo;
  final cmd = elinkProbeCmdUtils.setProbeInfo(probeInfo);
```
5. 获取数据:
```dart
    final cmd = elinkProbeCmdUtils.getProbeInfo();
```
6. 清除数据:
```dart
    final cmd = elinkProbeCmdUtils.clearProbeInfo();
```

### 探针盒子指令相关
##### ElinkProbeBoxCmdUtils
```dart
    import 'package:ailink_food_probe/utils/elink_probe_box_cmd_utils.dart';
    List<int> probeBoxMac;
    final elinkProbeBoxCmdUtils = ElinkProbeBoxCmdUtils(probeBoxMac);
```
1. 获取版本信息:
```dart
    final cmd = elinkProbeBoxCmdUtils.getVersion();
```
2. 同步时间:
```dart 
    final cmd = elinkProbeBoxCmdUtils.syncTime(dateTime);
```
3. 切换单位:
```dart
    final cmd = elinkProbeBoxCmdUtils.switchUnit(unit); //0: °C, 1: °F
```
4. 获取探针数据(根据探针的mac地址):
```dart
    List<int> probeMac;
    final cmd = elinkProbeBoxCmdUtils.getBoxProbeInfo(probeMac);
```
5. 设置探针数据(探针数据中目前仅有报警温度设备端有处理，其它数据都未处理):
```dart
    import 'package:ailink_food_probe/model/elink_probe_info.dart';

    ElinkProbeInfo probeInfo;
    final cmd = elinkProbeBoxCmdUtils.setBoxProbeInfo(probeInfo);
```
6. 清除探针数据(根据探针的mac地址):
```dart
    List<int> probeMac;
    final cmd = elinkProbeBoxCmdUtils.clearBoxProbeInfo(probeMac);
```

具体使用方法，请参照示例
