import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../plugins/bluetooth_le_scanner/bluetooth_le_scanner.dart';
import '../../../../services/bluetooth_service.dart';

/// A stateful widget that displays available Bluetooth LE devices.
class BluetoothDevicesSection extends StatefulWidget {
  const BluetoothDevicesSection({super.key});

  @override
  State<BluetoothDevicesSection> createState() => _BluetoothDevicesSectionState();
}

class _BluetoothDevicesSectionState extends State<BluetoothDevicesSection> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isBluetoothEnabled = false;
  String? _errorMessage;
  late BluetoothService _bluetoothService;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    _checkBluetoothStatus();

    // Subscribe to scan results
    _scanResultsSubscription = _bluetoothService.scanResults.listen((devices) {
      setState(() {
        _devices = devices;
      });
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _bluetoothService.stopScan();
    super.dispose();
  }

  Future<void> _checkBluetoothStatus() async {
    final isEnabled = await _bluetoothService.isBluetoothEnabled();
    setState(() {
      _isBluetoothEnabled = isEnabled;
    });
  }

  Future<void> _toggleScan() async {
    if (_isScanning) {
      final result = await _bluetoothService.stopScan();
      setState(() {
        _isScanning = !result;
        _errorMessage = null; // Clear error message when stopping scan
      });
    } else {
      setState(() {
        _errorMessage = null; // Clear previous error messages
      });

      if (!_isBluetoothEnabled) {
        final enabled = await _bluetoothService.requestBluetoothEnable();
        setState(() {
          _isBluetoothEnabled = enabled;
        });
        if (!enabled) {
          setState(() {
            _errorMessage = 'Bluetooth должен быть включен для сканирования устройств';
          });
          return;
        }
      }

      final result = await _bluetoothService.startScan();
      setState(() {
        _isScanning = result.success;
        if (!result.success) {
          _errorMessage = result.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Доступные Bluetooth устройства',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Bluetooth status and scan button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bluetooth: ${_isBluetoothEnabled ? 'Включен' : 'Выключен'}',
              style: TextStyle(
                color: _isBluetoothEnabled ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _toggleScan,
              icon: Icon(_isScanning ? Icons.stop : Icons.search),
              label: Text(_isScanning ? 'Остановить' : 'Сканировать'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Error message display
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Devices list
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: _devices.isEmpty
              ? Center(
                  child: Text(
                    _isScanning 
                        ? 'Сканирование...' 
                        : 'Нет доступных устройств',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          Icons.bluetooth,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          device.name.isNotEmpty ? device.name : 'Unknown Device',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${device.id}'),
                            Text('RSSI: ${device.rssi} dBm'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSignalStrengthColor(device.rssi),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getSignalStrengthText(device.rssi),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getSignalStrengthColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  String _getSignalStrengthText(int rssi) {
    if (rssi >= -50) return 'Сильный';
    if (rssi >= -70) return 'Средний';
    return 'Слабый';
  }
}
