class CreateDepositRequest {
  final int userId;
  final double amount;
  final String transactionHash;
  final String remarks;

  CreateDepositRequest({
    required this.userId,
    required this.amount,
    required this.transactionHash,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'amount': amount,
      'transaction_hash': transactionHash,
      'remarks': remarks,
    };
  }
}

class CreateDepositData {
  final int depositId;
  final String status;

  CreateDepositData({
    required this.depositId,
    required this.status,
  });

  factory CreateDepositData.fromJson(Map<String, dynamic> json) {
    return CreateDepositData(
      depositId: json['deposit_id'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class CreateDepositResponse {
  final bool status;
  final int code;
  final String message;
  final CreateDepositData? data;

  CreateDepositResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory CreateDepositResponse.fromJson(Map<String, dynamic> json) {
    return CreateDepositResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CreateDepositData.fromJson(json['data'])
          : null,
    );
  }
}

class DepositItem {
  final int id;
  final String amount;
  final String transactionHash;
  final String remarks;
  final String status;
  final String? approveDate;
  final String? adminNotes;
  final String createdAt;

  DepositItem({
    required this.id,
    required this.amount,
    required this.transactionHash,
    required this.remarks,
    required this.status,
    this.approveDate,
    this.adminNotes,
    required this.createdAt,
  });

  factory DepositItem.fromJson(Map<String, dynamic> json) {
    return DepositItem(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? '0.00',
      transactionHash: json['transaction_hash'] ?? '',
      remarks: json['remarks'] ?? '',
      status: json['status'] ?? '',
      approveDate: json['approve_date'],
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class GetDepositsResponse {
  final bool status;
  final int code;
  final String message;
  final List<DepositItem> data;

  GetDepositsResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory GetDepositsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = <DepositItem>[];
    if (json['data'] is List) {
      dataList.addAll(
        (json['data'] as List).map(
          (e) => DepositItem.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return GetDepositsResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: dataList,
    );
  }
}