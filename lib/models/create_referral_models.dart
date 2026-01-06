import 'referrals_list_response.dart';

class CreateReferralRequest {
  final String referralCode;
  final String firstName;
  final String lastName;

  CreateReferralRequest({
    required this.referralCode,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'referral_code': referralCode,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}

class CreateReferralResponse {
  final bool status;
  final int code;
  final dynamic message;
  final ReferralData? data;

  CreateReferralResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory CreateReferralResponse.fromJson(Map<String, dynamic> json) {
    return CreateReferralResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? ReferralData.fromJson(json['data']) : null,
    );
  }
}

class ReferralData {
  final Referral referral;

  ReferralData({required this.referral});

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(referral: Referral.fromJson(json['referral']));
  }
}
