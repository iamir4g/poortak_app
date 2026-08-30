import 'package:poortak/featueres/feature_profile/data/models/prize_history_model.dart';

abstract class PrizeHistoryState {}

class PrizeHistoryInitial extends PrizeHistoryState {}

class PrizeHistoryLoading extends PrizeHistoryState {}

class PrizeHistoryRefreshing extends PrizeHistoryState {}

class PrizeHistorySuccess extends PrizeHistoryState {
  final PrizeHistoryResponse prizeHistoryResponse;

  PrizeHistorySuccess({required this.prizeHistoryResponse});
}

class PrizeHistoryError extends PrizeHistoryState {
  final String message;

  PrizeHistoryError(this.message);
}

class PrizeHistoryEmpty extends PrizeHistoryState {
  final String message;

  PrizeHistoryEmpty({this.message = "هیچ امتیازی یافت نشد"});
}
