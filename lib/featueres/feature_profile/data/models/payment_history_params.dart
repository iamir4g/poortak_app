class PaymentHistoryParams {
  final int size;
  final int page;
  final String order;
  final String? referenceId;
  final String? trackingCode;
  final String? status;

  const PaymentHistoryParams({
    this.size = 10,
    this.page = 1,
    this.order = 'desc',
    this.referenceId,
    this.trackingCode,
    this.status,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'size': size,
      'page': page,
      'order': order,
    };

    if (referenceId != null && referenceId!.isNotEmpty) {
      params['referenceId'] = referenceId;
    }

    if (trackingCode != null && trackingCode!.isNotEmpty) {
      params['trackingCode'] = trackingCode;
    }

    if (status != null && status!.isNotEmpty) {
      params['status'] = status;
    }

    return params;
  }

  PaymentHistoryParams copyWith({
    int? size,
    int? page,
    String? order,
    String? referenceId,
    String? trackingCode,
    String? status,
  }) {
    return PaymentHistoryParams(
      size: size ?? this.size,
      page: page ?? this.page,
      order: order ?? this.order,
      referenceId: referenceId ?? this.referenceId,
      trackingCode: trackingCode ?? this.trackingCode,
      status: status ?? this.status,
    );
  }
}

enum PaymentOrder {
  asc('asc'),
  desc('desc');

  const PaymentOrder(this.value);
  final String value;
}

enum PaymentStatus {
  pending('Pending'),
  succeeded('Succeeded'),
  failed('Failed'),
  expired('Expired'),
  refunded('Refunded');

  const PaymentStatus(this.value);
  final String value;
}
