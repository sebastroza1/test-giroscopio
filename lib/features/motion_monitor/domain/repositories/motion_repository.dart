import '../../../../core/models/heart_rate_sample.dart';
import '../../../../core/models/vector3_sample.dart';
import '../../../../core/models/watch_connection_state.dart';

abstract class MotionRepository {
  Stream<Vector3Sample> get phoneGyroscopeStream;

  Stream<Vector3Sample> get phoneAccelerometerStream;

  Stream<Vector3Sample> get watchGyroscopeStream;

  Stream<Vector3Sample> get watchAccelerometerStream;

  Stream<HeartRateSample> get watchHeartRateStream;

  Future<void> initialize();

  Future<WatchConnectionState> getWatchConnectionState();

  Future<void> connectWatch();

  Future<void> disconnectWatch();

  Future<void> startWatchGyroscope();

  Future<void> stopWatchGyroscope();

  Future<void> startWatchAccelerometer();

  Future<void> stopWatchAccelerometer();

  Future<void> startWatchHeartRate();

  Future<void> stopWatchHeartRate();
}
