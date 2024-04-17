import 'dart:async';
import 'dart:typed_data';

import 'package:ailink/ailink.dart';
import 'package:ailink/utils/ble_common_util.dart';
import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/elink_broadcast_data_utils.dart';
import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_box_info.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/utils/elink_probe_box_parse_callback.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';
import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_box_cmd_utils.dart';
import 'package:ailink_food_probe_example/model/connect_device_model.dart';
import 'package:ailink_food_probe_example/utils/extensions.dart';
import 'package:ailink_food_probe_example/utils/log_utils.dart';
import 'package:ailink_food_probe_example/widgets/widget_ble_state.dart';
import 'package:ailink_food_probe_example/widgets/widget_operate_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Probe charging box device(探针充电盒子设备)
class ProbeBoxDevicePage extends StatefulWidget {
  const ProbeBoxDevicePage({super.key});

  @override
  State<ProbeBoxDevicePage> createState() => _ProbeBoxDevicePageState();
}

class _ProbeBoxDevicePageState extends State<ProbeBoxDevicePage> {
  final logList = <String>[];
  final probeInfoList = <ElinkProbeBoxInfo>[];
  ElinkProbeBoxInfo? selectProbeInfo;

  final _ailinkPlugin = Ailink();
  final ScrollController _controller = ScrollController();
  ElinkTemperatureUnit unit = ElinkTemperatureUnit.celsius;

  BluetoothDevice? _bluetoothDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _onReceiveDataSubscription;
  StreamSubscription<List<int>>? _onReceiveDataSubscription1;

  BluetoothCharacteristic? _dataA7Characteristic;
  BluetoothCharacteristic? _dataA6Characteristic;

  late ElinkProbeBoxCmdUtils _elinkProbeBoxSendCmdUtils;
  late ElinkProbeDataParseUtils _elinkProbeDataParseUtils;

  @override
  void initState() {
    super.initState();
    // _addLog('initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('addPostFrameCallback');
      _init();
      _connectionStateSubscription =
          _bluetoothDevice?.connectionState.listen((state) {
        if (state.isConnected) {
          _addLog('Connected');
          _bluetoothDevice?.discoverServices().then((services) {
            _addLog('DiscoverServices success: ${services.map((e) => e.serviceUuid).join(',').toUpperCase()}');
            if (services.isNotEmpty) {
              _setNotify(services);
            }
          }, onError: (error) {
            _addLog('DiscoverServices error');
          });
        } else {
          _dataA6Characteristic = null;
          _dataA7Characteristic = null;
          probeInfoList.clear();
          _addLog('Disconnected: code(${_bluetoothDevice?.disconnectReason?.code}), desc(${_bluetoothDevice?.disconnectReason?.description})');
        }
      });
      _bluetoothDevice?.connect();
    });
  }

  void _init() {
    final connectDeviceModel =
        ModalRoute.of(context)?.settings.arguments as ConnectDeviceModel;
    _bluetoothDevice = connectDeviceModel.device;
    _elinkProbeBoxSendCmdUtils = ElinkProbeBoxCmdUtils(connectDeviceModel.bleData.macArr);
    _elinkProbeDataParseUtils = ElinkProbeDataParseUtils(connectDeviceModel.bleData.macArr);
    _elinkProbeDataParseUtils.setProbeBoxCallback(ElinkProbeBoxParseCallback(
        onGetVersion: (version) {
          _addLog('onGetVersion: $version');
        }, onRequestSyncTime: () {
          _addLog('onRequestSyncTime');
        }, onSetResult: (setResult) {
          _addLog('onSetResult: $setResult');
        }, onSyncTimeResult: (syncResult) {
          _addLog('onSyncTimeResult: $syncResult');
        }, onSwitchUnit: (setResult) {
          _addLog('onSwitchUnit: $setResult, $unit');
          if (setResult == ElinkSetResult.success) {
            setState(() {
              unit = unit == ElinkTemperatureUnit.celsius ? ElinkTemperatureUnit.fahrenheit : ElinkTemperatureUnit.celsius;
            });
          }
        }, onGetProbeChargingBoxInfo: (supportNum, connectNum, boxChargingState, boxBattery, boxUnit, probeList) {
          // LogUtils().log('onGetProbeChargingBoxInfo: supportNum: $supportNum, currentNum: $currentNum, boxChargingState: $boxChargingState, boxBattery: $boxBattery, boxUnit: ${boxUnit.name}, ${probeList.map((e) => e.toFormatString()).join(',')}');
          _addLog('onGetProbeChargingBoxInfo: supportNum: $supportNum, connectNum: $connectNum, boxChargingState: $boxChargingState, boxBattery: $boxBattery, boxUnit: ${boxUnit.name}, ${probeList.map((e) => e.toFormatString()).join(',')}');
          if (unit != boxUnit) {
            setState(() {
              unit = boxUnit;
            });
          }
          if (probeInfoList.isEmpty) {
            setState(() {
              probeInfoList.addAll(probeList);
            });
          }
        }, onGetProbeInfo: (probeInfo) {
          _addLog('onGetProbeInfo: $probeInfo');
          LogUtils().log('onGetProbeInfo: $probeInfo');
        }
    ));
  }

  void _showInfo({
    String msg = 'Please select probe',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bluetoothDevice?.advName ?? 'Unknown',
              style: const TextStyle(fontSize: 18),
            ),
            StreamBuilder<BluetoothConnectionState>(
              initialData: BluetoothConnectionState.disconnected,
              stream: _bluetoothDevice?.connectionState,
              builder: (context, snapshot) {
                final state = snapshot.data ?? BluetoothConnectionState.disconnected;
                return Text(
                  state.isConnected ? 'Connected' : 'Disconnected',
                  style: const TextStyle(fontSize: 14),
                );
              },
            )
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          BleStateWidget(
            bluetoothDevice: _bluetoothDevice,
            onPressed: () {
              _bluetoothDevice?.connect();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OperateBtnWidget(
                onPressed: () {
                  final data = _elinkProbeBoxSendCmdUtils.getVersion();
                  _addLog('getVersion: ${data.toHex()}');
                  _dataA6Characteristic?.write(data);
                },
                title: 'GetVersion',
              ),
              OperateBtnWidget(
                onPressed: () {
                  final data = _elinkProbeBoxSendCmdUtils.syncTime();
                  _addLog('syncTime: ${data.toHex()}');
                  _dataA6Characteristic?.write(data);
                },
                title: 'SyncTime',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OperateBtnWidget(
                onPressed: () async {
                  final unitI = (unit == ElinkTemperatureUnit.celsius ? ElinkTemperatureUnit.fahrenheit : ElinkTemperatureUnit.celsius).index;
                  final data = await _elinkProbeBoxSendCmdUtils.switchUnit(unitI);
                  _addLog('switchUnit: ${data.toHex()}');
                  _dataA7Characteristic?.write(data);
                },
                title: 'SwitchUnit(${unit.name})',
              ),
              OperateBtnWidget(
                onPressed: () async {
                  final mac = selectProbeInfo?.mac ?? [];
                  if (mac.isEmpty) {
                    _showInfo();
                    return;
                  }
                  final data = await _elinkProbeBoxSendCmdUtils.clearBoxProbeInfo(mac);
                  _addLog('clearProbeInfo: ${data.toHex()}');
                  _dataA7Characteristic?.write(data);
                },
                title: 'ClearProbeInfo',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OperateBtnWidget(
                onPressed: () async {
                  final mac = selectProbeInfo?.mac ?? [];
                  if (mac.isEmpty) {
                    _showInfo();
                    return;
                  }
                  final time = DateTime.now().millisecondsSinceEpoch;
                  final probeInfo = ElinkProbeInfo(
                    mac: mac,
                    id: time,
                    foodType: 0,
                    foodRawness: 2,
                    targetTempCelsius: 20,
                    targetTempFahrenheit: 68,
                    lowerTempLimitCelsius: 0,
                    lowerTempLimitFahrenheit: 32,
                    upperTempLimitCelsius: 100,
                    upperTempLimitFahrenheit: 212,
                    alarmTempPercent: 0.8,
                    currentUnit: unit.index,
                    timerStart: time,
                    timerEnd: time,
                    alarmTempCelsius: 35,
                    alarmTempFahrenheit: 95,
                    remark: 'ProbeBox',
                  );
                  final data = await _elinkProbeBoxSendCmdUtils.setBoxProbeInfo(probeInfo);
                  _addLog('setProbeInfo: ${data.toHex()}');
                  _dataA7Characteristic?.write(data, allowLongWrite: true);
                },
                title: 'SetProbeInfo',
              ),
              OperateBtnWidget(
                onPressed: () async {
                  final mac = selectProbeInfo?.mac ?? [];
                  if (mac.isEmpty) {
                    _showInfo();
                    return;
                  }
                  final data = await _elinkProbeBoxSendCmdUtils.getBoxProbeInfo(mac);
                  _addLog('getProbeInfo: ${data.toHex()}');
                  _dataA7Characteristic?.write(data);
                },
                title: 'GetProbeInfo',
              ),
            ],
          ),
          DropdownButton<ElinkProbeBoxInfo>(
            value: selectProbeInfo,
            hint: const Text(
              'Select probe',
              style: TextStyle(fontSize: 16),
            ),
            items: probeInfoList.map((e) {
              return DropdownMenuItem<ElinkProbeBoxInfo>(
                value: e,
                child: Text(
                  ElinkBroadcastDataUtils.littleBytes2MacStr(e.mac),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (probeInfo) {
              setState(() {
                selectProbeInfo = probeInfo;
              });
            },
          ),
          Expanded(
            child: ListView.separated(
              controller: _controller,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Text(
                    '${DateTime.now()}: \n${logList[index]}',
                    style: TextStyle(
                      color: index % 2 == 0 ? Colors.black : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 0.5,
                  color: Colors.grey,
                );
              },
              itemCount: logList.length,
            ),
          )
        ],
      ),
    );
  }

  void _setNotify(List<BluetoothService> services) async {
    final service = services.firstWhere((service) => service.serviceUuid.str.equal(ElinkBleCommonUtils.elinkConnectDeviceUuid));
    _addLog('_setNotify characteristics: ${service.characteristics.map((e) => e.uuid).join(',').toUpperCase()}');
    for (var characteristic in service.characteristics) {
      if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkNotifyUuid) ||
          characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkWriteAndNotifyUuid)) {
        _addLog('_setNotify characteristics uuid: ${characteristic.uuid}');
        await characteristic.setNotifyValue(true);
        if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkWriteAndNotifyUuid)) {
          _onReceiveDataSubscription = characteristic.onValueReceived.listen((data) {
            _addLog('OnValueReceived [${characteristic.uuid.str}]: ${data.toHex()}, checked: ${ElinkCmdUtils.checkElinkCmdSum(data)}');
            if (ElinkBleCommonUtils.isSetHandShakeCmd(data)) {
              _replyHandShake(characteristic, data);
            } else if (ElinkBleCommonUtils.isGetHandShakeCmd(data)) {
              Future.delayed(const Duration(milliseconds: 500), () async {
                final handShakeStatus = await _ailinkPlugin.checkHandShakeStatus(Uint8List.fromList(data));
                _addLog('handShakeStatus: $handShakeStatus');
              });
            } else {
              _elinkProbeDataParseUtils.parseElinkData(data);
            }
          });
          _dataA6Characteristic = characteristic;
          await _setHandShake(characteristic);
        } else if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkNotifyUuid)) {
          _onReceiveDataSubscription1 = characteristic.onValueReceived.listen((data) {
            _addLog('OnValueReceived [${characteristic.uuid.str}]: ${data.toHex()}, checked: ${ElinkCmdUtils.checkElinkCmdSum(data)}');
            _elinkProbeDataParseUtils.parseElinkData(data);
          });
        }
      } else if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkWriteUuid)) {
        _dataA7Characteristic = characteristic;
      }
    }
  }

  Future<void> _setHandShake(BluetoothCharacteristic characteristic) async {
    Uint8List data = (await _ailinkPlugin.initHandShake()) ?? Uint8List(0);
    _addLog('_setHandShake: ${data.toHex()}');
    await characteristic.write(data.toList(), withoutResponse: true);
  }

  Future<void> _replyHandShake(BluetoothCharacteristic characteristic, List<int> data) async {
    Uint8List replyData = (await _ailinkPlugin.getHandShakeEncryptData(Uint8List.fromList(data))) ?? Uint8List(0);
    _addLog('_replyHandShake: ${replyData.toHex()}');
    await characteristic.write(replyData.toList(), withoutResponse: true);
  }

  void _addLog(String log) {
    if (mounted) {
      setState(() {
        logList.insert(0, log);
      });
    }
  }

  @override
  void dispose() {
    _bluetoothDevice?.disconnect();
    _bluetoothDevice = null;
    _dataA6Characteristic = null;
    _dataA6Characteristic = null;
    probeInfoList.clear();
    _controller.dispose();
    _onReceiveDataSubscription?.cancel();
    _onReceiveDataSubscription1?.cancel();
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}
