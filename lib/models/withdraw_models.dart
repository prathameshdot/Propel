class CreateWithdrawResponse {
  final bool status;
  final int code;
  final String message;
  final CreateWithdrawData? data;

  CreateWithdrawResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory CreateWithdrawResponse.fromJson(Map<String, dynamic> json) {
    return CreateWithdrawResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? CreateWithdrawData.fromJson(json['data']) : null,
    );
  }
}

class CreateWithdrawData {
  final int withdrawId;
  final int userId;
  final String walletType;
  final String amount;
  final String usdtAddress;
  final String status;
  final String createdAt;

  CreateWithdrawData({
    required this.withdrawId,
    required this.userId,
    required this.walletType,
    required this.amount,
    required this.usdtAddress,
    required this.status,
    required this.createdAt,
  });

  factory CreateWithdrawData.fromJson(Map<String, dynamic> json) {
    return CreateWithdrawData(
      withdrawId: json['withdraw_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      walletType: json['wallet_type'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      usdtAddress: json['usdt_address'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class WithdrawItem {
  final int id;
  final int userId;
  final String walletType;
  final String amount;
  final String usdtAddress;
  final String status;
  final String createdAt;

  WithdrawItem({
    required this.id,
    required this.userId,
    required this.walletType,
    required this.amount,
    required this.usdtAddress,
    required this.status,
    required this.createdAt,
  });

  factory WithdrawItem.fromJson(Map<String, dynamic> json) {
    return WithdrawItem(
      id: json['withdraw_id'] ?? json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      walletType: json['wallet_type'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      usdtAddress: json['usdt_address'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class GetWithdrawsResponse {
  final bool status;
  final int code;
  final String message;
  final List<WithdrawItem> data;

  GetWithdrawsResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory GetWithdrawsResponse.fromJson(Map<String, dynamic> json) {
    final list = <WithdrawItem>[];
    if (json['data'] is List) {
      list.addAll((json['data'] as List).map((e) => WithdrawItem.fromJson(e as Map<String, dynamic>)));
    }
    return GetWithdrawsResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: list,
    );
  }
}
