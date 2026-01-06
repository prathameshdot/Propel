class SubmitKycResponse {
  final bool status;
  final dynamic message;
  final Map<String, dynamic> data;

  SubmitKycResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SubmitKycResponse.fromJson(Map<String, dynamic> json) {
    return SubmitKycResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] ?? {},
    );
  }
}

class GetKycResponse {
  final bool status;
  final dynamic message;
  final KYCData? data;

  GetKycResponse({required this.status, required this.message, this.data});

  factory GetKycResponse.fromJson(Map<String, dynamic> json) {
    return GetKycResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null ? KYCData.fromJson(json['data']) : null,
    );
  }
}

class KYCData {
  final int id;
  final int userId;
  final String aadharFront;
  final String aadharBack;
  final String pancard;
  final String bankAccountNumber;
  final String bankIfsc;
  final String bankName;
  final String bankBranch;
  final String accountHolderName;
  final String status; // 'pending', 'verified', 'approved'
  final String? reason;
  final String createdAt;
  final String updatedAt;

  KYCData({
    required this.id,
    required this.userId,
    required this.aadharFront,
    required this.aadharBack,
    required this.pancard,
    required this.bankAccountNumber,
    required this.bankIfsc,
    required this.bankName,
    required this.bankBranch,
    required this.accountHolderName,
    required this.status,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KYCData.fromJson(Map<String, dynamic> json) {
    return KYCData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      aadharFront: json['adhar_front'] ?? '',
      aadharBack: json['adhar_back'] ?? '',
      pancard: json['pancard'] ?? '',
      bankAccountNumber: json['bank_account_number'] ?? '',
      bankIfsc: json['bank_ifsc'] ?? '',
      bankName: json['bank_name'] ?? '',
      bankBranch: json['bank_branch'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      status: json['status'] ?? 'pending',
      reason: json['reason'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
