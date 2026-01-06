class ApiConstants {
  // Authentication
  static const String login = '/admin/user/login';
  static const String register = '/admin/user/register';

  // General
  static const String packagesList = '/api/v1/packages-list';
  static const String createPayment = '/api/v1/payments';
  static const String referralCode = '/api/v1/referral/code';

  // Dashboard
  static const String userDashboard = '/api/v1/user-get/dashboard';

  // Referrals (OLD)
  static const String referralsList = '/api/v1/referral/list';
  static const String createReferral = '/api/v1/referral/store';

  // KYC
  static const String submitKyc = '/api/user-kyc/kyc/submit';
  static const String getKyc = '/api/user/kyc/get';

  // Master Image
  static const String uploadMasterImage = '/api/user/master-image/upload';

  // MLM
  static const String checkPosition = '/api/mlm/check-position';
  static const String mlmTree = '/api/mlm/tree'; // use /{user_id} when calling
  static const String rootPackageDetail = '/api/mlm/root-package-detail';

  // Rewards
  static const String rewards = '/api/rewards';
  static const String rewardIncome = '/api/reward-income';

  // Dashboard - additional endpoints
  static const String globalTurnover = '/api/dashboard/global-turnover';
  static const String matchingIncome = '/api/dashboard/matching-income';
  static const String directIncome = '/api/dashboard/direct-income';
  static const String myTeam = '/api/dashboard/my-team';
  static const String walletHistory = '/api/dashboard/wallet-history';

  // User Profile
  static const String userProfile = '/api/user-profile';
  static const String changePassword = '/api/change-password';
  static const String userProfileEdit = '/api/user-profile-edit';

  // Superadmin Wallet
  static const String superadminWallet = '/api/superadmin-wallet';

  // User Deposit
  static const String userDeposit = '/api/user-deposit';

  // Dashboard - business detail
  static const String businessDetail = '/api/dashboard/business-detail';

  // Withdraw
  static const String withdrawAmount = '/api/withdraw-amount';
}
