class Currency {
  final int currencyIndex;
  final String name;

  String get fullName => currencyToFullName[name]!;

  Currency._(this.currencyIndex, this.name);

  static Currency of(String currencyName) {
    if (currencyToIndex[currencyName.toUpperCase()] == null) {
      return Currency.of('SGD');
    }
    return Currency._(
        currencyToIndex[currencyName.toUpperCase()] ?? 0,
        currencyName.toUpperCase()
    );
  }

  static final Map<String, int> currencyToIndex = {
    'SGD': 0, // Singapore Dollar
    'MYR': 1, // Malaysian Ringgit
    'USD': 2, // United States Dollar
    'EUR': 3, // Euro
    'JPY': 4, // Japanese Yen
    'CNY': 5, // Chinese Yuan
    'AUD': 6, // Australian Dollar
    'GBP': 7, // British Pound
    'THB': 8, // Thai Baht
    'IDR': 9, // Indonesian Rupiah
    'VND': 10, // Vietnamese Dong
    'HKD': 11, // Hong Kong Dollar
    'KRW': 12, // South Korean Won
    'PHP': 13,  // Philippine Peso
    'INR': 14, // Indian Rupee
    'BDT': 15, // Bangladeshi Taka
    'NPR': 16, // Nepalese Rupee
    'LKR': 17, // Sri Lankan Rupee
    'MMK': 18  // Myanmar Kyat
  };

  static final Map<String, String> currencyToFullName = {
    'SGD': 'Singapore Dollar -- SGD',
    'MYR': 'Malaysian Ringgit -- MYR',
    'USD': 'United States Dollar -- USD',
    'EUR': 'Euro -- EUR',
    'JPY': 'Japanese Yen -- JPY',
    'CNY': 'Chinese Yuan -- CNY',
    'AUD': 'Australian Dollar -- AUD',
    'GBP': 'British Pound -- GBP',
    'THB': 'Thai Baht -- THB',
    'IDR': 'Indonesian Rupiah -- IDR',
    'VND': 'Vietnamese Dong -- VND',
    'HKD': 'Hong Kong Dollar -- HKD',
    'KRW': 'South Korean Won -- KRW',
    'PHP': 'Philippine Peso -- PHP',
    'INR': 'Indian Rupee -- INR',
    'BDT': 'Bangladeshi Taka -- BDT',
    'NPR': 'Nepalese Rupee -- NPR',
    'LKR': 'Sri Lankan Rupee -- LKR',
    'MMK': 'Myanmar Kyat -- MMK'
  };

  static final List<List<double>> rates = [
    // SGD (Singapore Dollar) conversions (row 0)
    [1, 3.304, 0.778, 0.669, 115.78, 5.585, 1.195, 0.580, 25.21, 12701.87, 20377.88, 6.11, 1083.24, 44.44, 67.25, 94.52, 107.24, 234.90, 1633.73],
    // MYR (Malaysian Ringgit) conversions (row 1)
    [0.30266, 1, 0.23553, 0.20247, 35.042, 1.6904, 0.36168, 0.17556, 7.6298, 3844.2, 6168.2, 1.849, 327.85, 13.447, 20.354, 28.608, 32.46, 71.09, 494.4],
    // USD (United States Dollar) conversions (row 2)
    [1.2853, 4.2460, 1, 0.93, 158.00, 7.25, 1.50, 0.79, 32.363, 16000, 25000, 7.84664, 1380, 58, 86.44, 121.5, 137.8, 301.9, 2100],
    // EUR (Euro) conversions (row 3)
    [1.4947, 5.15, 1.075, 1, 170.00, 7.80, 1.62, 0.85, 36.00, 17500, 28000, 8.50, 1500, 65, 96.6, 135.8, 154.0, 337.5, 2348.8],
    // JPY (Japanese Yen) conversions (row 4)
    [0.008637, 0.02853, 0.006329, 0.005882, 1, 0.046, 0.0095, 0.0063, 0.28, 110, 1.8, 0.05, 9.5, 0.38, 0.58, 0.81, 0.92, 2.03, 14.1],
    // CNY (Chinese Yuan) conversions (row 5)
    [0.17904, 0.66, 0.13793, 0.1282, 21.739, 1, 0.20, 0.11, 4.5, 2200, 3500, 1.1, 190, 8, 12.04, 16.92, 19.2, 42.08, 292.5],
    // AUD (Australian Dollar) conversions (row 6)
    [0.8368, 3.10, 0.66667, 0.61728, 105.26, 5.0, 1, 0.53, 21.5, 10700, 17000, 5.2, 900, 37, 56.27, 79.1, 89.7, 196.5, 1367.6],
    // GBP (British Pound) conversions (row 7)
    [1.7241, 5.95, 1.2658, 1.1765, 158.73, 9.09, 1.8868, 1, 43.5, 21500, 34500, 7.5, 1250, 52, 86.2, 121.2, 137.6, 301.5, 2098.8],
    // THB (Thai Baht) conversions (row 8)
    [0.03966, 0.039719, 0.03089, 0.02778, 3.5714, 0.2222, 0.0465, 0.02299, 1, 500, 800, 0.25, 45, 1.8, 2.667, 3.75, 4.25, 9.32, 64.8],
    // IDR (Indonesian Rupiah) conversions (row 9)
    [0.0000787, 0.00033, 0.0000625, 0.0000571, 0.00909, 0.00045, 0.0000934, 0.0000465, 0.002, 1, 1.6, 0.00048, 0.07, 0.003, 0.0053, 0.0074, 0.0084, 0.0185, 0.1286],
    // VND (Vietnamese Dong) conversions (row 10)
    [0.00004907, 0.00024, 0.00004, 0.0000357, 0.5555, 0.00028, 0.0000588, 0.0000289, 0.00125, 0.625, 1, 0.0003, 0.04, 0.002, 0.0033, 0.0046, 0.0053, 0.0115, 0.0801],
    // HKD (Hong Kong Dollar) conversions (row 11)
    [0.16366, 0.15, 0.12742, 0.11765, 20, 0.909, 0.1923, 0.1333, 4, 2083.3, 3333.3, 1, 140, 6, 9.5, 13.3, 15.1, 33.1, 230],
    // KRW (South Korean Won) conversions (row 12)
    [0.000923, 0.0046, 0.0007246, 0.000667, 0.10526, 0.00526, 0.00111, 0.0008, 0.0222, 14.28, 25, 0.00714, 1, 0.04, 0.062, 0.087, 0.099, 0.216, 1.5],
    // PHP (Philippine Peso) conversions (row 13)
    [0.0225, 0.07437, 0.01724, 0.01538, 2.6316, 0.125, 0.0270, 0.01923, 0.5555, 333.33, 500, 0.1667, 25, 1, 1.51, 2.12, 2.4, 5.25, 36.6],
    // INR (Indian Rupee) conversions (row 14)
    [0.01487, 0.04913, 0.01157, 0.01035, 1.724, 0.08306, 0.01777, 0.0116, 0.375, 188.68, 303.03, 0.1052, 16.129, 0.6622, 1, 1.405, 1.59, 3.49, 24.3],
    // BDT (Bangladeshi Taka) conversions (row 15)
    [0.01058, 0.03495, 0.00823, 0.00736, 1.23, 0.0591, 0.0126, 0.00825, 0.266, 135, 216, 0.075, 11.49, 0.471, 0.711, 1, 1.13, 2.48, 17.2],
    // NPR (Nepalese Rupee) conversions (row 16)
    [0.00932, 0.0308, 0.00725, 0.00649, 1.08, 0.052, 0.0111, 0.00726, 0.235, 119, 190, 0.066, 10.1, 0.416, 0.627, 0.88, 1, 2.19, 15.2],
    // LKR (Sri Lankan Rupee) conversions (row 17)
    [0.00425, 0.01406, 0.00331, 0.00296, 0.492, 0.0237, 0.00509, 0.00332, 0.107, 54.05, 86.7, 0.029, 4.62, 0.19, 0.286, 0.403, 0.457, 1, 6.95],
    // MMK (Myanmar Kyat) conversions (row 18)
    [0.0006121, 0.00202, 0.000476, 0.000425, 0.0709, 0.00342, 0.00073, 0.000476, 0.0154, 7.77, 12.45, 0.0043, 0.066, 0.0027, 0.0041, 0.0057, 0.0065, 0.0143, 1]
  ];

  static List<Currency> get currencies => Currency.currencyToIndex.keys.map((name) => Currency.of(name)).toList();

  static double convert(Currency from, Currency to, double amount) {
    return amount * rates[from.currencyIndex][to.currencyIndex];
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (other is Currency) {
      return name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}