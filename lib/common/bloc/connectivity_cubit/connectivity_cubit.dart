import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityCubit() : super(const ConnectivityState(isConnected: true)) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() async {
    // Check initial connectivity status
    await checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _checkActualConnectivity();
      },
    );
  }

  Future<void> checkConnectivity() async {
    await _checkActualConnectivity();
  }

  Future<void> _checkActualConnectivity() async {
    try {
      // First check connectivity status
      final connectivityResults = await _connectivity.checkConnectivity();

      // Check if any connection type is available
      bool hasConnection = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );

      // If connectivity says we're connected, verify with actual internet
      if (hasConnection) {
        try {
          final result = await InternetAddress.lookup('google.com')
              .timeout(const Duration(seconds: 5));
          hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (e) {
          hasConnection = false;
        }
      }

      emit(ConnectivityState(isConnected: hasConnection));
    } catch (e) {
      emit(const ConnectivityState(isConnected: false));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
