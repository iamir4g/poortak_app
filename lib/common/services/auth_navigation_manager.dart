import 'package:flutter/material.dart';

class AuthNavigationRequest {
  final int returnTabIndex;
  final String? returnRouteName;
  final Object? returnRouteArguments;

  const AuthNavigationRequest({
    required this.returnTabIndex,
    this.returnRouteName,
    this.returnRouteArguments,
  });
}

class AuthNavigationManager {
  static final AuthNavigationManager _instance = AuthNavigationManager._internal();
  factory AuthNavigationManager() => _instance;
  AuthNavigationManager._internal();

  final List<VoidCallback> _listeners = [];
  AuthNavigationRequest? _pendingRequest;

  AuthNavigationRequest? get pendingRequest => _pendingRequest;
  int? get pendingReturnTabIndex => _pendingRequest?.returnTabIndex;

  void requestLoginAndReturn({
    required int returnTabIndex,
    String? returnRouteName,
    Object? returnRouteArguments,
  }) {
    _pendingRequest = AuthNavigationRequest(
      returnTabIndex: returnTabIndex,
      returnRouteName: returnRouteName,
      returnRouteArguments: returnRouteArguments,
    );
    _notify();
  }

  void clearPendingRequest() {
    _pendingRequest = null;
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }
}

void goToLoginAndReturn({
  required int returnTabIndex,
  String? returnRouteName,
  Object? returnRouteArguments,
}) {
  AuthNavigationManager().requestLoginAndReturn(
    returnTabIndex: returnTabIndex,
    returnRouteName: returnRouteName,
    returnRouteArguments: returnRouteArguments,
  );
}
