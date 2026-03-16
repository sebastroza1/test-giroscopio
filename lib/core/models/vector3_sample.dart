class Vector3Sample {
  final double x;
  final double y;
  final double z;
  final String source;
  final String sensorType;
  final DateTime timestamp;

  const Vector3Sample({
    required this.x,
    required this.y,
    required this.z,
    required this.source,
    required this.sensorType,
    required this.timestamp,
  });

  factory Vector3Sample.fromMap(Map<dynamic, dynamic> map) {
    return Vector3Sample(
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      z: (map['z'] as num?)?.toDouble() ?? 0.0,
      source: map['source']?.toString() ?? 'unknown',
      sensorType: map['sensorType']?.toString() ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'source': source,
      'sensorType': sensorType,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
