import 'package:poortak/featueres/feature_profile/data/models/payment_history_params.dart';

abstract class PaymentHistoryEvent {}

class LoadPaymentHistoryEvent extends PaymentHistoryEvent {
  final PaymentHistoryParams? params;

  LoadPaymentHistoryEvent({this.params});
}

class RefreshPaymentHistoryEvent extends PaymentHistoryEvent {
  final PaymentHistoryParams? params;

  RefreshPaymentHistoryEvent({this.params});
}

class LoadMorePaymentHistoryEvent extends PaymentHistoryEvent {
  final PaymentHistoryParams? params;

  LoadMorePaymentHistoryEvent({this.params});
}

class FilterPaymentHistoryEvent extends PaymentHistoryEvent {
  final PaymentHistoryParams params;

  FilterPaymentHistoryEvent({required this.params});
}
