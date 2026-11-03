import 'package:poortak/common/utils/money_utils.dart';

class OwnedIKnowItem {
  final String type;
  final String itemId;
  final String name;
  final int price;

  const OwnedIKnowItem({
    required this.type,
    required this.itemId,
    required this.name,
    required this.price,
  });

  factory OwnedIKnowItem.fromJson(Map<String, dynamic> json) {
    return OwnedIKnowItem(
      type: json['type']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: MoneyUtils.parseRial(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'itemId': itemId,
        'name': name,
        'price': price,
      };

  int get priceToman => MoneyUtils.rialToTomanInt(price);
}

class IKnowPackagePricing {
  final String packageId;
  final int basePrice;
  final int packageDiscount;
  final int priceAfterPackageDiscount;
  final List<OwnedIKnowItem> ownedItems;
  final int ownedItemsTotal;
  final int appliedDeduction;
  final int payablePrice;

  const IKnowPackagePricing({
    required this.packageId,
    required this.basePrice,
    required this.packageDiscount,
    required this.priceAfterPackageDiscount,
    required this.ownedItems,
    required this.ownedItemsTotal,
    required this.appliedDeduction,
    required this.payablePrice,
  });

  factory IKnowPackagePricing.fromJson(Map<String, dynamic> json) {
    final ownedRaw = json['ownedItems'];
    return IKnowPackagePricing(
      packageId: json['packageId']?.toString() ?? '',
      basePrice: MoneyUtils.parseRial(json['basePrice']),
      packageDiscount: MoneyUtils.parseRial(json['packageDiscount']),
      priceAfterPackageDiscount:
          MoneyUtils.parseRial(json['priceAfterPackageDiscount']),
      ownedItems: ownedRaw is List
          ? ownedRaw
              .whereType<Map>()
              .map(
                (item) => OwnedIKnowItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      ownedItemsTotal: MoneyUtils.parseRial(json['ownedItemsTotal']),
      appliedDeduction: MoneyUtils.parseRial(json['appliedDeduction']),
      payablePrice: MoneyUtils.parseRial(json['payablePrice']),
    );
  }

  static IKnowPackagePricing? tryParse(dynamic json) {
    if (json is! Map) return null;
    return IKnowPackagePricing.fromJson(Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() => {
        'packageId': packageId,
        'basePrice': basePrice,
        'packageDiscount': packageDiscount,
        'priceAfterPackageDiscount': priceAfterPackageDiscount,
        'ownedItems': ownedItems.map((item) => item.toJson()).toList(),
        'ownedItemsTotal': ownedItemsTotal,
        'appliedDeduction': appliedDeduction,
        'payablePrice': payablePrice,
      };

  bool get isFree => payablePrice <= 0;

  bool get hasOwnershipDeduction => appliedDeduction > 0;

  int get basePriceToman => MoneyUtils.rialToTomanInt(basePrice);

  int get packageDiscountToman => MoneyUtils.rialToTomanInt(packageDiscount);

  int get priceAfterPackageDiscountToman =>
      MoneyUtils.rialToTomanInt(priceAfterPackageDiscount);

  int get ownedItemsTotalToman => MoneyUtils.rialToTomanInt(ownedItemsTotal);

  int get appliedDeductionToman => MoneyUtils.rialToTomanInt(appliedDeduction);

  int get payablePriceToman => MoneyUtils.rialToTomanInt(payablePrice);

  Set<String> get ownedItemIds =>
      ownedItems.map((item) => item.itemId).where((id) => id.isNotEmpty).toSet();
}

int fallbackIKnowSettingsPayableToman({
  required String price,
  required String discountType,
  required String discountAmount,
}) {
  final subtotal = MoneyUtils.parseRialToTomanInt(price);
  final isPercent = discountType.toLowerCase() == 'percent';
  final discountAmountValue = isPercent
      ? subtotal * MoneyUtils.parseRial(discountAmount) ~/ 100
      : MoneyUtils.parseRialToTomanInt(discountAmount);
  final payable = subtotal - discountAmountValue;
  return payable < 0 ? 0 : payable;
}

int resolveIKnowPackagePayableToman({
  required IKnowPackagePricing? packageInfo,
  required String settingsPrice,
  required String discountType,
  required String discountAmount,
}) {
  if (packageInfo != null) {
    return packageInfo.payablePriceToman;
  }
  return fallbackIKnowSettingsPayableToman(
    price: settingsPrice,
    discountType: discountType,
    discountAmount: discountAmount,
  );
}
