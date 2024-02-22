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
```
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
        <uses-permission android:name="android.permission.BLUETOOTH" />
        <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
```

## iOS
1. 使用flutter_blue_plus库, 需要在ios/Runner/Info.plist文件中添加相关权限
```
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
##### 探针指令相关
1. 获取版本信息: 
```dart
    final cmd = getVersion();
```
2. 同步时间: 
```dart 
    syncTime({DateTime? dateTime})
```
3. 获取电量:
```dart
  final cmd = getBattery();
```
4. 切换单位:
```dart
    final cmd = switchUnit(unit); //0: °C, 1: °F
```
5. 设置数据:
```dart
  import 'package:ailink_food_probe/model/elink_probe_info.dart';

  ElinkProbeInfo probeInfo;
  final cmd = setProbeInfo(probeInfo);
```
6. 获取数据:
```dart
    final cmd = getProbeInfo();
```
7. 清除数据:
```dart
    final cmd = clearProbeInfo();
```

##### 探针盒子指令相关
1. 切换单位:
```dart
    final cmd = switchUnitBox(unit); //0: °C, 1: °F
```
2. 获取探针数据(根据探针的mac地址):
```dart
    List<int> probeMac;
    final cmd = getBoxProbeInfo(probeMac);
```
3. 设置探针数据(探针数据中目前仅有报警温度设备端有处理，其它数据都未处理):
```dart
    import 'package:ailink_food_probe/model/elink_probe_info.dart';

    ElinkProbeInfo probeInfo;
    final cmd = setBoxProbeInfo(probeInfo);
```
4. 清除探针数据(根据探针的mac地址):
```dart
    List<int> probeMac;
    final cmd = clearBoxProbeInfo(probeMac);
```

具体使用方法，请参照示例
