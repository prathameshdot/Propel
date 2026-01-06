import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_repository.dart';
import '../utils/colors.dart';
import '../routes/app_router.dart';
import '../models/dashboard_response.dart';

class IncomeReportItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;

  IncomeReportItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });
}

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isLoading = true;
  DashboardResponse? _dashboardData;
  final Color brandColor = const Color(0xFF3979D3);

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) return;

      final userId = int.parse(userIdStr);
      final response = await ApiRepository.getDashboard(userId);

      if (response != null && response.status && response.data != null) {
        setState(() {
          _dashboardData = response;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<IncomeReportItem> get _incomeList {
    if (_dashboardData == null || _dashboardData!.data == null) {
      return [];
    }

    final data = _dashboardData!.data!;
    return [
      IncomeReportItem(
        icon: Icons.person_add_alt_1,
        iconColor: const Color(0xFF4CAF50), // Green
        title: "Direct Income",
        subtitle: "Total: \$${data.directIncome}",
        amount: "\$${data.directIncome}",
      ),
      IncomeReportItem(
        icon: Icons.group_work,
        iconColor: const Color(0xFF2196F3), // Blue
        title: "Matching Income",
        subtitle: "Total: \$${data.matchingIncome}",
        amount: "\$${data.matchingIncome}",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Income Report",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Wallet Balance Card at the top
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wallet Balance',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          Text(
                            '\$${_dashboardData?.data?.walletBalance ?? "0"}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: brandColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () {
                            Navigator.of(context).pushNamed(AppRouter.withdraw);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Withdraw",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.transactionHistory);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: brandColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Transactions",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: brandColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Income List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _incomeList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final item = _incomeList[index];
                return _buildIncomeCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widget for Income Report Card
  Widget _buildIncomeCard(IncomeReportItem item) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon in a colored circle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.iconColor.withValues(
                alpha: 0.1,
              ), // Light background for the icon
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 24),
          ),
          const SizedBox(width: 15),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Amount Display
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: brandColor, // Amount is blue
            ),
          ),
        ],
      ),
    );
  }
}
