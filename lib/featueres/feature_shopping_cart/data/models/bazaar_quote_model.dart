import 'package:poortak/common/utils/money_utils.dart';

class BazaarQuoteModel {
  final bool ok;
  final BazaarQuoteData data;

  const BazaarQuoteModel({
    required this.ok,
    required this.data,
  });

  factory BazaarQuoteModel.fromJson(Map<String, dynamic> json) {
    return BazaarQuoteModel(
      ok: json['ok'] == true,
      data: BazaarQuoteData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

class BazaarQuoteData {
  final String nonce;
  final String token;
  final DateTime? expiresAt;
  final int basePrice;
  final int pointsSpent;
  final int discountAmount;
  final int finalPrice;
  final int remainingPoints;
  final int pointValueInRials;

  const BazaarQuoteData({
    required this.nonce,
    required this.token,
    required this.expiresAt,
    required this.basePrice,
    required this.pointsSpent,
    required this.discountAmount,
    required this.finalPrice,
    required this.remainingPoints,
    required this.pointValueInRials,
  });

  factory BazaarQuoteData.fromJson(Map<String, dynamic> json) {
    return BazaarQuoteData(
      nonce: json['nonce']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
      basePrice: MoneyUtils.parseRial(json['basePrice']),
      pointsSpent: MoneyUtils.parseRial(json['pointsSpent']),
      discountAmount: MoneyUtils.parseRial(json['discountAmount']),
      finalPrice: MoneyUtils.parseRial(json['finalPrice']),
      remainingPoints: MoneyUtils.parseRial(json['remainingPoints']),
      pointValueInRials: MoneyUtils.parseRial(json['pointValueInRials']),
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().toUtc().isAfter(expiresAt!.toUtc());
  }

  int get basePriceToman => MoneyUtils.rialToTomanInt(basePrice);
  int get finalPriceToman => MoneyUtils.rialToTomanInt(finalPrice);
  int get discountAmountToman => MoneyUtils.rialToTomanInt(discountAmount);
  int get pointValueToman => MoneyUtils.rialToTomanInt(pointValueInRials);
}
