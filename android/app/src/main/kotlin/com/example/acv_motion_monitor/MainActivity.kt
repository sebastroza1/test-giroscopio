package com.example.acv_motion_monitor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var huaweiWatchManager: HuaweiWatchManager
    private lateinit var wearOsWatchManager: WearOsWatchManager
    private lateinit var bleGenericWatchManager: BleGenericWatchManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        huaweiWatchManager = HuaweiWatchManager(flutterEngine.dartExecutor.binaryMessenger, this)
        wearOsWatchManager = WearOsWatchManager(flutterEngine.dartExecutor.binaryMessenger, this)
        bleGenericWatchManager = BleGenericWatchManager(flutterEngine.dartExecutor.binaryMessenger, this)

        registerHuaweiChannel(flutterEngine)
        registerWearOsChannel(flutterEngine)
        registerBleChannel(flutterEngine)
    }

    private fun registerHuaweiChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "acv_motion_monitor/huawei/methods"
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initializeHuawei" -> result.success(huaweiWatchManager.initializeHuawei())
                    "isHuaweiAvailable" -> result.success(huaweiWatchManager.isHuaweiAvailable())
                    "getHuaweiConnectionState" -> result.success(huaweiWatchManager.getHuaweiConnectionState())
                    "connectHuawei" -> result.success(huaweiWatchManager.connectHuawei())
                    "disconnectHuawei" -> result.success(huaweiWatchManager.disconnectHuawei())
                    "startHuaweiGyroscope" -> result.success(huaweiWatchManager.startHuaweiGyroscope())
                    "stopHuaweiGyroscope" -> result.success(huaweiWatchManager.stopHuaweiGyroscope())
                    "startHuaweiAccelerometer" -> result.success(huaweiWatchManager.startHuaweiAccelerometer())
                    "stopHuaweiAccelerometer" -> result.success(huaweiWatchManager.stopHuaweiAccelerometer())
                    "startHuaweiHeartRate" -> result.success(huaweiWatchManager.startHuaweiHeartRate())
                    "stopHuaweiHeartRate" -> result.success(huaweiWatchManager.stopHuaweiHeartRate())
                    else -> result.notImplemented()
                }
            } catch (ex: Exception) {
                // Protección para evitar crash cuando la integración nativa todavía está incompleta.
                result.success(false)
            }
        }
    }

    private fun registerWearOsChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "acv_motion_monitor/wearos/methods"
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initializeWearOs" -> result.success(wearOsWatchManager.initializeWearOs())
                    "isWearOsAvailable" -> result.success(wearOsWatchManager.isWearOsAvailable())
                    "getWearOsConnectionState" -> result.success(wearOsWatchManager.getWearOsConnectionState())
                    "connectWearOs" -> result.success(wearOsWatchManager.connectWearOs())
                    "disconnectWearOs" -> result.success(wearOsWatchManager.disconnectWearOs())
                    "startWearOsGyroscope" -> result.success(wearOsWatchManager.startWearOsGyroscope())
                    "stopWearOsGyroscope" -> result.success(wearOsWatchManager.stopWearOsGyroscope())
                    "startWearOsAccelerometer" -> result.success(wearOsWatchManager.startWearOsAccelerometer())
                    "stopWearOsAccelerometer" -> result.success(wearOsWatchManager.stopWearOsAccelerometer())
                    "startWearOsHeartRate" -> result.success(wearOsWatchManager.startWearOsHeartRate())
                    "stopWearOsHeartRate" -> result.success(wearOsWatchManager.stopWearOsHeartRate())
                    else -> result.notImplemented()
                }
            } catch (ex: Exception) {
                result.success(false)
            }
        }
    }

    private fun registerBleChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "acv_motion_monitor/ble/methods"
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initializeBle" -> result.success(bleGenericWatchManager.initializeBle())
                    "isBleAvailable" -> result.success(bleGenericWatchManager.isBleAvailable())
                    "getBleConnectionState" -> result.success(bleGenericWatchManager.getBleConnectionState())
                    "connectBleWatch" -> result.success(bleGenericWatchManager.connectBleWatch())
                    "disconnectBleWatch" -> result.success(bleGenericWatchManager.disconnectBleWatch())
                    "startBleGyroscope" -> result.success(bleGenericWatchManager.startBleGyroscope())
                    "stopBleGyroscope" -> result.success(bleGenericWatchManager.stopBleGyroscope())
                    "startBleAccelerometer" -> result.success(bleGenericWatchManager.startBleAccelerometer())
                    "stopBleAccelerometer" -> result.success(bleGenericWatchManager.stopBleAccelerometer())
                    "startBleHeartRate" -> result.success(bleGenericWatchManager.startBleHeartRate())
                    "stopBleHeartRate" -> result.success(bleGenericWatchManager.stopBleHeartRate())
                    else -> result.notImplemented()
                }
            } catch (ex: Exception) {
                result.success(false)
            }
        }
    }
}
