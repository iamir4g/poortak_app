import 'package:poortak/featueres/feature_profile/data/models/payment_history_model.dart';

abstract class PaymentHistoryState {}

class PaymentHistoryInitial extends PaymentHistoryState {}

class PaymentHistoryLoading extends PaymentHistoryState {}

class PaymentHistoryRefreshing extends PaymentHistoryState {}

class PaymentHistoryLoadingMore extends PaymentHistoryState {}

class PaymentHistorySuccess extends PaymentHistoryState {
  final PaymentHistoryList paymentHistoryList;
  final bool hasReachedMax;
  final int currentPage;

  PaymentHistorySuccess({
    required this.paymentHistoryList,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  PaymentHistorySuccess copyWith({
    PaymentHistoryList? paymentHistoryList,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return PaymentHistorySuccess(
      paymentHistoryList: paymentHistoryList ?? this.paymentHistoryList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PaymentHistoryError extends PaymentHistoryState {
  final String message;

  PaymentHistoryError(this.message);
}

class PaymentHistoryEmpty extends PaymentHistoryState {
  final String message;

  PaymentHistoryEmpty({this.message = "هیچ تراکنشی یافت نشد"});
}
