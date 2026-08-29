import 'package:poortak/featueres/feature_profile/data/models/user_points_total_model.dart';

abstract class UserPointsTotalState {}

class UserPointsTotalInitial extends UserPointsTotalState {}

class UserPointsTotalLoading extends UserPointsTotalState {}

class UserPointsTotalSuccess extends UserPointsTotalState {
  final UserPointsTotalData data;

  UserPointsTotalSuccess({required this.data});
}

class UserPointsTotalError extends UserPointsTotalState {
  final String message;

  UserPointsTotalError(this.message);
}
