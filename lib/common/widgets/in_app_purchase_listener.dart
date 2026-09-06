import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/bloc/in_app_purchase_bloc/in_app_purchase_bloc.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/user_points_total_bloc/user_points_total_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/user_points_total_bloc/user_points_total_event.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/locator.dart';

class InAppPurchaseListener extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const InAppPurchaseListener({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<InAppPurchaseBloc, InAppPurchaseState>(
      listenWhen: (previous, current) =>
          current is InAppPurchaseSuccess || current is InAppPurchaseError,
      listener: (context, state) async {
        if (state is InAppPurchaseSuccess) {
          await locator<ShoppingCartBloc>().clearAfterSuccessfulPayment();
          locator<IknowAccessBloc>().add(
            FetchIknowAccessEvent(forceRefresh: true),
          );
          locator<UserPointsTotalBloc>().add(LoadUserPointsTotalEvent());

          final ref = state.purchases.isNotEmpty
              ? state.purchases.first.purchaseToken
              : null;
          navigatorKey?.currentState?.pushNamed(
            PaymentResultScreen.routeName,
            arguments: {
              'status': 1,
              'ref': ref,
            },
          );
          return;
        }

        if (state is InAppPurchaseError) {
          final navigatorContext = navigatorKey?.currentContext ?? context;
          await ReusableModal.show(
            context: navigatorContext,
            title: 'پرداخت بازار',
            message: state.message,
            type: ModalType.error,
            buttonText: 'باشه',
          );
        }
      },
      child: child,
    );
  }
}
