import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import 'activation_packages_page.dart';

class AccountInactivePage extends StatefulWidget {
  const AccountInactivePage({super.key});

  @override
  State<AccountInactivePage> createState() => _AccountInactivePageState();
}

class _AccountInactivePageState extends State<AccountInactivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar matching the blue header
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Account Inactive",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle:
            true, // Title looks centered in this specific image screenshot
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The Red Inactive Status Alert Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFEECEB,
                  ), // Very light pink/red background
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(
                      0xFFF3B4B0,
                    ), // Slightly darker pink border
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .add_circle, // Using add_circle to match the plus icon
                      color: Colors.red[400],
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Account Status: Inactive",
                      style: GoogleFonts.poppins(
                        color: Colors.red[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Main Title Text
              Text(
                "Your account is inactive.",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 10),

              // Description Text (Corrected the garbled text from the image)
              Text(
                "Activate a package to unlock Income eligibility and team business counting.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),

              // Primary Blue Button: "View Packages"
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ActivationPackagesPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "View Packages",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Secondary Outline Button: "Share Referral Link"
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey[50],
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Share Referral Link",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
