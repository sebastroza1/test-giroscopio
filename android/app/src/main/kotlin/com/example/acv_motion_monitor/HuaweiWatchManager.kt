package com.example.acv_motion_monitor

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class HuaweiWatchManager(
    messenger: BinaryMessenger,
    private val context: Context
) {
    private var isConnected: Boolean = false

    private val gyroEventSink = SafeEventSink()
    private val accelerometerEventSink = SafeEventSink()
    private val heartRateEventSink = SafeEventSink()

    init {
        EventChannel(messenger, "acv_motion_monitor/huawei/gyro")
            .setStreamHandler(gyroEventSink)
        EventChannel(messenger, "acv_motion_monitor/huawei/accelerometer")
            .setStreamHandler(accelerometerEventSink)
        EventChannel(messenger, "acv_motion_monitor/huawei/heart_rate")
            .setStreamHandler(heartRateEventSink)
    }

    fun initializeHuawei(): Boolean {
        val adapter = bluetoothAdapter()
        return adapter != null
    }

    fun isHuaweiAvailable(): Boolean {
        val adapter = bluetoothAdapter() ?: return false
        if (!adapter.isEnabled) {
            return false
        }

        if (!hasBluetoothConnectPermission()) {
            return false
        }

        return true
    }

    fun getHuaweiConnectionState(): Map<String, Any> {
        val adapter = bluetoothAdapter()
        val available = isHuaweiAvailable()
        val pairedWatchName = if (available) findPairedHuaweiWatchName(adapter) else null

        if (pairedWatchName != null) {
            isConnected = true
        }

        val message = when {
            adapter == null -> "Bluetooth no disponible en este dispositivo"
            !adapter.isEnabled -> "Bluetooth está apagado"
            !hasBluetoothConnectPermission() -> "Falta permiso BLUETOOTH_CONNECT"
            pairedWatchName != null -> "Huawei detectado por Bluetooth: $pairedWatchName. Para sensores aún falta integrar Wear Engine/Health Kit."
            else -> "No se encontró un reloj Huawei emparejado"
        }

        return mapOf(
            "available" to available,
            "connected" to isConnected,
            "provider" to "huawei",
            "message" to message
        )
    }

    fun connectHuawei(): Boolean {
        val adapter = bluetoothAdapter()
        if (adapter == null || !adapter.isEnabled || !hasBluetoothConnectPermission()) {
            isConnected = false
            return false
        }

        val pairedWatchName = findPairedHuaweiWatchName(adapter)
        isConnected = pairedWatchName != null
        return isConnected
    }

    fun disconnectHuawei(): Boolean {
        isConnected = false
        return true
    }

    fun startHuaweiGyroscope(): Boolean {
        // TODO: Integración real con Huawei Health Kit/HMS para datos de sensores en vivo.
        return false
    }

    fun stopHuaweiGyroscope(): Boolean {
        return true
    }

    fun startHuaweiAccelerometer(): Boolean {
        // TODO: Integración real con Huawei Health Kit/HMS para acelerómetro.
        return false
    }

    fun stopHuaweiAccelerometer(): Boolean {
        return true
    }

    fun startHuaweiHeartRate(): Boolean {
        // TODO: Integración real con Huawei Health Kit/HMS para ritmo cardiaco.
        return false
    }

    fun stopHuaweiHeartRate(): Boolean {
        return true
    }

    fun onHuaweiGyroData(x: Double, y: Double, z: Double) {
        gyroEventSink.send(
            mapOf(
                "x" to x,
                "y" to y,
                "z" to z,
                "source" to "watch_huawei",
                "sensorType" to "gyroscope",
                "timestamp" to System.currentTimeMillis()
            )
        )
    }

    fun onHuaweiAccelerometerData(x: Double, y: Double, z: Double) {
        accelerometerEventSink.send(
            mapOf(
                "x" to x,
                "y" to y,
                "z" to z,
                "source" to "watch_huawei",
                "sensorType" to "accelerometer",
                "timestamp" to System.currentTimeMillis()
            )
        )
    }

    fun onHuaweiHeartRateData(bpm: Int) {
        heartRateEventSink.send(
            mapOf(
                "bpm" to bpm,
                "source" to "watch_huawei",
                "timestamp" to System.currentTimeMillis()
            )
        )
    }

    private fun bluetoothAdapter(): BluetoothAdapter? {
        val manager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        return manager?.adapter
    }

    private fun hasBluetoothConnectPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }
        return context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun findPairedHuaweiWatchName(adapter: BluetoothAdapter?): String? {
        if (adapter == null || !hasBluetoothConnectPermission()) {
            return null
        }

        return adapter.bondedDevices
            .firstOrNull { device ->
                val name = device.name ?: return@firstOrNull false
                val normalized = name.lowercase()
                normalized.contains("huawei watch") || normalized.contains("watch fit")
            }
            ?.name
    }
}

private class SafeEventSink : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun send(payload: Any) {
        eventSink?.success(payload)
    }
}
