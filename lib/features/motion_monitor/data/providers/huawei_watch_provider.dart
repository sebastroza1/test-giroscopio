import 'dart:async';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../../../core/models/heart_rate_sample.dart';
import '../../../../core/models/vector3_sample.dart';
import '../../../../core/models/watch_connection_state.dart';
import '../../domain/services/watch_provider.dart';

class HuaweiWatchProvider implements WatchProvider {
  static const MethodChannel _methodChannel =
      MethodChannel('acv_motion_monitor/huawei/methods');
  static const EventChannel _gyroChannel =
      EventChannel('acv_motion_monitor/huawei/gyro');
  static const EventChannel _accelChannel =
      EventChannel('acv_motion_monitor/huawei/accelerometer');
  static const EventChannel _heartRateChannel =
      EventChannel('acv_motion_monitor/huawei/heart_rate');

  final Logger _logger;

  HuaweiWatchProvider(this._logger);

  @override
  String get providerName => 'huawei';

  @override
  Stream<Vector3Sample> get watchGyroscopeStream {
    return _gyroChannel.receiveBroadcastStream().map(
      (event) => Vector3Sample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) {
      _logger.w('Error en stream giroscopio Huawei: $error');
    });
  }

  @override
  Stream<Vector3Sample> get watchAccelerometerStream {
    return _accelChannel.receiveBroadcastStream().map(
      (event) => Vector3Sample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) {
      _logger.w('Error en stream acelerómetro Huawei: $error');
    });
  }

  @override
  Stream<HeartRateSample> get watchHeartRateStream {
    return _heartRateChannel.receiveBroadcastStream().map(
      (event) => HeartRateSample.fromMap(event as Map<dynamic, dynamic>),
    ).handleError((error) {
      _logger.w('Error en stream ritmo cardiaco Huawei: $error');
    });
  }

  @override
  Future<void> initialize() async {
    try {
      await _methodChannel.invokeMethod<void>('initializeHuawei');
    } catch (e) {
      // Se captura el error para que la app nunca crashee si falta integración nativa.
      _logger.w('initializeHuawei falló: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isHuaweiAvailable') ?? false;
    } catch (e) {
      _logger.w('isHuaweiAvailable falló: $e');
      return false;
    }
  }

  @override
  Future<WatchConnectionState> getConnectionState() async {
    try {
      final response =
          await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getHuaweiConnectionState');
      if (response == null) {
        return WatchConnectionState.initial(providerName);
      }
      return WatchConnectionState.fromMap(response);
    } catch (e) {
      _logger.w('getHuaweiConnectionState falló: $e');
      return WatchConnectionState(
        available: false,
        connected: false,
        provider: providerName,
        message: 'Integración Huawei no disponible',
      );
    }
  }

  @override
  Future<void> connect() async {
    try {
      await _methodChannel.invokeMethod<void>('connectHuawei');
    } catch (e) {
      _logger.w('connectHuawei falló: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod<void>('disconnectHuawei');
    } catch (e) {
      _logger.w('disconnectHuawei falló: $e');
    }
  }

  @override
  Future<void> startGyroscope() async {
    try {
      await _methodChannel.invokeMethod<void>('startHuaweiGyroscope');
    } catch (e) {
      _logger.w('startHuaweiGyroscope falló: $e');
    }
  }

  @override
  Future<void> stopGyroscope() async {
    try {
      await _methodChannel.invokeMethod<void>('stopHuaweiGyroscope');
    } catch (e) {
      _logger.w('stopHuaweiGyroscope falló: $e');
    }
  }

  @override
  Future<void> startAccelerometer() async {
    try {
      await _methodChannel.invokeMethod<void>('startHuaweiAccelerometer');
    } catch (e) {
      _logger.w('startHuaweiAccelerometer falló: $e');
    }
  }

  @override
  Future<void> stopAccelerometer() async {
    try {
      await _methodChannel.invokeMethod<void>('stopHuaweiAccelerometer');
    } catch (e) {
      _logger.w('stopHuaweiAccelerometer falló: $e');
    }
  }

  @override
  Future<void> startHeartRate() async {
    try {
      await _methodChannel.invokeMethod<void>('startHuaweiHeartRate');
    } catch (e) {
      _logger.w('startHuaweiHeartRate falló: $e');
    }
  }

  @override
  Future<void> stopHeartRate() async {
    try {
      await _methodChannel.invokeMethod<void>('stopHuaweiHeartRate');
    } catch (e) {
      _logger.w('stopHuaweiHeartRate falló: $e');
    }
  }
}
