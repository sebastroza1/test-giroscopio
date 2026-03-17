class HeartRateSample {
  final int bpm;
  final String source;
  final DateTime timestamp;

  const HeartRateSample({
    required this.bpm,
    required this.source,
    required this.timestamp,
  });

  factory HeartRateSample.fromMap(Map<dynamic, dynamic> map) {
    return HeartRateSample(
      bpm: (map['bpm'] as num?)?.toInt() ?? 0,
      source: map['source']?.toString() ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bpm': bpm,
      'source': source,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
