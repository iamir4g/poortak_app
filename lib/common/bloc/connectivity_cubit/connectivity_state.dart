part of 'connectivity_cubit.dart';

class ConnectivityState {
  final bool isConnected;

  const ConnectivityState({
    required this.isConnected,
  });

  ConnectivityState copyWith({
    bool? isConnected,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
