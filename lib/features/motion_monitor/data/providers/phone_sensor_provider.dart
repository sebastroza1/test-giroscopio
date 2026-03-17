import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/models/vector3_sample.dart';

class PhoneSensorProvider {
  Stream<Vector3Sample> get phoneGyroscopeStream {
    return gyroscopeEventStream().map(
      (event) => Vector3Sample(
        x: event.x,
        y: event.y,
        z: event.z,
        source: 'phone',
        sensorType: 'gyroscope',
        timestamp: DateTime.now(),
      ),
    );
  }

  Stream<Vector3Sample> get phoneAccelerometerStream {
    return accelerometerEventStream().map(
      (event) => Vector3Sample(
        x: event.x,
        y: event.y,
        z: event.z,
        source: 'phone',
        sensorType: 'accelerometer',
        timestamp: DateTime.now(),
      ),
    );
  }
}
