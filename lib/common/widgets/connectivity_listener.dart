import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/bloc/connectivity_cubit/connectivity_cubit.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';

class ConnectivityListener extends StatefulWidget {
  final Widget child;

  const ConnectivityListener({
    Key? key,
    required this.child,
  }) : super(key: key);

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
          _showNoInternetModal(context);
        } else if (state.isConnected && _isModalShowing) {
          // If connection is restored, close the modal if it's open
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          _isModalShowing = false;
        }
      },
      child: widget.child,
    );
  }

  void _showNoInternetModal(BuildContext context) {
    ReusableModal.showError(
      context: context,
      title: 'اتصال به اینترنت',
      message: 'لطفاً اتصال اینترنت خود را بررسی کنید',
      buttonText: 'تلاش مجدد',
      barrierDismissible: false,
      customImagePath: 'assets/images/modals/old_man_final.png',
      onButtonPressed: () {
        Navigator.of(context).pop();
        _isModalShowing = false;
        // Check connectivity again
        context.read<ConnectivityCubit>().checkConnectivity();
      },
    );
  }
}
