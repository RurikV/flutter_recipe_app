import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../presentation/providers/language_provider.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';
import '../services/auth/auth_service.dart';
import '../services/bluetooth_service.dart';
import '../plugins/bluetooth_le_scanner/bluetooth_le_scanner.dart';
import '../data/models/user.dart';
import 'login_screen.dart';

/// A stateless widget representing the profile screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();

      // Check if the context is still valid before using it
      if (context.mounted) {
        // Dispatch logout action to update Redux state
        StoreProvider.of<AppState>(context, listen: false)
            .dispatch(LogoutAction());

        // Navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выходе: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFECECEC), // Background color as per design
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
        backgroundColor: const Color(0xFFECECEC),
        elevation: 0,
      ),
      body: StoreConnector<AppState, _ProfileViewModel>(
        converter: (store) => _ProfileViewModel.fromStore(store),
        builder: (context, viewModel) {
          return OrientationBuilder(
            builder: (context, orientation) {
              return Center(
                child: SizedBox(
                  width: orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // User avatar
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Center(
                            child: Container(
                              width: 123,
                              height: 123,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF165932),
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 96,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // User info card
                        Padding(
                          padding: const EdgeInsets.only(top: 29.0, left: 16.0, right: 16.0),
                          child: Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(26), // 0.1 opacity = 26 alpha (255 * 0.1)
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Логин',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: const Color(0xFF165932),
                                    ),
                                  ),
                                  Text(
                                    viewModel.isAuthenticated ? viewModel.username : 'Не авторизован',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: const Color(0xFF2ECC71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Logout button
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                          child: GestureDetector(
                            onTap: () => _logout(context),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withAlpha(26), // 0.1 opacity = 26 alpha (255 * 0.1)
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Выход',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: const Color(0xFFF54848), // Red color for logout
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Language selection (keeping this from the original)
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            children: [
                              Text(
                                'Язык / Language',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  languageProvider.toggleLanguage();
                                },
                                icon: const Icon(Icons.language),
                                label: Text(
                                  languageProvider.locale.languageCode == 'ru' 
                                      ? 'English' 
                                      : 'Русский',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24, 
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bluetooth devices section
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: BluetoothDevicesSection(),
                        ),

                        // Add some bottom padding
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ViewModel for the ProfileScreen
class _ProfileViewModel {
  final bool isAuthenticated;
  final String username;

  _ProfileViewModel({
    required this.isAuthenticated,
    required this.username,
  });

  // Factory method to create a ViewModel from the Redux store
  static _ProfileViewModel fromStore(store) {
    final User? user = store.state.user;
    return _ProfileViewModel(
      isAuthenticated: store.state.isAuthenticated,
      username: user?.login ?? '',
    );
  }
}

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
      });
    } else {
      if (!_isBluetoothEnabled) {
        final enabled = await _bluetoothService.requestBluetoothEnable();
        setState(() {
          _isBluetoothEnabled = enabled;
        });
        if (!enabled) return;
      }

      final result = await _bluetoothService.startScan();
      setState(() {
        _isScanning = result;
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
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4, 
                        horizontal: 16,
                      ),
                      child: ListTile(
                        title: Text(device.name),
                        subtitle: Text('ID: ${device.id}'),
                        trailing: Text(
                          'RSSI: ${device.rssi} dBm',
                          style: TextStyle(
                            color: device.rssi > -80 
                                ? Colors.green 
                                : Colors.orange,
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
}
