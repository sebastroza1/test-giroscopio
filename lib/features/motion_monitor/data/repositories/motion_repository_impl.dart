import 'dart:async';

import 'package:logger/logger.dart';

import '../../../../core/models/heart_rate_sample.dart';
import '../../../../core/models/vector3_sample.dart';
import '../../../../core/models/watch_connection_state.dart';
import '../../domain/repositories/motion_repository.dart';
import '../../domain/services/watch_provider.dart';
import '../providers/phone_sensor_provider.dart';

class MotionRepositoryImpl implements MotionRepository {
  final PhoneSensorProvider _phoneProvider;
  final List<WatchProvider> _watchProviders;
  final Logger _logger;

  late WatchProvider _activeWatchProvider;

  MotionRepositoryImpl({
    required PhoneSensorProvider phoneProvider,
    required List<WatchProvider> watchProviders,
    required Logger logger,
    String preferredProvider = 'huawei',
  })  : _phoneProvider = phoneProvider,
        _watchProviders = watchProviders,
        _logger = logger {
    _activeWatchProvider = _watchProviders.firstWhere(
      (provider) => provider.providerName == preferredProvider,
      orElse: () => _watchProviders.first,
    );
  }

  void setActiveProvider(String providerName) {
    final found = _watchProviders.where((w) => w.providerName == providerName);
    if (found.isNotEmpty) {
      _activeWatchProvider = found.first;
    }
  }

  @override
  Stream<Vector3Sample> get phoneGyroscopeStream => _phoneProvider.phoneGyroscopeStream;

  @override
  Stream<Vector3Sample> get phoneAccelerometerStream =>
      _phoneProvider.phoneAccelerometerStream;

  @override
  Stream<Vector3Sample> get watchGyroscopeStream =>
      _activeWatchProvider.watchGyroscopeStream;

  @override
  Stream<Vector3Sample> get watchAccelerometerStream =>
      _activeWatchProvider.watchAccelerometerStream;

  @override
  Stream<HeartRateSample> get watchHeartRateStream =>
      _activeWatchProvider.watchHeartRateStream;

  @override
  Future<void> initialize() async {
    for (final provider in _watchProviders) {
      try {
        await provider.initialize();
      } catch (e) {
        // Protección adicional por si algún provider lanza error inesperado.
        _logger.w('No se pudo inicializar ${provider.providerName}: $e');
      }
    }

    // Selección automática del primer provider realmente disponible.
    for (final provider in _watchProviders) {
      final available = await provider.isAvailable();
      if (available) {
        _activeWatchProvider = provider;
        break;
      }
    }
  }

  @override
  Future<WatchConnectionState> getWatchConnectionState() {
    return _activeWatchProvider.getConnectionState();
  }

  @override
  Future<void> connectWatch() => _activeWatchProvider.connect();

  @override
  Future<void> disconnectWatch() => _activeWatchProvider.disconnect();

  @override
  Future<void> startWatchGyroscope() => _activeWatchProvider.startGyroscope();

  @override
  Future<void> stopWatchGyroscope() => _activeWatchProvider.stopGyroscope();

  @override
  Future<void> startWatchAccelerometer() =>
      _activeWatchProvider.startAccelerometer();

  @override
  Future<void> stopWatchAccelerometer() => _activeWatchProvider.stopAccelerometer();

  @override
  Future<void> startWatchHeartRate() => _activeWatchProvider.startHeartRate();

  @override
  Future<void> stopWatchHeartRate() => _activeWatchProvider.stopHeartRate();
}
