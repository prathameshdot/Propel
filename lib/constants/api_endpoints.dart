class ApiEndpoints {
  // General API
  static const String packagesList = '/api/v1/packages-list';
  static const String createPayment = '/api/v1/payments';
  static const String referralCode = '/api/v1/referral/code';

  // User Dashboard
  static const String userDashboard = '/api/v1/user-get/dashboard';

  // User Authentication
  static const String register = '/admin/user/register';
  static const String login = '/admin/user/login';

  // OLD API
  static const String referralList = '/api/v1/referral/list';
  static const String referralStore = '/api/v1/referral/store';

  // User KYC
  static const String submitKyc = '/api/user-kyc/kyc/submit';
  static const String getKyc = '/api/user/kyc/get';

  // Master Image
  static const String uploadMasterImage = '/api/user/master-image/upload';

  // MLM
  static const String checkPosition = '/api/mlm/check-position';
  static const String mlmTree = '/api/mlm/tree'; // use /{user_id} when calling

  // Rewards
  static const String rewards = '/api/rewards';
}
