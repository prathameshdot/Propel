import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/packages_list_response.dart';
import 'package_activation_page.dart';
import 'topup_details_page.dart';
import 'investment_request_page.dart';

class PackagePage extends StatefulWidget {
  final Package package;

  const PackagePage({super.key, required this.package});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Text(
          'Package',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Top Up'),
            Tab(text: 'Top Up Details'),
            Tab(text: 'Investment Request'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Top Up Tab - Existing package activation flow
          PackageActivationPage(package: widget.package),

          // Top Up Details Tab - User deposit history
          const TopupDetailsPage(),

          // Investment Request Tab - Create new deposit request
          const InvestmentRequestPage(),
        ],
      ),
    );
  }
}