import 'dart:async';
import 'dart:typed_data';

import 'package:ailink/ailink.dart';
import 'package:ailink/utils/ble_common_util.dart';
import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/elink_broadcast_data_utils.dart';
import 'package:ailink/utils/elink_cmd_utils.dart';
import 'package:ailink_food_probe/model/elink_probe_info.dart';
import 'package:ailink_food_probe/utils/elink_probe_cmd_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';
import 'package:ailink_food_probe/utils/elink_probe_data_parse_utils.dart';
import 'package:ailink_food_probe_example/model/connect_device_model.dart';
import 'package:ailink_food_probe_example/utils/extensions.dart';
import 'package:ailink_food_probe_example/widgets/widget_ble_state.dart';
import 'package:ailink_food_probe_example/widgets/widget_operate_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Probe device(探针设备)
class ProbeDevicePage extends StatefulWidget {
  const ProbeDevicePage({super.key});

  @override
  State<ProbeDevicePage> createState() => _ProbeDevicePageState();
}

class _ProbeDevicePageState extends State<ProbeDevicePage> {
  final logList = <String>[];

  final _ailinkPlugin = Ailink();
  final ScrollController _controller = ScrollController();
  ElinkTemperatureUnit unit = ElinkTemperatureUnit.celsius;

  BluetoothDevice? _bluetoothDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _onReceiveDataSubscription;
  StreamSubscription<List<int>>? _onReceiveDataSubscription1;

  BluetoothCharacteristic? _dataA7Characteristic;
  BluetoothCharacteristic? _dataA6Characteristic;

  late ElinkProbeCmdUtils _elinkProbeSendCmdUtils;
  late ElinkProbeDataParseUtils _elinkProbeDataParseUtils;

  @override
  void initState() {
    super.initState();
    // _addLog('initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('addPostFrameCallback');
      _init();
      _connectionStateSubscription = _bluetoothDevice?.connectionState.listen((state) {
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
          _addLog('Disconnected: code(${_bluetoothDevice?.disconnectReason?.code}), desc(${_bluetoothDevice?.disconnectReason?.description})');
        }
      });
      _bluetoothDevice?.connect();
    });
  }

  void _init() {
    final connectDeviceModel = ModalRoute.of(context)?.settings.arguments as ConnectDeviceModel;
    _bluetoothDevice = connectDeviceModel.device;
    _elinkProbeSendCmdUtils = ElinkProbeCmdUtils(connectDeviceModel.bleData.macArr);
    _elinkProbeDataParseUtils = ElinkProbeDataParseUtils(connectDeviceModel.bleData.macArr);
    _elinkProbeDataParseUtils.setCallback(onGetVersion: (version) {
      _addLog('onGetVersion: $version');
    }, onGetBattery: (state, battery) {
      _addLog('onGetBattery: $state, $battery');
    }, onSetResult: (setResult) {
      _addLog('onSetResult: $setResult');
    }, onSwitchUnit: (setResult) {
      _addLog('onSwitchUnit: $setResult, $unit');
      if (setResult == ElinkSetResult.success) {
        setState(() {
          unit = unit == ElinkTemperatureUnit.celsius ? ElinkTemperatureUnit.fahrenheit : ElinkTemperatureUnit.celsius;
        });
      }
    }, onGetRealTimeData: (realTimeModel) {
      _addLog('onGetRealTimeData: ${realTimeModel.toFormatString()}');
    }, onGetProbeInfo: (probeInfo) {
      _addLog('onGetProbeInfo: $probeInfo');
    }, onGetProbeInfoFailure: (mac) {
      _addLog('onGetProbeInfoFailure: ${ElinkBroadcastDataUtils.littleBytes2MacStr(mac)}');
    });
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
                  final data = _elinkProbeSendCmdUtils.getVersion();
                  _addLog('getVersion: ${data.toHex()}');
                  _dataA6Characteristic?.write(data);
                },
                title: 'GetVersion',
              ),
              OperateBtnWidget(
                onPressed: () {
                  final data = _elinkProbeSendCmdUtils.getBattery();
                  _addLog('getBattery: ${data.toHex()}');
                  _dataA6Characteristic?.write(data);
                },
                title: 'GetBattery',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OperateBtnWidget(
                onPressed: () {
                  final deviceModel = ModalRoute.of(context)?.settings.arguments as ConnectDeviceModel;
                  final probeInfo = ElinkProbeInfo(mac: deviceModel.bleData.macArr,
                      id: 1708568881612, foodType: 0,
                      foodRawness: 2, targetTempCelsius: 1,
                      targetTempFahrenheit: 149,
                      lowerTempLimitCelsius: 0,
                      lowerTempLimitFahrenheit: 32,
                      upperTempLimitCelsius: 100,
                      upperTempLimitFahrenheit: 212,
                      alarmTempPercent: 0.8,
                      currentUnit: unit.index,
                      timerStart: 1708568881612,
                      timerEnd: 1708568881612,
                  );
                  final data = _elinkProbeSendCmdUtils.setProbeInfo(probeInfo);
                  _addLog('SetProbeInfo: ${data.toHex()}');
                  _dataA6Characteristic?.write(data);
                },
                title: 'SetProbeInfo',
              ),
              OperateBtnWidget(
                onPressed: () {
                  final data = _elinkProbeSendCmdUtils.getProbeInfo();
                  _addLog('GetProbeInfo: ${data.toHex()}');
                  _dataA6Characteristic?.write(data);
                },
                title: 'GetProbeInfo',
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OperateBtnWidget(
                onPressed: () async {
                  final unitI = (unit == ElinkTemperatureUnit.celsius ? ElinkTemperatureUnit.fahrenheit : ElinkTemperatureUnit.celsius).index;
                  final data = await _elinkProbeSendCmdUtils.switchUnit(unitI);
                  _addLog('switchUnit: ${data.toHex()}');
                  _dataA7Characteristic?.write(data);
                },
                title: 'SwitchUnit(${unit.name})',
              ),
              OperateBtnWidget(
                onPressed: () {
                  final data = _elinkProbeSendCmdUtils.clearProbeInfo();
                  _addLog('clearProbeInfo: ${data.toHex()}');
                  _dataA6Characteristic?.write(data);
                },
                title: 'clearProbeInfo',
              ),
            ],
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
      if (characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkNotifyUuid) || characteristic.uuid.str.equal(ElinkBleCommonUtils.elinkWriteAndNotifyUuid)) {
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
            // LogUtils().log('OnValueReceived [${characteristic.uuid.str}]: ${data.toHex()}, checked: ${ElinkCmdUtils.checkElinkCmdSum(data)}');
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
    _controller.dispose();
    _onReceiveDataSubscription?.cancel();
    _onReceiveDataSubscription1?.cancel();
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}
