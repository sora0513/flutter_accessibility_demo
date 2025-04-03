import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final List<BluetoothDevice> devicesList = [];
  final Map<String, bool> connectedDevices = {}; // デバイスIDと接続状態のマップ
  final TextEditingController _commandController = TextEditingController();
  BluetoothDevice? _selectedDevice; // 現在選択されているデバイス
  BluetoothCharacteristic? _writeCharacteristic; // 書き込み用キャラクタリスティック
  bool _isScanning = false;

  // サブスクリプション管理用
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    // スキャン結果のリスナーを設定
    _subscriptions.add(FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          setState(() {
            devicesList.add(result.device);
            // 接続状態を初期化
            connectedDevices[result.device.remoteId.str] = false;
          });
          // デバイスごとに接続状態を監視
          _monitorDeviceConnectionState(result.device);
        }
      }
    }));

    // スキャン状態のリスナーを設定
    _subscriptions.add(FlutterBluePlus.isScanning.listen((isScanning) {
      setState(() {
        _isScanning = isScanning;
      });
    }));

    // 接続状態の初期チェック
    _checkConnectedDevices();
  }

  // デバイスごとの接続状態を監視
  void _monitorDeviceConnectionState(BluetoothDevice device) {
    _subscriptions
        .add(device.connectionState.listen((BluetoothConnectionState state) {
      setState(() {
        connectedDevices[device.remoteId.str] =
            state == BluetoothConnectionState.connected;
        if (state != BluetoothConnectionState.connected &&
            _selectedDevice?.remoteId.str == device.remoteId.str) {
          _selectedDevice = null;
          _writeCharacteristic = null;
        }
      });
    }));
  }

  // 接続済みデバイスの確認
  void _checkConnectedDevices() async {
    try {
      List<BluetoothDevice> connectedDevicesList =
          FlutterBluePlus.connectedDevices;
      for (BluetoothDevice device in connectedDevicesList) {
        setState(() {
          connectedDevices[device.remoteId.str] = true;
          if (!devicesList.contains(device)) {
            devicesList.add(device);
            _monitorDeviceConnectionState(device);
          }
        });
      }
    } catch (e) {
      debugPrint('接続デバイスの確認エラー: $e');
    }
  }

  @override
  void dispose() {
    // すべてのサブスクリプションをキャンセル
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _commandController.dispose();
    super.dispose();
  }

  // スキャン開始
  void _startScan() async {
    setState(() {
      devicesList.clear();
      connectedDevices.clear();
    });

    // 既存の接続デバイスを先に取得
    _checkConnectedDevices();

    // 新しいデバイスをスキャン
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('スキャンエラー: $e')),
        );
      }
    }
  }

  // スキャン停止
  void _stopScan() {
    FlutterBluePlus.stopScan();
  }

  // デバイスに接続
  void _connect(BluetoothDevice device) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${device.platformName.isNotEmpty ? device.platformName : 'デバイス'}に接続中...')),
        );
      }

      await device.connect();

      if (mounted) {
        setState(() {
          connectedDevices[device.remoteId.str] = true;
          _selectedDevice = device;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${device.platformName.isNotEmpty ? device.platformName : 'デバイス'}に接続しました')),
        );
      }

      // サービスとキャラクタリスティックを探す
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          // 書き込み可能なキャラクタリスティックを探す
          if (characteristic.properties.write) {
            if (mounted) {
              setState(() {
                _writeCharacteristic = characteristic;
              });
            }
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('接続エラー: $e')),
        );
      }
    }
  }

  // デバイスから切断
  void _disconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();

      if (mounted) {
        setState(() {
          connectedDevices[device.remoteId.str] = false;
          if (_selectedDevice?.remoteId.str == device.remoteId.str) {
            _selectedDevice = null;
            _writeCharacteristic = null;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${device.platformName.isNotEmpty ? device.platformName : 'デバイス'}から切断しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('切断エラー: $e')),
        );
      }
    }
  }

  // コマンド送信
  void _sendCommand() async {
    if (_selectedDevice == null || _writeCharacteristic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('デバイスに接続してください')),
      );
      return;
    }

    final command = _commandController.text.trim();
    if (command.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コマンドを入力してください')),
      );
      return;
    }

    try {
      // UTF-8エンコードでデータ送信
      List<int> data = utf8.encode(command);
      await _writeCharacteristic!.write(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('コマンド送信: $command')),
        );
      }

      // 送信後にテキストフィールドをクリア
      _commandController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('送信エラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // スキャンボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('デバイスをスキャン'),
                  onPressed: _isScanning ? null : _startScan,
                ),
                if (_isScanning)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('スキャンを停止'),
                    onPressed: _stopScan,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
              ],
            ),
          ),

          // スキャン中のインジケーター
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // デバイスリスト
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = devicesList[index];
                bool isConnected =
                    connectedDevices[device.remoteId.str] ?? false;

                return ListTile(
                  title: Text(device.platformName.isNotEmpty
                      ? device.platformName
                      : 'Unknown Device'),
                  subtitle: Text(device.remoteId.str),
                  trailing: isConnected
                      ? ElevatedButton(
                          onPressed: () => _disconnect(device),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          child: const Text('切断'),
                        )
                      : ElevatedButton(
                          child: const Text('接続'),
                          onPressed: () => _connect(device),
                        ),
                  // 選択状態を表示
                  selected:
                      _selectedDevice?.remoteId.str == device.remoteId.str,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  onTap: () {
                    if (isConnected) {
                      setState(() {
                        _selectedDevice = device;
                      });
                    }
                  },
                );
              },
            ),
          ),

          // コマンド入力エリア
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(thickness: 1),
                Text(
                  '選択中のデバイス: ${_selectedDevice != null ? (_selectedDevice!.platformName.isNotEmpty ? _selectedDevice!.platformName : 'Unknown Device') : "なし"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commandController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'コマンド',
                          hintText: 'ここにコマンドを入力',
                          isDense: true,
                        ),
                        enabled: _selectedDevice != null &&
                            _writeCharacteristic != null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _selectedDevice != null &&
                              _writeCharacteristic != null
                          ? _sendCommand
                          : null,
                      child: const Text('送信'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
