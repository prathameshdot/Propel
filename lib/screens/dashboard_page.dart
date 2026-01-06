import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_drawer.dart';
import '../utils/colors.dart';
import '../routes/app_router.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/dashboard_response.dart';
import '../models/user_profile_response.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DashboardData? _dashboardData;
  UserProfileData? _userProfile;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final userIdString = await AuthService.getUserId();
      if (userIdString == null) {
        setState(() {
          _loading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      final userId = int.tryParse(userIdString) ?? 0;
      
      // Fetch both dashboard and user profile
      final dashboardResponse = ApiRepository.getDashboard(userId);
      final profileResponse = ApiRepository.getUserProfile(userId);
      
      final results = await Future.wait([dashboardResponse, profileResponse]);
      
      if (!mounted) return;

      final dashboardResp = results[0] as DashboardResponse?;
      final profileResp = results[1] as UserProfileResponse?;

      if (dashboardResp != null && dashboardResp.status) {
        setState(() {
          _dashboardData = dashboardResp.data;
        });
      } else {
        setState(() {
          _errorMessage = dashboardResp?.message ?? 'Failed to load dashboard';
        });
      }

      if (profileResp != null && profileResp.status) {
        setState(() {
          _userProfile = profileResp.data;
        });
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          "Main Dashboard",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchDashboard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 20.0),
              child: _buildDashboardContent(),
            ),
      drawer: const AppDrawer(),
    );
  }

  Widget _buildDashboardContent() {
    final data = _dashboardData!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Profile Section ---
        Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/profile.avif'),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userProfile?.basicInfo.fullName ?? "User",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "ID: ${_userProfile?.basicInfo.userId ?? "N/A"}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 3,
                          width: 28,
                          color: const Color(0xFFFFD54F),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rank',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF3979D3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 28,
                          color: const Color(0xFF3979D3),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Associate',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[500], size: 16),
                  const SizedBox(width: 5),
                  Text(
                    "Active",
                    style: GoogleFonts.poppins(
                      color: Colors.green[500],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),

        // --- Income Cards Row ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIncomeCard(
              label: "Direct\nIncome",
              amount: "\$${_formatAmount(data.directIncome)}",
              amountColor: AppColors.brand,
            ),
            _buildIncomeCard(
              label: "Matching\nIncome",
              amount: "\$${_formatAmount(data.matchingIncome)}",
              amountColor: const Color(0xFF333333),
            ),
            _buildIncomeCard(
              label: "Wallet\nBalance",
              amount: "\$${_formatAmount(data.walletBalance)}",
              amountColor: const Color(0xFF333333),
            ),
          ],
        ),
        const SizedBox(height: 25),

        // --- Business Overview Section ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Business Overview",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              _buildOverviewRow(
                label: "Left Team Business",
                amount: "\$${_formatAmount(data.leftTeamBusiness)}",
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 8),
              _buildOverviewRow(
                label: "Right Team Business",
                amount: "\$${_formatAmount(data.rightTeamBusiness)}",
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 8),
              _buildOverviewRow(
                label: "Left Team Count",
                amount: "${data.leftTeamCount}",
                isTotal: false,
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 8),
              _buildOverviewRow(
                label: "Right Team Count",
                amount: "${data.rightTeamCount}",
                isTotal: false,
              ),
              // const SizedBox(height: 16),

              // // Show Active Package if present
              // if (data.activePackage != null)
              //   Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Divider(color: Colors.grey[200], height: 1),
              //       const SizedBox(height: 12),
              //       Text('Active Package', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              //       const SizedBox(height: 8),
              //       Text('Price: \$${_formatAmount(data.activePackage!.price)} | Status: ${data.activePackage!.status}', style: GoogleFonts.poppins(color: Colors.grey[700])),

              //     ],
              //   ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        // --- Quick Actions Row ---
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.referEarn);
                },
                child: _buildActionButton(
                  icon: Icons.person_add_alt_outlined,
                  label: "Invite",
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.myTeam);
                },
                child: _buildActionButton(
                  icon: Icons.group_outlined,
                  label: "My Team",
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.wallet);
                },
                child: _buildActionButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Wallet",
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.directReferralIncome);
                },
                child: _buildActionButton(
                  icon: Icons.insert_drive_file_outlined,
                  label: "Reports",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAmount(String val) {
    try {
      final d = double.tryParse(val) ?? 0.0;
      if (d.isNaN || d.isInfinite) return val;
      if (d % 1 == 0) return d.toInt().toString();
      var s = d.toStringAsFixed(8);
      // Remove trailing zeros and any trailing decimal point
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
      return s;
    } catch (e) {
      return val;
    }
  }

  // Helper widget for Income Cards
  Widget _buildIncomeCard({
    required String label,
    required String amount,
    Color? amountColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: amountColor ?? AppColors.brand,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for Business Overview rows
  Widget _buildOverviewRow({
    required String label,
    required String amount,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  // Helper widget for Quick Action buttons (icon + label inside box)
  Widget _buildActionButton({required IconData icon, required String label}) {
    return Container(
      height: 96,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.brand, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
