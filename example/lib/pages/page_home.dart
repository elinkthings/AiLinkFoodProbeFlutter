import 'dart:convert';

import 'package:ailink/ailink.dart';
import 'package:ailink/model/body_fat_data.dart';
import 'package:ailink/model/elink_ble_data.dart';
import 'package:ailink/model/param_body_fat_data.dart';
import 'package:ailink/utils/ble_common_util.dart';
import 'package:ailink/utils/broadcast_scale_data_utils.dart';
import 'package:ailink/utils/common_extensions.dart';
import 'package:ailink/utils/elink_broadcast_data_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_cmd_utils.dart';
import 'package:ailink_food_probe/utils/elink_probe_config.dart';
import 'package:ailink_food_probe_example/model/connect_device_model.dart';
import 'package:ailink_food_probe_example/utils/constants.dart';
import 'package:ailink_food_probe_example/utils/log_utils.dart';
import 'package:ailink_food_probe_example/widgets/widget_ble_state.dart';
import 'package:ailink_food_probe_example/widgets/widget_operate_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ailinkPlugin = Ailink();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AiLink Food Prob example app'),
          actions: const [
            BleStateWidget(),
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildNotSupportedWidget,
              _buildOperatorWidget,
              Expanded(child: _buildScanResultWidget)
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildNotSupportedWidget => FutureBuilder<bool>(
        future: FlutterBluePlus.isSupported,
        builder: (context, snapshot) {
          return Visibility(
            visible: !(snapshot.hasData && snapshot.data == true),
            child: const Text(
              'Bluetooth is not supported',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          );
        },
      );

  Widget get _buildOperatorWidget => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Builder(builder: (context) {
            return OperateBtnWidget(
              title: 'Scan',
              onPressed: () => FlutterBluePlus.startScan(withServices: [
                ///Filter specified scales by serviceUUID
                Guid(ElinkBleCommonUtils.elinkBroadcastDeviceUuid),
                Guid(ElinkBleCommonUtils.elinkConnectDeviceUuid)
              ]).onError((error, stackTrace) {
                LogUtils().log('startScan error: ${error.toString()}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(prettyException(error)),
                    backgroundColor: Colors.red,
                  ),
                );
              }),
            );
          }),
          OperateBtnWidget(
            title: 'StopScan',
            onPressed: () async => await FlutterBluePlus.stopScan(),
          ),
        ],
      );

  Widget get _buildScanResultWidget => StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.onScanResults,
        builder: (context, snapshot) {
          final List<ScanResult> list = snapshot.hasData ? (snapshot.data ?? []) : [];
          list.sort((a, b) => b.rssi.compareTo(a.rssi));
          final probeList = list.where((element) {
            List<int> manufacturerData = ElinkBroadcastDataUtils.getManufacturerData(element.advertisementData.manufacturerData);
            final uuids = element.advertisementData.serviceUuids.map((uuid) => uuid.str.toUpperCase()).toList();
            final isBroadcastDevice = ElinkBleCommonUtils.isBroadcastDevice(uuids);
            LogUtils().log('manufacturerData: ${manufacturerData.toHex()}');
            final elinkBleData = ElinkBroadcastDataUtils.getElinkBleData(manufacturerData, isBroadcastDevice: isBroadcastDevice);
            LogUtils().log('elinkBleData: ${elinkBleData.cidArr.toHex()}');
            return ElinkProbeConfig.isProbeAndBox(elinkBleData.cidArr);
          }).toList(); // 过滤掉不是充电盒子的设备
          return ListView.separated(
            itemCount: probeList.length,
            itemBuilder: (context, index) {
              List<int> manufacturerData = ElinkBroadcastDataUtils.getManufacturerData(probeList[index].advertisementData.manufacturerData);
              final uuids = probeList[index].advertisementData.serviceUuids.map((uuid) => uuid.str.toUpperCase()).toList();
              final isBroadcastDevice = ElinkBleCommonUtils.isBroadcastDevice(uuids);
              final elinkBleData = ElinkBroadcastDataUtils.getElinkBleData(manufacturerData, isBroadcastDevice: isBroadcastDevice);
              return ListTile(
                title: Text(
                  probeList[index].device.advName.isEmpty
                      ? 'Unknown'
                      : probeList[index].device.advName,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAC: ${elinkBleData.mac}',
                    ),
                    Text(
                      'CID: ${elinkBleData.cidStr}(${elinkBleData.cid}), VID: ${elinkBleData.vidStr}(${elinkBleData.vid}), PID: ${elinkBleData.pidStr}(${elinkBleData.pid})',
                    ),
                    Text(
                      'UUIDs: ${uuids.join(', ').toUpperCase()}',
                    ),
                    Text(
                      'Data: ${manufacturerData.toHex()}',
                    ),
                    isBroadcastDevice
                        ? _buildBroadcastWidget(manufacturerData)
                        : _buildConnectDeviceWidget(probeList[index], elinkBleData),
                  ],
                ),
                trailing: Text(
                  probeList[index].rssi.toString(),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                height: 0.5,
                color: Colors.grey,
              );
            },
          );
        },
      );

  Widget _buildBroadcastWidget(List<int> manufacturerData) {
    return FutureBuilder(
      future: _ailinkPlugin.decryptBroadcast(
        Uint8List.fromList(manufacturerData),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final weightData = BroadcastScaleDataUtils().getWeightData(snapshot.data);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ParseResult: ${snapshot.data?.toHex()}',
              ),
              Text('Status: ${weightData?.statusStr}'),
              Text('Impedance value: ${weightData?.adc}'),
              Text(
                'WeightData: ${weightData?.weightStr} ${weightData?.weightUnitStr}',
              ),
              weightData == null || weightData.isAdcError == true
                  ? Container()
                  : FutureBuilder(
                      future: _ailinkPlugin.getBodyFatData(ParamBodyFatData(double.parse(weightData.weightStr), weightData.adc, 0, 34, 170, weightData.algorithmId).toJson()),
                      builder: (context, snapshot) {
                        if (weightData.status == 0xFF) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Text(
                              'BodyFatData: ${BodyFatData.fromJson(json.decode(snapshot.data!)).toJson()}',
                            );
                          }
                        }
                        return Container();
                      },
                    )
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildConnectDeviceWidget(ScanResult scanResult, ElinkBleData bleData) {
    final device = scanResult.device;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            FlutterBluePlus.stopScan();
            Navigator.pushNamed(context, ElinkProbeConfig.isCidProbe(bleData.cidArr) ? page_probe_devce : page_probe_box_device, arguments: ConnectDeviceModel(device: device, bleData: bleData));
          },
          child: Container(
            color: Colors.black,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                'Connect',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
      ],
    );
  }

  String prettyException(dynamic e) {
    if (e is FlutterBluePlusException) {
      return "${e.description}";
    } else if (e is PlatformException) {
      return "${e.message}";
    }
    return e.toString();
  }
}
