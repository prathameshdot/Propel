import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; 
import 'package:share_plus/share_plus.dart'; 
import '../utils/colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/referrals_list_response.dart';

class ReferAndEarnPage extends StatefulWidget {
  const ReferAndEarnPage({super.key});

  @override
  State<ReferAndEarnPage> createState() => _ReferAndEarnPageState();
}

class _ReferAndEarnPageState extends State<ReferAndEarnPage> {
  String referralLink = "yourcompany.com/referral-code"; // Will be updated dynamically
  String? referralCode; // Store the actual code

  // Referrals data
  List<Referral> _referrals = [];
  bool _loadingReferrals = true;

  // Add referral form
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _referralCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReferralCode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  void _fetchReferralCode() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final response = await ApiService.get('/api/v1/referral/code?user_id=$userId');
    if (!mounted) return;
    if (response != null && response['status'] == true) {
      final code = response['data']['referral_code'];
      setState(() {
        referralCode = code;
        referralLink = 'https://propel.hoomaservice.com/?refcode=$code';
      });
      // Now fetch referrals using the code
      _fetchReferrals();
    } else {
      String errorMessage = 'Failed to load referral code';
      if (response != null && response['message'] != null) {
        errorMessage = response['message'];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _fetchReferrals() async {
    final userId = await AuthService.getUserId();
    if (userId == null || referralCode == null) {
      // Wait for referral code to be fetched
      return;
    }

    final response = await ApiService.get('/api/v1/referral/list?user_id=$userId&referral_code=$referralCode');
    if (!mounted) return;
    if (response != null && response['status'] == true) {
      setState(() {
        _referrals = (response['data']['referrals'] as List)
            .map((item) => Referral.fromJson(item))
            .toList();
        _loadingReferrals = false;
      });
    } else {
      setState(() {
        _loadingReferrals = false;
      });
      String errorMessage = 'Failed to load referrals. Please try again.';
      if (response != null && response['message'] != null) {
        errorMessage = response['message'];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // void _submitReferral() async {
  //   if (_firstNameController.text.isEmpty ||
  //       _lastNameController.text.isEmpty ||
  //       _referralCodeController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all fields')),
  //     );
  //     return;
  //   }

  //   final response = await ApiService.post('/api/v1/referral/store', {
  //     'referral_code': _referralCodeController.text,
  //     'first_name': _firstNameController.text,
  //     'last_name': _lastNameController.text,
  //   });

  //   if (!mounted) return;
  //   if (response != null && response['status'] == true) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Referral added successfully')),
  //     );
  //     _firstNameController.clear();
  //     _lastNameController.clear();
  //     _referralCodeController.clear();
  //     _fetchReferrals(); // Refresh the list
  //   } else {
  //     String errorMessage = 'Failed to add referral. Please try again.';
  //     if (response != null && response['message'] != null) {
  //       errorMessage = response['message'];
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage)),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Refer & Earn",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Illustration - use existing asset if specific image not available
            Image.asset(
              'assets/Group 1 (1).png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // Main Title
            Text(
              "Invite & Earn Rewards",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              "Refer your friends and earn rewards when they join and activate a package.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Referral Code Box
            if (referralCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code, color: AppColors.brand, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Referral Code',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            referralCode!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: referralCode ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Referral code copied!')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.content_copy, color: AppColors.brand, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Referral Link Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: AppColors.brand, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Referral Link',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          referralLink,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.content_copy, color: AppColors.brand, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Share.share(referralLink);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.share, color: AppColors.brand, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Action Buttons Row (icon above text, fixed box sizes, larger icons)
            Column(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => Share.share(referralLink),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 36),
                          const SizedBox(height: 10),
                          Text("Share Link", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => _copyToClipboard(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.link, color: Colors.white, size: 36),
                          const SizedBox(height: 10),
                          Text(
                            "Copy Referal Link",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "Your Referrals",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            if (_loadingReferrals)
              const Center(child: CircularProgressIndicator())
            else if (_referrals.isEmpty)
              Text(
                "No referrals yet.",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _referrals.length,
                itemBuilder: (context, index) {
                  final referral = _referrals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.brand,
                          child: Text(
                            '${referral.firstName[0]}${referral.lastName[0]}',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${referral.firstName} ${referral.lastName}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Position: ${referral.positionName}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Joined: ${referral.createdAt.split('T')[0]}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Link copied to clipboard!"),
        backgroundColor: Color(0xFF3979D3),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
