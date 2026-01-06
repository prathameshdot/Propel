import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:propples/screens/package_activation_page.dart';
import '../services/api_repository.dart';
import '../models/packages_list_response.dart';

class ActivationPackagesPage extends StatefulWidget {
  const ActivationPackagesPage({super.key});

  @override
  State<ActivationPackagesPage> createState() => _ActivationPackagesPageState();
}

class _ActivationPackagesPageState extends State<ActivationPackagesPage> {
  final Color brandColor = const Color(0xFF3979D3);
  List<Package> _packages = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiRepository.getPackagesList();
      if (!mounted) return;
      if (response != null && response.status && response.data != null) {
        setState(() {
          _packages = response.data!.packages;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _errorMessage =
              response?.message ?? 'Failed to load packages. Please try again.';
        });
      }
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
      backgroundColor: const Color(0xFFF0F4F8), // Matches the light grey bg
      appBar: AppBar(
        backgroundColor: brandColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Activation Packages",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
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
                    onPressed: _fetchPackages,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: _packages
                    .map((package) => _buildPackageCard(package))
                    .toList(),
              ),
            ),
    );
  }

  // Reusable Widget for the Package Card
  Widget _buildPackageCard(Package package) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Text
            Text(
              "\$${_formatPrice(package.price)}",
              style: GoogleFonts.poppins(
                color: brandColor, // Using the brand blue
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Divider Line
            Divider(color: Colors.grey[300], thickness: 1),
            const SizedBox(height: 15),

            // Feature List
            _buildFeatureRow("Direct Referral Income"),
            const SizedBox(height: 10),
            _buildFeatureRow("Team Business Counting"),
            const SizedBox(height: 10),
            _buildFeatureRow("Matching Income Eligibility"),

            const SizedBox(height: 20),

            // Activate Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PackageActivationPage(package: package),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  "Activate Now",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the Checkmark + Text rows
  Widget _buildFeatureRow(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check,
          color: Color(0xFF81C784), // Light green color matching the image
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(String val) {
    final d = double.tryParse(val) ?? 0.0;
    if (d % 1 == 0) return d.toInt().toString();
    var s = d.toString();
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}
