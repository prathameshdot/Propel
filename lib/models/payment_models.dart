class CreatePaymentRequest {
  final int userId;
  final int packageId;
  final double amount;
  final String paymentMethod;
  final String referenceId;
  final String status;

  CreatePaymentRequest({
    required this.userId,
    required this.packageId,
    required this.amount,
    required this.paymentMethod,
    required this.referenceId,
    this.status = 'completed',
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'package_id': packageId,
      'amount': amount,
      'payment_method': paymentMethod,
      'reference_id': referenceId,
      'status': status,
    };
  }
}

class CreatePaymentResponse {
  final bool status;
  final int code;
  final dynamic message;
  final PaymentData? data;

  CreatePaymentResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory CreatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePaymentResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? PaymentData.fromJson(json['data']) : null,
    );
  }
}

class PaymentData {
  final Payment payment;

  PaymentData({required this.payment});

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(payment: Payment.fromJson(json['payment']));
  }
}

class Payment {
  final int id;
  final int userId;
  final int packageId;
  final double amount;
  final String paymentMethod;
  final String referenceId;
  final String status;
  final String createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.amount,
    required this.paymentMethod,
    required this.referenceId,
    required this.status,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      packageId: json['package_id'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      referenceId: json['reference_id'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
