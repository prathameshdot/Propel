import 'package:flutter/material.dart';
import '../screens/dashboard_page.dart';
import '../screens/login_page.dart';
import '../screens/refer_and_earn_page.dart';
import '../screens/my_team_page.dart';
import '../screens/support_page.dart';
import '../screens/terms_conditions_page.dart';
import '../screens/profile_kyc_page.dart';
import '../screens/withdraw_request_page.dart';
import '../screens/rank_system_page.dart';
import '../screens/global_turnover_page.dart';
import '../screens/matching_income_page.dart';
import '../screens/reward_income_page.dart';
import '../screens/wallet_page.dart';
import '../screens/direct_referral_income_page.dart';
import '../screens/transaction_history_page.dart';
import '../screens/create_account_page.dart';
import '../screens/splash_screen.dart';
import '../screens/account_inactive_page.dart';
import '../screens/activation_packages_page.dart';
import '../screens/topup_details_page.dart';
import '../screens/investment_request_page.dart';
import '../screens/change_password_page.dart';
import '../screens/edit_profile_page.dart';
import '../screens/usdt_address_page.dart';
import '../screens/binary_tree_page.dart';
import '../screens/business_details_page.dart';
import '../screens/referrals_page.dart';
import '../screens/package_page.dart';
import '../screens/complete_kyc_page.dart';
import '../models/packages_list_response.dart';

class AppRouter {
  static const String home = '/home';
  static const String login = '/login';
  static const String referEarn = '/refer-earn';
  static const String myTeam = '/my-team';
  static const String support = '/support';
  static const String terms = '/terms';
  static const String profile = '/profile';
  static const String withdraw = '/withdraw';
  static const String incomeReport = '/income-report';
  static const String rankSystem = '/rank-system';
  static const String globalTurnover = '/global-turnover';
  static const String matchingIncome = '/matching-income';
  static const String rewardIncome = '/reward-income';
  static const String dailyIncome = '/daily-income';
  static const String dailyIncomeV2 = '/daily-income-v2';
  static const String wallet = '/wallet';
  static const String directReferralIncome = '/direct-referral-income';
  static const String transactionHistory = '/transaction-history';
  static const String createAccount = '/create-account';
  static const String splash = '/splash';
  static const String accountInactive = '/account-inactive';
  static const String activationPackages = '/activation-packages';
  static const String packageActivation = '/package-activation';
  static const String package = '/package';
  static const String topupDetails = '/topup-details';
  static const String investmentRequest = '/investment-request';
  static const String completeKYC = '/complete-kyc';
  static const String changePassword = '/change-password';
  static const String editProfile = '/edit-profile';
  static const String usdtAddress = '/usdt-address';
  static const String binaryTree = '/binary-tree';
  static const String businessDetails = '/business-details';
  static const String referrals = '/referrals';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case referEarn:
        return MaterialPageRoute(builder: (_) => const ReferAndEarnPage());
      case myTeam:
        return MaterialPageRoute(builder: (_) => const MyTeamPage());
      case support:
        return MaterialPageRoute(builder: (_) => const SupportPage());
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsConditionsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileKYCPage());
      case withdraw:
        return MaterialPageRoute(builder: (_) => const WithdrawRequestPage());
      case incomeReport:
        return MaterialPageRoute(builder: (_) => const WithdrawRequestPage());
      case rankSystem:
        return MaterialPageRoute(builder: (_) => const RankSystemPage());
      case globalTurnover:
        return MaterialPageRoute(builder: (_) => const GlobalTurnoverPage());
      case matchingIncome:
        return MaterialPageRoute(builder: (_) => const MatchingIncomePage());
      case rewardIncome:
        return MaterialPageRoute(builder: (_) => const RewardIncomePage());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletPage());
      case directReferralIncome:
        return MaterialPageRoute(
          builder: (_) => const DirectReferralIncomePage(),
        );
      case transactionHistory:
        return MaterialPageRoute(
          builder: (_) => const TransactionHistoryPage(),
        );
      case createAccount:
        return MaterialPageRoute(builder: (_) => const CreateAccountPage());
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case accountInactive:
        return MaterialPageRoute(builder: (_) => const AccountInactivePage());
      case activationPackages:
        return MaterialPageRoute(
          builder: (_) => const ActivationPackagesPage(),
        );
      case packageActivation:
        final package = settings.arguments as Package;
        return MaterialPageRoute(
          builder: (_) => PackagePage(package: package),
        );
      case package:
        final package = settings.arguments as Package;
        return MaterialPageRoute(
          builder: (_) => PackagePage(package: package),
        );
      case topupDetails:
        return MaterialPageRoute(
          builder: (_) => const TopupDetailsPage(),
        );
      case investmentRequest:
        return MaterialPageRoute(
          builder: (_) => const InvestmentRequestPage(),
        );
      case completeKYC:
        return MaterialPageRoute(builder: (_) => const CompleteKYCPage());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case usdtAddress:
        return MaterialPageRoute(builder: (_) => const UsdtAddressPage());
      case binaryTree:
        return MaterialPageRoute(builder: (_) => const BinaryTreePage());
      case businessDetails:
        return MaterialPageRoute(builder: (_) => const BusinessDetailsPage());
      case referrals:
        return MaterialPageRoute(builder: (_) => const ReferralsPage());
      case dailyIncome:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case dailyIncomeV2:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      default:
        return null;
    }
  }
}
