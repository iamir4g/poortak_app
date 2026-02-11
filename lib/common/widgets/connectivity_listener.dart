import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/bloc/connectivity_cubit/connectivity_cubit.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';

class ConnectivityListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const ConnectivityListener({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  bool _isModalShowing = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) {
        if (!state.isConnected && !_isModalShowing) {
          _isModalShowing = true;
          // Use addPostFrameCallback to ensure MaterialApp is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNoInternetModal();
          });
        } else if (state.isConnected && _isModalShowing) {
          // If connection is restored, close the modal if it's open
          final navigatorContext = widget.navigatorKey?.currentContext;
          if (navigatorContext != null) {
            if (Navigator.of(navigatorContext, rootNavigator: true).canPop()) {
              Navigator.of(navigatorContext, rootNavigator: true).pop();
            }
          }
          _isModalShowing = false;
        }
      },
      child: widget.child,
    );
  }

  void _showNoInternetModal() {
    // Get context from navigator key which has MaterialLocalizations
    final navigatorContext = widget.navigatorKey?.currentContext;
    if (navigatorContext == null) {
      // If navigator is not ready yet, try again after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _showNoInternetModal();
        } else {
          // If widget is unmounted, reset the flag
          _isModalShowing = false;
        }
      });
      return;
    }

    // Verify we can actually show the dialog
    if (!mounted) {
      _isModalShowing = false;
      return;
    }

    ReusableModal.showError(
      context: navigatorContext,
      title: 'اتصال به اینترنت',
      message: 'لطفاً اتصال اینترنت خود را بررسی کنید',
      buttonText: 'تلاش مجدد',
      barrierDismissible: false,
      customImagePath: 'assets/images/modals/old_man_final.png',
      onButtonPressed: () {
        final context = widget.navigatorKey?.currentContext;
        if (context != null) {
          Navigator.of(context, rootNavigator: true).pop();
          _isModalShowing = false;
          // Check connectivity again
          context.read<ConnectivityCubit>().checkConnectivity();
        }
      },
    );
  }
}
