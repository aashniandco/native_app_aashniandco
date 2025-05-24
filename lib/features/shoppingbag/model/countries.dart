// class Country {
//   final String id;
//   final String twoLetterAbbreviation;
//   final String threeLetterAbbreviation;
//   final String fullNameLocale;
//   final String fullNameEnglish;
//
//   Country({
//     required this.id,
//     required this.twoLetterAbbreviation,
//     required this.threeLetterAbbreviation,
//     required this.fullNameLocale,
//     required this.fullNameEnglish,
//   });
//
//   factory Country.fromJson(Map<String, dynamic> json) {
//     return Country(
//       id: json['id'] ?? '',
//       twoLetterAbbreviation: json['two_letter_abbreviation'] ?? '',
//       threeLetterAbbreviation: json['three_letter_abbreviation'] ?? '',
//       fullNameLocale: json['full_name_locale'] ?? '',
//       fullNameEnglish: json['full_name_english'] ?? '',
//     );
//   }
// }


class Country {
  final String id;
  final String twoLetterAbbreviation;
  final String threeLetterAbbreviation;
  final String fullNameLocale;
  final String fullNameEnglish;

  Country({
    required this.id,
    required this.twoLetterAbbreviation,
    required this.threeLetterAbbreviation,
    required this.fullNameLocale,
    required this.fullNameEnglish,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Handle cases where 'available_regions' might be missing or null
    // For this problem, we are not using regions directly from here, but good practice.
    return Country(
      id: json['id'] ?? '',
      twoLetterAbbreviation: json['two_letter_abbreviation'] ?? '',
      threeLetterAbbreviation: json['three_letter_abbreviation'] ?? '',
      fullNameLocale: json['full_name_locale'] ?? '',
      fullNameEnglish: json['full_name_english'] ?? '',
    );
  }
}

// Shipping Method Model (New)
class ShippingMethod {
  final String carrierCode;
  final String methodCode;
  final String carrierTitle;
  final String methodTitle;
  final double amount;
  final bool available;

  ShippingMethod({
    required this.carrierCode,
    required this.methodCode,
    required this.carrierTitle,
    required this.methodTitle,
    required this.amount,
    required this.available,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      carrierCode: json['carrier_code'] ?? '',
      methodCode: json['method_code'] ?? '',
      carrierTitle: json['carrier_title'] ?? '',
      methodTitle: json['method_title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      available: json['available'] ?? false,
    );
  }

  String get displayName => '$carrierTitle - $methodTitle';
}
