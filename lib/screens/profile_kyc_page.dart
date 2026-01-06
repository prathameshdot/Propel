import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_repository.dart';
import '../utils/colors.dart';
import '../routes/app_router.dart';
import '../models/user_profile_response.dart';

class ProfileKYCPage extends StatefulWidget {
  const ProfileKYCPage({super.key});

  @override
  State<ProfileKYCPage> createState() => _ProfileKYCPageState();
}

class _ProfileKYCPageState extends State<ProfileKYCPage> {
  bool _isLoading = true;
  String _accountStatus = 'Inactive';
  String _kycStatus = 'Pending';
  int _kycVerified = 0;

  // Dashboard-specific fields
  String _walletBalance = '0';
  int _leftTeamCount = 0;
  int _rightTeamCount = 0;
  bool _isFetchingDashboard = false;

  // User Profile data
  UserProfileData? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _refreshUserData(); // Refresh in background
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedKycVerified = await AuthService.getKycVerified();
      if (cachedKycVerified != null) {
        setState(() {
          _kycVerified = cachedKycVerified;
          _kycStatus = cachedKycVerified == 1 ? 'Verified' : 'Pending';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshUserData() async {
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) return;

      final userId = int.parse(userIdStr);

      // Fetch KYC status
      final kycResponse = await ApiRepository.getKyc(userId);

      if (kycResponse != null &&
          kycResponse.status &&
          kycResponse.data != null) {
        // status can be true/false (boolean) or "pending"/"verified" (string)
        final statusStr = kycResponse.data!.status.toString().toLowerCase();
        final isVerified =
            statusStr == 'true' ||
            statusStr == 'verified' ||
            statusStr == 'approved';
        final verified = isVerified ? 1 : 0;
        final displayStatus = isVerified ? 'Verified' : 'Pending';
        await AuthService.setKycStatus(verified, displayStatus);

        if (mounted) {
          setState(() {
            _kycVerified = verified;
            _kycStatus = displayStatus;
          });
        }
      }

      // Fetch referral code to determine account status
      final referralResponse = await ApiRepository.getReferralCode(userId);

      if (referralResponse != null && referralResponse.status) {
        final referralCode = referralResponse.data?.referralCode ?? '';
        if (mounted) {
          setState(() {
            _accountStatus = referralCode.isNotEmpty ? 'Active' : 'Inactive';
          });
        }
      }

      // Fetch Dashboard data to show wallet and team counts in profile
      setState(() {
        _isFetchingDashboard = true;
      });
      try {
        final dashboardResp = await ApiRepository.getDashboard(userId);
        if (dashboardResp != null &&
            dashboardResp.status &&
            dashboardResp.data != null) {
          final d = dashboardResp.data!;
          if (mounted) {
            setState(() {
              _walletBalance = d.walletBalance;
              _leftTeamCount = d.leftTeamCount;
              _rightTeamCount = d.rightTeamCount;
            });
          }
        } else if (dashboardResp != null && !dashboardResp.status) {
          // API returned an error payload
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(dashboardResp.message)));
          }
        }
      } catch (e) {
        // Surface network error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to fetch dashboard data. Please check your connection.',
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isFetchingDashboard = false;
          });
        }
      }

      // Fetch User Profile data
      try {
        final profileResp = await ApiRepository.getUserProfile(userId);
        if (profileResp != null && profileResp.status && profileResp.data != null) {
          if (mounted) {
            setState(() {
              _userProfile = profileResp.data;
            });
          }
        }
      } catch (e) {
        // Silently handle profile fetch error
      }
    } catch (e) {
      // Silently handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile & KYC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Loading profile...'),
                        ],
                      ),
                    ),
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage('assets/profile.avif'),
                          backgroundColor: Color(0xFFE0E0E0),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _userProfile?.basicInfo.fullName ?? 'User',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${_userProfile?.basicInfo.userId ?? "N/A"}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),

                        // Wallet and Team summary row
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSummaryBox(
                                'Wallet',
                                '\$$_walletBalance',
                                isLoading: _isFetchingDashboard,
                              ),
                              const SizedBox(width: 12),
                              _buildSummaryBox(
                                'Left',
                                '$_leftTeamCount',
                                isLoading: _isFetchingDashboard,
                              ),
                              const SizedBox(width: 12),
                              _buildSummaryBox(
                                'Right',
                                '$_rightTeamCount',
                                isLoading: _isFetchingDashboard,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        _buildContactRow(Icons.phone, _userProfile?.basicInfo.mobile ?? '+91 XXXXX XXXXX'),
                        _buildDivider(),
                        _buildContactRow(Icons.email, _userProfile?.basicInfo.email ?? 'email@example.com'),
                        _buildDivider(),
                        _buildContactRow(Icons.person, _userProfile?.basicInfo.username ?? 'username'),
                        _buildDivider(),
                        _buildContactRow(Icons.calendar_today, _formatJoinDate(_userProfile?.basicInfo.createdAt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _accountStatus == 'Active'
                                    ? Icons.check_circle
                                    : Icons.account_balance,
                                color: _accountStatus == 'Active'
                                    ? Colors.green
                                    : AppColors.brand,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Account Status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _accountStatus,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _accountStatus == 'Active'
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _kycVerified == 1
                                    ? Icons.verified_user
                                    : Icons.pending,
                                color: _kycVerified == 1
                                    ? Colors.green
                                    : AppColors.brand,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'KYC Status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _kycStatus,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _kycVerified == 1
                                            ? Colors.green
                                            : Colors.orange[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Profile Management Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        _buildProfileButton(
                          'Change Password',
                          Icons.lock,
                          () => Navigator.of(context).pushNamed(AppRouter.changePassword),
                        ),
                        const SizedBox(height: 15),
                        _buildProfileButton(
                          'Edit Profile',
                          Icons.edit,
                          () => Navigator.of(context).pushNamed(AppRouter.editProfile),
                        ),
                        const SizedBox(height: 15),
                        _buildProfileButton(
                          'USDT Address',
                          Icons.account_balance_wallet,
                          () => Navigator.of(context).pushNamed(AppRouter.usdtAddress),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.brand, size: 22),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[200], thickness: 1, height: 1);
  }

  Widget _buildSummaryBox(
    String label,
    String value, {
    bool isLoading = false,
  }) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.brand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.brand, width: 1),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatJoinDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}
