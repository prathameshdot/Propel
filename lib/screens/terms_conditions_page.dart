import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Terms & Conditions',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 160,
                child: Image.asset(
                  'assets/Group 1 (1).png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Center(
              child: Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'By accessing and using this application, you agree to the following Terms and Conditions. Please read these terms carefully before using our services.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            _buildSection(
              title: '1. Introduction',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula. Curss artit ris massa.',
            ),
            _buildSection(
              title: '2. User Responsibilities',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula. Curss artit ris massa.',
            ),
            _buildSection(
              title: '3. Payment Terms',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula. Curss artit ris massa.',
            ),
            _buildSection(
              title: '4. Privacy Policy',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula. Curss artit ris massa.',
            ),
            _buildSection(title: '5. Limitation of Liability', content: ''),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Uncomment below when API is ready
                  /*
                  final response = await ApiService.post('/accept-terms', {});
                  if (response != null && response['success'] == true) {
                    Navigator.of(context).pop(); // Go back or navigate to next screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to accept terms')),
                    );
                  }
                  */

                  // For now, just go back
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'I Agree',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
