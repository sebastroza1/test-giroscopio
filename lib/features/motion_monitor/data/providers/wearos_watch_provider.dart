import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../../../core/models/heart_rate_sample.dart';
import '../../../../core/models/vector3_sample.dart';
import '../../../../core/models/watch_connection_state.dart';
import '../../domain/services/watch_provider.dart';

class WearOsWatchProvider implements WatchProvider {
  static const MethodChannel _methodChannel =
      MethodChannel('acv_motion_monitor/wearos/methods');
  static const EventChannel _gyroChannel =
      EventChannel('acv_motion_monitor/wearos/gyro');
  static const EventChannel _accelChannel =
      EventChannel('acv_motion_monitor/wearos/accelerometer');
  static const EventChannel _heartRateChannel =
      EventChannel('acv_motion_monitor/wearos/heart_rate');

  final Logger _logger;

  WearOsWatchProvider(this._logger);

  @override
  String get providerName => 'wearos';

  @override
  Future<void> initialize() async {
    try {
      await _methodChannel.invokeMethod<void>('initializeWearOs');
    } catch (e) {
      _logger.w('initializeWearOs falló: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isWearOsAvailable') ?? false;
    } catch (e) {
      _logger.w('isWearOsAvailable falló: $e');
      return false;
    }
  }

  @override
  Future<WatchConnectionState> getConnectionState() async {
    try {
      final response =
          await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getWearOsConnectionState');
      if (response == null) {
        return WatchConnectionState.initial(providerName);
      }
      return WatchConnectionState.fromMap(response);
    } catch (e) {
      _logger.w('getWearOsConnectionState falló: $e');
      return WatchConnectionState(
        available: false,
        connected: false,
        provider: providerName,
        message: 'Wear OS no implementado aún',
      );
    }
  }

  @override
  Future<void> connect() async {
    try {
      await _methodChannel.invokeMethod<void>('connectWearOs');
    } catch (e) {
      _logger.w('connectWearOs falló: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod<void>('disconnectWearOs');
    } catch (e) {
      _logger.w('disconnectWearOs falló: $e');
    }
  }

  @override
  Stream<Vector3Sample> get watchGyroscopeStream {
    return _gyroChannel.receiveBroadcastStream().map(
      (event) => Vector3Sample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) => _logger.w('stream gyro Wear OS falló: $error'));
  }

  @override
  Stream<Vector3Sample> get watchAccelerometerStream {
    return _accelChannel.receiveBroadcastStream().map(
      (event) => Vector3Sample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) => _logger.w('stream accel Wear OS falló: $error'));
  }

  @override
  Stream<HeartRateSample> get watchHeartRateStream {
    return _heartRateChannel.receiveBroadcastStream().map(
      (event) => HeartRateSample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) => _logger.w('stream HR Wear OS falló: $error'));
  }

  @override
  Future<void> startGyroscope() async {
    try {
      await _methodChannel.invokeMethod<void>('startWearOsGyroscope');
    } catch (e) {
      _logger.w('startWearOsGyroscope falló: $e');
    }
  }

  @override
  Future<void> stopGyroscope() async {
    try {
      await _methodChannel.invokeMethod<void>('stopWearOsGyroscope');
    } catch (e) {
      _logger.w('stopWearOsGyroscope falló: $e');
    }
  }

  @override
  Future<void> startAccelerometer() async {
    try {
      await _methodChannel.invokeMethod<void>('startWearOsAccelerometer');
    } catch (e) {
      _logger.w('startWearOsAccelerometer falló: $e');
    }
  }

  @override
  Future<void> stopAccelerometer() async {
    try {
      await _methodChannel.invokeMethod<void>('stopWearOsAccelerometer');
    } catch (e) {
      _logger.w('stopWearOsAccelerometer falló: $e');
    }
  }

  @override
  Future<void> startHeartRate() async {
    try {
      await _methodChannel.invokeMethod<void>('startWearOsHeartRate');
    } catch (e) {
      _logger.w('startWearOsHeartRate falló: $e');
    }
  }

  @override
  Future<void> stopHeartRate() async {
    try {
      await _methodChannel.invokeMethod<void>('stopWearOsHeartRate');
    } catch (e) {
      _logger.w('stopWearOsHeartRate falló: $e');
    }
  }
}
