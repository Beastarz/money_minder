class Passcode {
  final String salt;
  final String encryptedPasscode;
  final int activePeriod;

  const Passcode({
    required this.salt,
    required this.encryptedPasscode,
    required this.activePeriod,
  });

  /// Convert a Map object to a [Passcode] instance.
  ///
  /// The keys of the [map] must be:
  ///
  /// - 'salt': The salt used for encryption.
  ///
  /// - 'encrypted_passcode': The encrypted passcode.
  ///
  /// - 'active_period': The active period of the passcode (in seconds).
  ///
  /// Returns a [Passcode] instance.
  static Passcode fromMap(Map<String, dynamic> map) {
    return Passcode(
      salt: map['salt'],
      encryptedPasscode: map['encrypted_passcode'],
      activePeriod: map['active_period'] as int,
    );
  }

  /// Convert a [Passcode] instance to a Map object.
  ///
  /// Returns a Map object with the following keys:
  ///
  /// - 'salt': The salt used for encryption.
  ///
  /// - 'encrypted_passcode': The encrypted passcode.
  ///
  /// - 'active_period': The active period of the passcode (in seconds).
  ///
  /// Returns a Map object.
  static Map<String, dynamic> insertAsMap(
      String salt,
      String encryptedPasscode,
      int activePeriod,
      ) {
    return {
      'salt': salt,
      'encrypted_passcode': encryptedPasscode,
      'active_period': activePeriod
    };
  }
}