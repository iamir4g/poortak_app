import 'package:equatable/equatable.dart';

class BazaarSkuDetails extends Equatable {
  final String sku;
  final String type;
  final String price;
  final String title;
  final String description;

  const BazaarSkuDetails({
    required this.sku,
    required this.type,
    required this.price,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [sku, type, price, title, description];
}
