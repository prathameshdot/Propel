class ReferralsListResponse {
  final bool status;
  final int code;
  final dynamic message;
  final ReferralsData? data;

  ReferralsListResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ReferralsListResponse.fromJson(Map<String, dynamic> json) {
    return ReferralsListResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? ReferralsData.fromJson(json['data']) : null,
    );
  }
}

class ReferralsData {
  final List<Referral> referrals;

  ReferralsData({required this.referrals});

  factory ReferralsData.fromJson(Map<String, dynamic> json) {
    return ReferralsData(
      referrals:
          (json['referrals'] as List<dynamic>?)
              ?.map((e) => Referral.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Referral {
  final int id;
  final String firstName;
  final String lastName;
  final String positionName;
  final String createdAt;

  Referral({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.positionName,
    required this.createdAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      positionName: json['position_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
