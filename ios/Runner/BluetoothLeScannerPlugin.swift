import Flutter
import UIKit
import CoreBluetooth

public class BluetoothLeScannerPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate {
    private var channel: FlutterMethodChannel?
    private var centralManager: CBCentralManager?
    private var discoveredDevices: [CBPeripheral] = []
    private var isScanning = false
    private var scanTimer: Timer?
    private let scanPeriod: TimeInterval = 10.0 // 10 seconds scan period

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.recipe_app/bluetooth_le_scanner", binaryMessenger: registrar.messenger())
        let instance = BluetoothLeScannerPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "startScan":
            startScan(result: result)
        case "stopScan":
            stopScan(result: result)
        case "isBluetoothEnabled":
            isBluetoothEnabled(result: result)
        case "requestBluetoothEnable":
            requestBluetoothEnable(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(result: @escaping FlutterResult) {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        result(true)
    }

    private func startScan(result: @escaping FlutterResult) {
        guard let centralManager = centralManager else {
            result(FlutterError(code: "BLUETOOTH_UNAVAILABLE", message: "Bluetooth is not available", details: nil))
            return
        }

        guard centralManager.state == .poweredOn else {
            result(FlutterError(code: "BLUETOOTH_DISABLED", message: "Bluetooth is disabled", details: nil))
            return
        }

        if isScanning {
            result(false)
            return
        }

        // Clear previously discovered devices
        discoveredDevices.removeAll()

        // Start scanning
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])

        // Stop scanning after scan period
        scanTimer = Timer.scheduledTimer(withTimeInterval: scanPeriod, repeats: false) { [weak self] _ in
            self?.stopScanInternal()
        }

        result(true)
    }

    private func stopScan(result: @escaping FlutterResult) {
        if isScanning {
            stopScanInternal()
            result(true)
        } else {
            result(false)
        }
    }

    private func stopScanInternal() {
        guard let centralManager = centralManager, isScanning else { return }

        isScanning = false
        centralManager.stopScan()
        scanTimer?.invalidate()
        scanTimer = nil
    }

    private func isBluetoothEnabled(result: @escaping FlutterResult) {
        guard let centralManager = centralManager else {
            result(false)
            return
        }
        result(centralManager.state == .poweredOn)
    }

    private func requestBluetoothEnable(result: @escaping FlutterResult) {
        // On iOS, we cannot programmatically enable Bluetooth
        // We can only check the state and inform the user
        guard let centralManager = centralManager else {
            result(FlutterError(code: "BLUETOOTH_UNAVAILABLE", message: "Bluetooth is not available", details: nil))
            return
        }

        if centralManager.state == .poweredOn {
            result(true)
        } else {
            result(FlutterError(code: "BLUETOOTH_DISABLED", message: "Please enable Bluetooth in Settings", details: nil))
        }
    }

    private func sendDeviceList() {
        let deviceList = discoveredDevices.map { peripheral in
            return [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": 0 // RSSI will be updated in didDiscover method
            ] as [String: Any]
        }

        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("onScanResult", arguments: deviceList)
        }
    }

    // MARK: - CBCentralManagerDelegate

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Handle state changes if needed
        print("Bluetooth state changed to: \(central.state.rawValue)")
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Add discovered device if not already in the list
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)

            // Send individual device result
            let deviceData: [String: Any] = [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": RSSI.intValue
            ]

            DispatchQueue.main.async { [weak self] in
                self?.channel?.invokeMethod("onScanResult", arguments: [deviceData])
            }
        }
    }
}
