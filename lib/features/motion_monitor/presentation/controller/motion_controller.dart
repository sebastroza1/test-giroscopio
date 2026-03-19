import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/models/heart_rate_sample.dart';
import '../../../../core/models/vector3_sample.dart';
import '../../../../core/models/watch_connection_state.dart';
import '../../domain/repositories/motion_repository.dart';

class MotionController extends ChangeNotifier {
  final MotionRepository _repository;
  final Logger _logger;

  StreamSubscription<Vector3Sample>? _phoneGyroSub;
  StreamSubscription<Vector3Sample>? _phoneAccelSub;
  StreamSubscription<Vector3Sample>? _watchGyroSub;
  StreamSubscription<Vector3Sample>? _watchAccelSub;
  StreamSubscription<HeartRateSample>? _watchHeartSub;

  Vector3Sample? lastPhoneGyroscope;
  Vector3Sample? lastPhoneAccelerometer;
  Vector3Sample? lastWatchGyroscope;
  Vector3Sample? lastWatchAccelerometer;
  HeartRateSample? lastWatchHeartRate;

  WatchConnectionState watchConnectionState =
      WatchConnectionState.initial('none');

  bool isLoading = false;
  String? errorMessage;

  MotionController(this._repository, this._logger);

  bool get watchSensorsImplemented {
    switch (watchConnectionState.provider) {
      case 'huawei':
      case 'wearos':
      case 'ble_generic':
        return false;
      default:
        return false;
    }
  }

  String get watchSensorsStatusMessage {
    switch (watchConnectionState.provider) {
      case 'huawei':
        return 'El proyecto ya incluye Wear Engine y Health Kit a nivel Gradle, pero todavía falta completar autenticación Huawei y la lectura nativa de sensores del reloj.';
      case 'wearos':
        return 'La integración de sensores de Wear OS todavía no está implementada.';
      case 'ble_generic':
        return 'La integración BLE genérica todavía no conoce las características GATT del reloj para leer sensores.';
      default:
        return 'La integración de sensores del reloj todavía no está implementada.';
    }
  }

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _ensureRuntimePermissions();
      await _repository.initialize();
      _subscribePhoneStreams();
      _subscribeWatchStreams();
      watchConnectionState = await _repository.getWatchConnectionState();
    } catch (e) {
      errorMessage = 'Error al inicializar: $e';
      _logger.e(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureRuntimePermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.sensors,
    ];

    final statuses = await permissions.request();
    final denied = statuses.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key.toString())
        .toList();

    if (denied.isNotEmpty) {
      _logger.w('Permisos no concedidos: ${denied.join(', ')}');
    }
  }

  void _subscribePhoneStreams() {
    _phoneGyroSub?.cancel();
    _phoneAccelSub?.cancel();

    _phoneGyroSub = _repository.phoneGyroscopeStream.listen(
      (sample) {
        lastPhoneGyroscope = sample;
        notifyListeners();
      },
      onError: (error) {
        _logger.w('Error en phoneGyroscopeStream: $error');
      },
    );

    _phoneAccelSub = _repository.phoneAccelerometerStream.listen(
      (sample) {
        lastPhoneAccelerometer = sample;
        notifyListeners();
      },
      onError: (error) {
        _logger.w('Error en phoneAccelerometerStream: $error');
      },
    );
  }

  void _subscribeWatchStreams() {
    _watchGyroSub?.cancel();
    _watchAccelSub?.cancel();
    _watchHeartSub?.cancel();

    _watchGyroSub = _repository.watchGyroscopeStream.listen(
      (sample) {
        lastWatchGyroscope = sample;
        notifyListeners();
      },
      onError: (error) {
        _logger.w('Error en watchGyroscopeStream: $error');
      },
    );

    _watchAccelSub = _repository.watchAccelerometerStream.listen(
      (sample) {
        lastWatchAccelerometer = sample;
        notifyListeners();
      },
      onError: (error) {
        _logger.w('Error en watchAccelerometerStream: $error');
      },
    );

    _watchHeartSub = _repository.watchHeartRateStream.listen(
      (sample) {
        lastWatchHeartRate = sample;
        notifyListeners();
      },
      onError: (error) {
        _logger.w('Error en watchHeartRateStream: $error');
      },
    );
  }

  Future<void> connectWatch() async {
    try {
      errorMessage = null;
      await _repository.connectWatch();
      watchConnectionState = await _repository.getWatchConnectionState();
    } catch (e) {
      errorMessage = 'No se pudo conectar reloj: $e';
    }
    notifyListeners();
  }

  Future<void> disconnectWatch() async {
    try {
      errorMessage = null;
      await _repository.disconnectWatch();
      watchConnectionState = await _repository.getWatchConnectionState();
    } catch (e) {
      errorMessage = 'No se pudo desconectar reloj: $e';
    }
    notifyListeners();
  }

  Future<void> startAllWatchSensors() async {
    if (!watchConnectionState.connected) {
      errorMessage = 'Primero conecta un reloj antes de iniciar sensores.';
      notifyListeners();
      return;
    }

    if (!watchSensorsImplemented) {
      errorMessage = watchSensorsStatusMessage;
      notifyListeners();
      return;
    }

    try {
      errorMessage = null;
      await _repository.startWatchGyroscope();
      await _repository.startWatchAccelerometer();
      await _repository.startWatchHeartRate();
    } catch (e) {
      errorMessage = 'Error iniciando sensores del reloj: $e';
    }
    notifyListeners();
  }

  Future<void> stopAllWatchSensors() async {
    try {
      errorMessage = null;
      await _repository.stopWatchGyroscope();
      await _repository.stopWatchAccelerometer();
      await _repository.stopWatchHeartRate();
    } catch (e) {
      errorMessage = 'Error deteniendo sensores del reloj: $e';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _phoneGyroSub?.cancel();
    _phoneAccelSub?.cancel();
    _watchGyroSub?.cancel();
    _watchAccelSub?.cancel();
    _watchHeartSub?.cancel();
    super.dispose();
  }
}
