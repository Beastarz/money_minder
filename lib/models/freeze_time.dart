class FreezeTime {
  final int frozenCount;
  final DateTime frozenUntil;

  const FreezeTime({
    required this.frozenCount,
    required this.frozenUntil,
  });

  /// Convert a Map object to a [FreezeTime] instance.
  ///
  /// The keys of the [map] must be:
  ///
  /// - frozen_count: The number of times the app has been frozen.
  ///
  /// - frozen_until: The date and time when the app will be unfrozen.
  ///
  /// Returns a [FreezeTime] instance.
  static FreezeTime fromMap(Map<String, dynamic> map) {
    return FreezeTime(
      frozenCount: map['frozen_count'] as int,
      frozenUntil: DateTime.fromMillisecondsSinceEpoch(map['frozen_until'] as int),
    );
  }

  /// Convert a [FreezeTime] instance to a Map object.
  ///
  /// Returns a Map object with the following keys:
  ///
  /// - frozen_count: The number of times the app has been frozen.
  ///
  /// - frozen_until: The date and time when the app will be unfrozen.
  ///
  /// Returns a Map object.
  static Map<String, dynamic> insertAsMap(int frozenCount, DateTime frozenUntil) {
    return {
      'frozen_count': frozenCount,
      'frozen_until': frozenUntil.millisecondsSinceEpoch,
    };
  }
}