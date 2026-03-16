import '../../../../core/models/heart_rate_sample.dart';
import '../../../../core/models/vector3_sample.dart';
import '../../../../core/models/watch_connection_state.dart';

abstract class WatchProvider {
  String get providerName;

  Future<void> initialize();

  Future<bool> isAvailable();

  Future<WatchConnectionState> getConnectionState();

  Future<void> connect();

  Future<void> disconnect();

  Stream<Vector3Sample> get watchGyroscopeStream;

  Stream<Vector3Sample> get watchAccelerometerStream;

  Stream<HeartRateSample> get watchHeartRateStream;

  Future<void> startGyroscope();

  Future<void> stopGyroscope();

  Future<void> startAccelerometer();

  Future<void> stopAccelerometer();

  Future<void> startHeartRate();

  Future<void> stopHeartRate();
}
