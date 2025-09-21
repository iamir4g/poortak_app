// Example usage of PaymentHistoryBloc
// This file demonstrates how to use the payment history bloc with different query parameters

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_params.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_bloc/payment_history_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_bloc/payment_history_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_bloc/payment_history_state.dart';

class PaymentHistoryUsageExample extends StatelessWidget {
  const PaymentHistoryUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentHistoryBloc(
        repository: context.read(), // Assuming ProfileRepository is provided
      ),
      child: const PaymentHistoryExampleWidget(),
    );
  }
}

class PaymentHistoryExampleWidget extends StatefulWidget {
  const PaymentHistoryExampleWidget({super.key});

  @override
  State<PaymentHistoryExampleWidget> createState() =>
      _PaymentHistoryExampleWidgetState();
}

class _PaymentHistoryExampleWidgetState
    extends State<PaymentHistoryExampleWidget> {
  @override
  void initState() {
    super.initState();
    // Load initial payment history with default parameters
    context.read<PaymentHistoryBloc>().add(LoadPaymentHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
        builder: (context, state) {
          if (state is PaymentHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PaymentHistoryRefreshing) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PaymentHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PaymentHistoryBloc>()
                          .add(LoadPaymentHistoryEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is PaymentHistoryEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PaymentHistoryBloc>()
                          .add(RefreshPaymentHistoryEvent());
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          } else if (state is PaymentHistorySuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<PaymentHistoryBloc>()
                    .add(RefreshPaymentHistoryEvent());
              },
              child: ListView.builder(
                itemCount: state.paymentHistoryList.data.length +
                    (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index == state.paymentHistoryList.data.length) {
                    // Load more button
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<PaymentHistoryBloc>()
                              .add(LoadMorePaymentHistoryEvent());
                        },
                        child: const Text('Load More'),
                      ),
                    );
                  }

                  final payment = state.paymentHistoryList.data[index];
                  return ListTile(
                    title: Text(payment.trackingCode),
                    subtitle: Text('Status: ${payment.status.name}'),
                    trailing: Text(payment.grandTotal),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Initial state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadWithCustomParams,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Payment History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Filter by pending status
                final params = PaymentHistoryParams(
                  status: PaymentStatus.pending.value,
                  size: 10,
                  page: 1,
                );
                context
                    .read<PaymentHistoryBloc>()
                    .add(FilterPaymentHistoryEvent(params: params));
                Navigator.pop(context);
              },
              child: const Text('Show Pending'),
            ),
            ElevatedButton(
              onPressed: () {
                // Filter by succeeded status
                final params = PaymentHistoryParams(
                  status: PaymentStatus.succeeded.value,
                  size: 10,
                  page: 1,
                );
                context
                    .read<PaymentHistoryBloc>()
                    .add(FilterPaymentHistoryEvent(params: params));
                Navigator.pop(context);
              },
              child: const Text('Show Succeeded'),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear filters
                context
                    .read<PaymentHistoryBloc>()
                    .add(LoadPaymentHistoryEvent());
                Navigator.pop(context);
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadWithCustomParams() {
    // Example: Load payment history with custom parameters
    final params = PaymentHistoryParams(
      size: 20,
      page: 1,
      order: PaymentOrder.desc.value,
      status: PaymentStatus.succeeded.value,
    );

    context
        .read<PaymentHistoryBloc>()
        .add(LoadPaymentHistoryEvent(params: params));
  }
}

// Example of how to use the bloc in different scenarios:

class PaymentHistoryExamples {
  static void loadDefaultHistory(BuildContext context) {
    // Load with default parameters (size: 10, page: 1, order: desc)
    context.read<PaymentHistoryBloc>().add(LoadPaymentHistoryEvent());
  }

  static void loadWithPagination(BuildContext context) {
    // Load specific page
    final params = PaymentHistoryParams(page: 2, size: 15);
    context
        .read<PaymentHistoryBloc>()
        .add(LoadPaymentHistoryEvent(params: params));
  }

  static void loadWithStatusFilter(BuildContext context) {
    // Load only pending payments
    final params = PaymentHistoryParams(
      status: PaymentStatus.pending.value,
      size: 10,
      page: 1,
    );
    context
        .read<PaymentHistoryBloc>()
        .add(FilterPaymentHistoryEvent(params: params));
  }

  static void loadWithReferenceId(BuildContext context, String referenceId) {
    // Load payments by reference ID
    final params = PaymentHistoryParams(
      referenceId: referenceId,
      size: 10,
      page: 1,
    );
    context
        .read<PaymentHistoryBloc>()
        .add(LoadPaymentHistoryEvent(params: params));
  }

  static void loadWithTrackingCode(BuildContext context, String trackingCode) {
    // Load payments by tracking code
    final params = PaymentHistoryParams(
      trackingCode: trackingCode,
      size: 10,
      page: 1,
    );
    context
        .read<PaymentHistoryBloc>()
        .add(LoadPaymentHistoryEvent(params: params));
  }

  static void loadAscendingOrder(BuildContext context) {
    // Load with ascending order
    final params = PaymentHistoryParams(
      order: PaymentOrder.asc.value,
      size: 10,
      page: 1,
    );
    context
        .read<PaymentHistoryBloc>()
        .add(LoadPaymentHistoryEvent(params: params));
  }

  static void refreshHistory(BuildContext context) {
    // Refresh current data
    context.read<PaymentHistoryBloc>().add(RefreshPaymentHistoryEvent());
  }

  static void loadMoreHistory(BuildContext context) {
    // Load more data (pagination)
    context.read<PaymentHistoryBloc>().add(LoadMorePaymentHistoryEvent());
  }
}
