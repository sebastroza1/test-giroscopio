import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../../../core/models/heart_rate_sample.dart';
import '../../../../core/models/vector3_sample.dart';
import '../../../../core/models/watch_connection_state.dart';
import '../../domain/services/watch_provider.dart';

class BleGenericWatchProvider implements WatchProvider {
  static const MethodChannel _methodChannel =
      MethodChannel('acv_motion_monitor/ble/methods');
  static const EventChannel _gyroChannel =
      EventChannel('acv_motion_monitor/ble/gyro');
  static const EventChannel _accelChannel =
      EventChannel('acv_motion_monitor/ble/accelerometer');
  static const EventChannel _heartRateChannel =
      EventChannel('acv_motion_monitor/ble/heart_rate');

  final Logger _logger;

  BleGenericWatchProvider(this._logger);

  @override
  String get providerName => 'ble_generic';

  @override
  Future<void> initialize() async {
    try {
      await _methodChannel.invokeMethod<void>('initializeBle');
    } catch (e) {
      _logger.w('initializeBle falló: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isBleAvailable') ?? false;
    } catch (e) {
      _logger.w('isBleAvailable falló: $e');
      return false;
    }
  }

  @override
  Future<WatchConnectionState> getConnectionState() async {
    try {
      final response =
          await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getBleConnectionState');
      if (response == null) {
        return WatchConnectionState.initial(providerName);
      }
      return WatchConnectionState.fromMap(response);
    } catch (e) {
      _logger.w('getBleConnectionState falló: $e');
      return WatchConnectionState(
        available: false,
        connected: false,
        provider: providerName,
        message: 'BLE no implementado aún',
      );
    }
  }

  @override
  Future<void> connect() async {
    try {
      await _methodChannel.invokeMethod<void>('connectBleWatch');
    } catch (e) {
      _logger.w('connectBleWatch falló: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod<void>('disconnectBleWatch');
    } catch (e) {
      _logger.w('disconnectBleWatch falló: $e');
    }
  }

  @override
  Stream<Vector3Sample> get watchGyroscopeStream {
    return _gyroChannel.receiveBroadcastStream().map(
      (event) => Vector3Sample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) => _logger.w('stream gyro BLE falló: $error'));
  }

  @override
  Stream<Vector3Sample> get watchAccelerometerStream {
    return _accelChannel.receiveBroadcastStream().map(
      (event) => Vector3Sample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) => _logger.w('stream accel BLE falló: $error'));
  }

  @override
  Stream<HeartRateSample> get watchHeartRateStream {
    return _heartRateChannel.receiveBroadcastStream().map(
      (event) => HeartRateSample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) => _logger.w('stream HR BLE falló: $error'));
  }

  @override
  Future<void> startGyroscope() async {
    try {
      await _methodChannel.invokeMethod<void>('startBleGyroscope');
    } catch (e) {
      _logger.w('startBleGyroscope falló: $e');
    }
  }

  @override
  Future<void> stopGyroscope() async {
    try {
      await _methodChannel.invokeMethod<void>('stopBleGyroscope');
    } catch (e) {
      _logger.w('stopBleGyroscope falló: $e');
    }
  }

  @override
  Future<void> startAccelerometer() async {
    try {
      await _methodChannel.invokeMethod<void>('startBleAccelerometer');
    } catch (e) {
      _logger.w('startBleAccelerometer falló: $e');
    }
  }

  @override
  Future<void> stopAccelerometer() async {
    try {
      await _methodChannel.invokeMethod<void>('stopBleAccelerometer');
    } catch (e) {
      _logger.w('stopBleAccelerometer falló: $e');
    }
  }

  @override
  Future<void> startHeartRate() async {
    try {
      await _methodChannel.invokeMethod<void>('startBleHeartRate');
    } catch (e) {
      _logger.w('startBleHeartRate falló: $e');
    }
  }

  @override
  Future<void> stopHeartRate() async {
    try {
      await _methodChannel.invokeMethod<void>('stopBleHeartRate');
    } catch (e) {
      _logger.w('stopBleHeartRate falló: $e');
    }
  }
}
