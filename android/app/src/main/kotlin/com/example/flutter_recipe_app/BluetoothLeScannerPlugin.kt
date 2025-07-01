package com.example.flutter_recipe_app

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class BluetoothLeScannerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothLeScanner: BluetoothLeScanner? = null
    private var scanning = false
    private val handler = Handler(Looper.getMainLooper())
    
    // Stops scanning after 10 seconds
    private val SCAN_PERIOD: Long = 10000
    
    // Request codes
    private val REQUEST_ENABLE_BT = 1
    private val REQUEST_FINE_LOCATION = 2
    private val REQUEST_BLUETOOTH_SCAN = 3
    private val REQUEST_BLUETOOTH_CONNECT = 4
    
    // Discovered devices
    private val discoveredDevices = mutableMapOf<String, DeviceInfo>()
    
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.recipe_app/bluetooth_le_scanner")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        
        // Initialize Bluetooth adapter
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner
    }
    
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
    
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }
    
    override fun onDetachedFromActivity() {
        activity = null
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                initialize(result)
            }
            "startScan" -> {
                startScan(result)
            }
            "stopScan" -> {
                stopScan(result)
            }
            "isBluetoothEnabled" -> {
                result.success(bluetoothAdapter?.isEnabled ?: false)
            }
            "requestBluetoothEnable" -> {
                requestBluetoothEnable(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun initialize(result: Result) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device", null)
            return
        }
        
        result.success(true)
    }
    
    private fun startScan(result: Result) {
        activity?.let { activity ->
            // Check if Bluetooth is enabled
            if (bluetoothAdapter == null || !bluetoothAdapter!!.isEnabled) {
                result.error("BLUETOOTH_DISABLED", "Bluetooth is disabled", null)
                return
            }
            
            // Check for required permissions
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.BLUETOOTH_SCAN), REQUEST_BLUETOOTH_SCAN)
                    result.error("PERMISSION_DENIED", "Bluetooth scan permission not granted", null)
                    return
                }
                
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.BLUETOOTH_CONNECT), REQUEST_BLUETOOTH_CONNECT)
                    result.error("PERMISSION_DENIED", "Bluetooth connect permission not granted", null)
                    return
                }
            } else {
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), REQUEST_FINE_LOCATION)
                    result.error("PERMISSION_DENIED", "Location permission not granted", null)
                    return
                }
            }
            
            // Clear previously discovered devices
            discoveredDevices.clear()
            
            // Start scanning
            if (!scanning) {
                // Stop scanning after a predefined scan period
                handler.postDelayed({
                    if (scanning) {
                        scanning = false
                        bluetoothLeScanner?.stopScan(leScanCallback)
                    }
                }, SCAN_PERIOD)
                
                scanning = true
                bluetoothLeScanner?.startScan(leScanCallback)
                result.success(true)
            } else {
                result.success(false)
            }
        } ?: run {
            result.error("ACTIVITY_UNAVAILABLE", "Activity is not available", null)
        }
    }
    
    private fun stopScan(result: Result) {
        if (scanning) {
            scanning = false
            bluetoothLeScanner?.stopScan(leScanCallback)
            result.success(true)
        } else {
            result.success(false)
        }
    }
    
    private fun requestBluetoothEnable(result: Result) {
        activity?.let { activity ->
            if (bluetoothAdapter == null) {
                result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device", null)
                return
            }
            
            if (!bluetoothAdapter!!.isEnabled) {
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (ContextCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
                        activity.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT)
                        result.success(true)
                    } else {
                        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.BLUETOOTH_CONNECT), REQUEST_BLUETOOTH_CONNECT)
                        result.error("PERMISSION_DENIED", "Bluetooth connect permission not granted", null)
                    }
                } else {
                    activity.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT)
                    result.success(true)
                }
            } else {
                result.success(true)
            }
        } ?: run {
            result.error("ACTIVITY_UNAVAILABLE", "Activity is not available", null)
        }
    }
    
    // Device scan callback
    private val leScanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            super.onScanResult(callbackType, result)
            
            val device = result.device
            val deviceName = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
                    device.name ?: "Unknown Device"
                } else {
                    "Unknown Device"
                }
            } else {
                device.name ?: "Unknown Device"
            }
            
            val deviceInfo = DeviceInfo(
                id = device.address,
                name = deviceName,
                rssi = result.rssi
            )
            
            discoveredDevices[device.address] = deviceInfo
            
            // Send the updated list of devices to Flutter
            sendDeviceList()
        }
    }
    
    private fun sendDeviceList() {
        val devicesList = discoveredDevices.values.map {
            mapOf(
                "id" to it.id,
                "name" to it.name,
                "rssi" to it.rssi
            )
        }
        
        handler.post {
            channel.invokeMethod("onScanResult", devicesList)
        }
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        when (requestCode) {
            REQUEST_FINE_LOCATION, REQUEST_BLUETOOTH_SCAN, REQUEST_BLUETOOTH_CONNECT -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Permission granted, try to start scan again
                    handler.post {
                        startScan(object : Result {
                            override fun success(result: Any?) {}
                            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
                            override fun notImplemented() {}
                        })
                    }
                    return true
                }
            }
        }
        return false
    }
    
    // Data class to hold device information
    data class DeviceInfo(
        val id: String,
        val name: String,
        val rssi: Int
    )
}