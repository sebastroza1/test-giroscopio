package com.example.acv_motion_monitor

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import java.util.UUID

class BleGenericWatchManager(
    messenger: BinaryMessenger,
    private val context: Context
) {
    private var isConnected: Boolean = false
    private var connectedDeviceName: String? = null
    private var bluetoothGatt: BluetoothGatt? = null
    private var heartRateCharacteristic: BluetoothGattCharacteristic? = null
    private var shouldStartHeartRate: Boolean = false

    private val gyroEventSink = BleSafeEventSink()
    private val accelerometerEventSink = BleSafeEventSink()
    private val heartRateEventSink = BleSafeEventSink()

    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                bluetoothGatt = gatt
                isConnected = true
                connectedDeviceName = gatt.device.name
                if (hasBluetoothConnectPermission()) {
                    gatt.discoverServices()
                }
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                isConnected = false
                heartRateCharacteristic = null
                bluetoothGatt?.close()
                bluetoothGatt = null
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                return
            }

            heartRateCharacteristic = gatt
                .getService(HEART_RATE_SERVICE_UUID)
                ?.getCharacteristic(HEART_RATE_MEASUREMENT_UUID)

            if (shouldStartHeartRate) {
                enableHeartRateNotifications()
            }
        }

        override fun onCharacteristicChanged(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
        ) {
            if (characteristic.uuid == HEART_RATE_MEASUREMENT_UUID) {
                emitHeartRate(characteristic)
            }
        }

        override fun onCharacteristicRead(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            status: Int,
        ) {
            if (status == BluetoothGatt.GATT_SUCCESS &&
                characteristic.uuid == HEART_RATE_MEASUREMENT_UUID
            ) {
                emitHeartRate(characteristic)
            }
        }
    }

    init {
        EventChannel(messenger, "acv_motion_monitor/ble/gyro")
            .setStreamHandler(gyroEventSink)
        EventChannel(messenger, "acv_motion_monitor/ble/accelerometer")
            .setStreamHandler(accelerometerEventSink)
        EventChannel(messenger, "acv_motion_monitor/ble/heart_rate")
            .setStreamHandler(heartRateEventSink)
    }

    fun initializeBle(): Boolean {
        return bluetoothAdapter() != null
    }

    fun isBleAvailable(): Boolean {
        val adapter = bluetoothAdapter() ?: return false
        if (!adapter.isEnabled) {
            return false
        }
        return hasBluetoothConnectPermission()
    }

    fun getBleConnectionState(): Map<String, Any> {
        val adapter = bluetoothAdapter()
        val pairedWatch = if (adapter != null && hasBluetoothConnectPermission()) {
            findPairedHuaweiWatch(adapter)
        } else {
            null
        }

        val message = when {
            adapter == null -> "Bluetooth no disponible en este dispositivo"
            !adapter.isEnabled -> "Bluetooth está apagado"
            !hasBluetoothConnectPermission() -> "Falta permiso BLUETOOTH_CONNECT"
            pairedWatch == null -> "No se encontró reloj Huawei emparejado por BLE"
            isConnected -> "Conectado por BLE a ${connectedDeviceName ?: pairedWatch.name}; intentando leer Heart Rate estándar"
            else -> "Huawei detectado por BLE: ${pairedWatch.name}. Puedes leer FC si el reloj expone el servicio estándar"
        }

        return mapOf(
            "available" to isBleAvailable(),
            "connected" to isConnected,
            "provider" to "ble_generic",
            "message" to message,
        )
    }

    @SuppressLint("MissingPermission")
    fun connectBleWatch(): Boolean {
        val adapter = bluetoothAdapter() ?: return false
        if (!adapter.isEnabled || !hasBluetoothConnectPermission()) {
            isConnected = false
            return false
        }

        val device = findPairedHuaweiWatch(adapter) ?: run {
            isConnected = false
            return false
        }

        connectedDeviceName = device.name
        bluetoothGatt?.close()
        bluetoothGatt = device.connectGatt(context, false, gattCallback)
        return true
    }

    fun disconnectBleWatch(): Boolean {
        shouldStartHeartRate = false
        heartRateCharacteristic = null
        bluetoothGatt?.disconnect()
        bluetoothGatt?.close()
        bluetoothGatt = null
        isConnected = false
        return true
    }

    fun startBleGyroscope(): Boolean {
        return false
    }

    fun stopBleGyroscope(): Boolean = true

    fun startBleAccelerometer(): Boolean {
        return false
    }

    fun stopBleAccelerometer(): Boolean = true

    fun startBleHeartRate(): Boolean {
        shouldStartHeartRate = true

        if (!isConnected) {
            return connectBleWatch()
        }

        return enableHeartRateNotifications()
    }

    fun stopBleHeartRate(): Boolean {
        shouldStartHeartRate = false
        val gatt = bluetoothGatt ?: return true
        val characteristic = heartRateCharacteristic ?: return true
        if (!hasBluetoothConnectPermission()) {
            return false
        }

        gatt.setCharacteristicNotification(characteristic, false)
        characteristic
            .getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID)
            ?.apply {
                value = BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE
                gatt.writeDescriptor(this)
            }
        return true
    }

    @SuppressLint("MissingPermission")
    private fun enableHeartRateNotifications(): Boolean {
        val gatt = bluetoothGatt ?: return false
        val characteristic = heartRateCharacteristic ?: return false
        if (!hasBluetoothConnectPermission()) {
            return false
        }

        gatt.setCharacteristicNotification(characteristic, true)
        characteristic
            .getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID)
            ?.apply {
                value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                gatt.writeDescriptor(this)
            }

        gatt.readCharacteristic(characteristic)
        return true
    }

    private fun emitHeartRate(characteristic: BluetoothGattCharacteristic) {
        val data = characteristic.value ?: return
        if (data.isEmpty()) {
            return
        }

        val flags = data[0].toInt()
        val isHeartRateInUInt16 = flags and 0x01 != 0
        val bpm = if (isHeartRateInUInt16 && data.size >= 3) {
            ((data[2].toInt() and 0xFF) shl 8) or (data[1].toInt() and 0xFF)
        } else if (data.size >= 2) {
            data[1].toInt() and 0xFF
        } else {
            return
        }

        heartRateEventSink.send(
            mapOf(
                "bpm" to bpm,
                "source" to "watch_ble",
                "timestamp" to System.currentTimeMillis(),
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

    private fun findPairedHuaweiWatch(adapter: BluetoothAdapter): BluetoothDevice? {
        return adapter.bondedDevices.firstOrNull { device ->
            val name = device.name ?: return@firstOrNull false
            val normalized = name.lowercase()
            normalized.contains("huawei watch") || normalized.contains("watch fit")
        }
    }

    companion object {
        private val HEART_RATE_SERVICE_UUID: UUID =
            UUID.fromString("0000180D-0000-1000-8000-00805F9B34FB")
        private val HEART_RATE_MEASUREMENT_UUID: UUID =
            UUID.fromString("00002A37-0000-1000-8000-00805F9B34FB")
        private val CLIENT_CHARACTERISTIC_CONFIG_UUID: UUID =
            UUID.fromString("00002902-0000-1000-8000-00805F9B34FB")
    }
}

private class BleSafeEventSink : EventChannel.StreamHandler {
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
