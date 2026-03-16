class WatchConnectionState {
  final bool available;
  final bool connected;
  final String provider;
  final String message;

  const WatchConnectionState({
    required this.available,
    required this.connected,
    required this.provider,
    required this.message,
  });

  factory WatchConnectionState.initial(String provider) {
    return WatchConnectionState(
      available: false,
      connected: false,
      provider: provider,
      message: 'Sin inicializar',
    );
  }

  factory WatchConnectionState.fromMap(Map<dynamic, dynamic> map) {
    return WatchConnectionState(
      available: map['available'] as bool? ?? false,
      connected: map['connected'] as bool? ?? false,
      provider: map['provider']?.toString() ?? 'unknown',
      message: map['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'available': available,
      'connected': connected,
      'provider': provider,
      'message': message,
    };
  }
}
