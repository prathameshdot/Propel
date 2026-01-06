import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/dashboard_response.dart';
import '../models/packages_list_response.dart';
import '../models/payment_models.dart';
import '../models/referral_code_response.dart';
import '../models/referrals_list_response.dart';
import '../models/create_referral_models.dart';
import '../models/kyc_models.dart';
import '../models/upload_image_response.dart';
import '../models/login_response.dart';
import '../models/register_response.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../models/mlm_check_position_response.dart';
import '../models/mlm_tree_response.dart';
import '../models/root_package_detail_response.dart';
import '../models/user_profile_response.dart';
import '../models/superadmin_wallet_response.dart';
import '../models/user_deposit_models.dart';
import '../models/api_response.dart';
import '../models/global_turnover_response.dart';
import '../models/matching_income_response.dart';
import '../models/direct_income_response.dart';
import '../models/my_team_response.dart';
import '../models/wallet_history_response.dart';
import '../models/withdraw_models.dart';
import '../models/rewards_response.dart';
import '../models/business_detail_response.dart';
import '../models/reward_income_response.dart';
import 'api_service.dart';

class ApiRepository {
  // Authentication
  static Future<LoginResponse?> login(LoginRequest request) async {
    final response = await ApiService.post(
      ApiConstants.login,
      request.toJson(),
      requireAuth: false,
    );
    return response != null ? LoginResponse.fromJson(response) : null;
  }

  static Future<RegisterResponse?> register(RegisterRequest request) async {
    final response = await ApiService.post(
      ApiConstants.register,
      request.toJson(),
      requireAuth: false,
    );
    return response != null ? RegisterResponse.fromJson(response) : null;
  }

  // General
  static Future<PackagesListResponse?> getPackagesList() async {
    final response = await ApiService.get(ApiConstants.packagesList);
    return response != null ? PackagesListResponse.fromJson(response) : null;
  }

  static Future<CreatePaymentResponse?> createPayment(
    CreatePaymentRequest request,
  ) async {
    final response = await ApiService.post(
      ApiConstants.createPayment,
      request.toJson(),
    );
    return response != null ? CreatePaymentResponse.fromJson(response) : null;
  }

  static Future<ReferralCodeResponse?> getReferralCode(int userId) async {
    final response = await ApiService.get(
      ApiConstants.referralCode,
      queryParams: {'user_id': userId.toString()},
    );
    return response != null ? ReferralCodeResponse.fromJson(response) : null;
  }

  // Dashboard
  static Future<DashboardResponse?> getDashboard(int userId) async {
    final response = await ApiService.get(
      '${ApiConstants.userDashboard}/$userId',
    );
    return response != null ? DashboardResponse.fromJson(response) : null;
  }

  // Referrals (OLD)
  static Future<ReferralsListResponse?> getReferralsList({
    int? userId,
    String? referralCode,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['user_id'] = userId.toString();
    if (referralCode != null) queryParams['referral_code'] = referralCode;
    final response = await ApiService.get(
      ApiConstants.referralsList,
      queryParams: queryParams,
    );
    return response != null ? ReferralsListResponse.fromJson(response) : null;
  }

  static Future<CreateReferralResponse?> createReferral(
    CreateReferralRequest request,
  ) async {
    final response = await ApiService.post(
      ApiConstants.createReferral,
      request.toJson(),
    );
    return response != null ? CreateReferralResponse.fromJson(response) : null;
  }

  // MLM
  static Future<MlmCheckPositionResponse?> checkPosition({
    required String refCode,
    required String joinPosition,
  }) async {
    final response = await ApiService.post(ApiConstants.checkPosition, {
      'ref_code': refCode,
      'join_position': joinPosition,
    });
    return response != null
        ? MlmCheckPositionResponse.fromJson(response)
        : null;
  }

  static Future<MlmTreeResponse?> getMlmTree(
    int userId, {
    String usedMyReferenceCode = 'all',
    String? fromDate,
    String? toDate,
    String? side,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'usedmyrefrencecode': usedMyReferenceCode,
    };
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;
    if (side != null) queryParams['side'] = side;
    if (status != null) queryParams['status'] = status;
    final response = await ApiService.get(
      '${ApiConstants.mlmTree}/$userId',
      queryParams: queryParams,
    );
    return response != null ? MlmTreeResponse.fromJson(response) : null;
  }

  // Rewards
  static Future<RewardsResponse?> getRewards() async {
    final response = await ApiService.get(ApiConstants.rewards);
    return response != null ? RewardsResponse.fromJson(response) : null;
  }

  // Reward Income (per user)
  static Future<RewardIncomeResponse?> getRewardIncome(int userId) async {
    final response = await ApiService.get('${ApiConstants.rewardIncome}/$userId');
    return response != null ? RewardIncomeResponse.fromJson(response) : null;
  }

  // KYC
  static Future<SubmitKycResponse?> submitKyc(
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final response = await ApiService.multipartPost(
      ApiConstants.submitKyc,
      fields,
      files: files,
    );
    return response != null ? SubmitKycResponse.fromJson(response) : null;
  }

  static Future<GetKycResponse?> getKyc(int userId) async {
    final response = await ApiService.get(
      ApiConstants.getKyc,
      queryParams: {'user_id': userId.toString()},
    );
    return response != null ? GetKycResponse.fromJson(response) : null;
  }

  // Master Image
  static Future<UploadMasterImageResponse?> uploadMasterImage(
    http.MultipartFile image,
  ) async {
    final response = await ApiService.multipartPost(
      ApiConstants.uploadMasterImage,
      {},
      files: [image],
    );
    return response != null
        ? UploadMasterImageResponse.fromJson(response)
        : null;
  }

  // MLM
  static Future<RootPackageDetailResponse?> getRootPackageDetail({
    required int userId,
    String? fromDate,
    String? toDate,
    String type = 'package_by_user',
  }) async {
    final queryParams = <String, String>{
      'user_id': userId.toString(),
      'type': type,
    };
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;
    final response = await ApiService.get(
      ApiConstants.rootPackageDetail,
      queryParams: queryParams,
    );
    return response != null ? RootPackageDetailResponse.fromJson(response) : null;
  }

  // User Profile
  static Future<UserProfileResponse?> getUserProfile(int userId) async {
    final response = await ApiService.post(
      ApiConstants.userProfile,
      {'user_id': userId},
    );
    return response != null ? UserProfileResponse.fromJson(response) : null;
  }

  // Change Password
  static Future<ApiResponse?> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await ApiService.post(
      ApiConstants.changePassword,
      {
        'user_id': userId,
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );
    return response != null ? ApiResponse.fromJson(response) : null;
  }

  // Edit user profile (update basic fields, save USDT address via same endpoint if supported)
  static Future<ApiResponse?> editUserProfile({
    required int userId,
    String? firstName,
    String? lastName,
    String? email,
    String? mobile,
    String? usdtAddress,
  }) async {
    final body = <String, dynamic>{'user_id': userId};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (email != null) body['email'] = email;
    if (mobile != null) body['mobile'] = mobile;
    if (usdtAddress != null) body['usdt_address'] = usdtAddress;

    final response = await ApiService.post(ApiConstants.userProfileEdit, body);
    return response != null ? ApiResponse.fromJson(response) : null;
  }

  // Superadmin Wallet
  static Future<SuperadminWalletResponse?> getSuperadminWallet() async {
    final response = await ApiService.get(ApiConstants.superadminWallet);
    return response != null ? SuperadminWalletResponse.fromJson(response) : null;
  }

  // User Deposit
  static Future<CreateDepositResponse?> createDeposit(
    CreateDepositRequest request,
  ) async {
    final response = await ApiService.post(
      ApiConstants.userDeposit,
      request.toJson(),
    );
    return response != null ? CreateDepositResponse.fromJson(response) : null;
  }

  static Future<GetDepositsResponse?> getDeposits(int userId) async {
    final response = await ApiService.get(
      ApiConstants.userDeposit,
      queryParams: {'user_id': userId.toString()},
    );
    return response != null ? GetDepositsResponse.fromJson(response) : null;
  }

  // Dashboard - additional endpoints
  static Future<GlobalTurnoverResponse?> getGlobalTurnover(int userId) async {
    final response = await ApiService.get('${ApiConstants.globalTurnover}/$userId');
    return response != null ? GlobalTurnoverResponse.fromJson(response) : null;
  }

  static Future<MatchingIncomeResponse?> getMatchingIncome(int userId) async {
    final response = await ApiService.get('${ApiConstants.matchingIncome}/$userId');
    return response != null ? MatchingIncomeResponse.fromJson(response) : null;
  }

  static Future<DirectIncomeResponse?> getDirectIncome(int userId) async {
    final response = await ApiService.get('${ApiConstants.directIncome}/$userId');
    return response != null ? DirectIncomeResponse.fromJson(response) : null;
  }

  static Future<MyTeamResponse?> getMyTeam(int userId) async {
    final response = await ApiService.get('${ApiConstants.myTeam}/$userId');
    return response != null ? MyTeamResponse.fromJson(response) : null;
  }

  static Future<WalletHistoryResponse?> getWalletHistory(int userId) async {
    final response = await ApiService.get('${ApiConstants.walletHistory}/$userId');
    return response != null ? WalletHistoryResponse.fromJson(response) : null;
  }

  // Withdraw
  static Future<CreateWithdrawResponse?> createWithdraw(Map<String, dynamic> body) async {
    final response = await ApiService.post(ApiConstants.withdrawAmount, body);
    return response != null ? CreateWithdrawResponse.fromJson(response) : null;
  }

  static Future<GetWithdrawsResponse?> getWithdraws(int userId) async {
    final response = await ApiService.get(
      ApiConstants.withdrawAmount,
      queryParams: {'user_id': userId.toString()},
    );
    return response != null ? GetWithdrawsResponse.fromJson(response) : null;
  }

  // Business detail (daily PV)
  static Future<BusinessDetailResponse?> getBusinessDetail(int userId) async {
    final response = await ApiService.get('${ApiConstants.businessDetail}/$userId');
    return response != null ? BusinessDetailResponse.fromJson(response) : null;
  }
}
