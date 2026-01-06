class ReferralCodeResponse {
  final bool status;
  final int code;
  final dynamic message;
  final ReferralCodeData? data;

  ReferralCodeResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ReferralCodeResponse.fromJson(Map<String, dynamic> json) {
    return ReferralCodeResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null
          ? ReferralCodeData.fromJson(json['data'])
          : null,
    );
  }
}

class ReferralCodeData {
  final String referralCode;

  ReferralCodeData({required this.referralCode});

  factory ReferralCodeData.fromJson(Map<String, dynamic> json) {
    return ReferralCodeData(referralCode: json['referral_code'] ?? '');
  }
}
