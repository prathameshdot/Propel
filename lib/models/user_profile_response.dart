class StatusBadge {
  final String badgeClass;
  final String value;

  StatusBadge({
    required this.badgeClass,
    required this.value,
  });

  factory StatusBadge.fromJson(Map<String, dynamic> json) {
    return StatusBadge(
      badgeClass: json['class'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class BasicInfo {
  final int userId;
  final String? firstName;
  final String? lastName;
  final String fullName;
  final String? username;
  final String email;
  final String mobile;
  final String? profileImage;
  final StatusBadge status;
  final String? lastLogin;
  final String? createdAt;

  BasicInfo({
    required this.userId,
    this.firstName,
    this.lastName,
    required this.fullName,
    this.username,
    required this.email,
    required this.mobile,
    this.profileImage,
    required this.status,
    this.lastLogin,
    this.createdAt,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      profileImage: json['profile_image'],
      status: StatusBadge.fromJson(json['status'] ?? {}),
      lastLogin: json['last_login'],
      createdAt: json['created_at'],
    );
  }
}

class Verification {
  final bool emailVerified;
  final bool smsVerified;
  final StatusBadge kycStatus;

  Verification({
    required this.emailVerified,
    required this.smsVerified,
    required this.kycStatus,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      emailVerified: json['email_verified'] ?? false,
      smsVerified: json['sms_verified'] ?? false,
      kycStatus: StatusBadge.fromJson(json['kyc_status'] ?? {}),
    );
  }
}

class ReferralInfo {
  final String myReferralCode;
  final String? usedReferralCode;
  final int totalReferrals;

  ReferralInfo({
    required this.myReferralCode,
    this.usedReferralCode,
    required this.totalReferrals,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      myReferralCode: json['my_referral_code'] ?? '',
      usedReferralCode: json['used_referral_code'],
      totalReferrals: json['total_referrals'] ?? 0,
    );
  }
}

class Wallet {
  final String? walletType;
  final String balance;

  Wallet({
    this.walletType,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletType: json['wallet_type'],
      balance: json['balance'] ?? '0.00',
    );
  }
}

class UsdtInfo {
  final String? address;
  final String? updatedAt;

  UsdtInfo({this.address, this.updatedAt});

  factory UsdtInfo.fromJson(Map<String, dynamic> json) {
    return UsdtInfo(
      address: json['address'],
      updatedAt: json['updated_at'],
    );
  }
}

class PackageInfo {
  final int? packageId;
  final String? price;
  final String? directPercentage;
  final bool? matchingEligible;
  final String? packageStatus;
  final String? purchasedAt;

  PackageInfo({
    this.packageId,
    this.price,
    this.directPercentage,
    this.matchingEligible,
    this.packageStatus,
    this.purchasedAt,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      packageId: json['package_id'],
      price: json['price'],
      directPercentage: json['direct_percentage'],
      matchingEligible: json['matching_eligible'],
      packageStatus: json['package_status'],
      purchasedAt: json['purchased_at'],
    );
  }
}

class UserProfileData {
  final BasicInfo basicInfo;
  final Verification verification;
  final ReferralInfo referral;
  final List<Wallet> wallets;
  final PackageInfo? package;
  final UsdtInfo? usdt;

  UserProfileData({
    required this.basicInfo,
    required this.verification,
    required this.referral,
    required this.wallets,
    this.package,
    this.usdt,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    final walletsList = <Wallet>[];
    if (json['wallets'] is List) {
      walletsList.addAll(
        (json['wallets'] as List).map(
          (e) => Wallet.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return UserProfileData(
      basicInfo: BasicInfo.fromJson(json['basic_info'] ?? {}),
      verification: Verification.fromJson(json['verification'] ?? {}),
      referral: ReferralInfo.fromJson(json['referral'] ?? {}),
      wallets: walletsList,
      package: json['package'] != null
          ? PackageInfo.fromJson(json['package'])
          : null,
      usdt: json['usdt'] != null ? UsdtInfo.fromJson(json['usdt']) : null,
    );
  }
}

class UserProfileResponse {
  final bool status;
  final int code;
  final String message;
  final UserProfileData? data;

  UserProfileResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UserProfileData.fromJson(json['data'])
          : null,
    );
  }
}