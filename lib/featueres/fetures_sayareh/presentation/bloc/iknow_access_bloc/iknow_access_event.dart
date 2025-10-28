part of 'iknow_access_bloc.dart';

abstract class IknowAccessEvent {}

class FetchIknowAccessEvent extends IknowAccessEvent {
  final bool forceRefresh;
  FetchIknowAccessEvent({this.forceRefresh = false});
}

class CheckCourseAccessEvent extends IknowAccessEvent {
  CheckCourseAccessEvent();
}

class ClearIknowAccessEvent extends IknowAccessEvent {
  ClearIknowAccessEvent();
}
