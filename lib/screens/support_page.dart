import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
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
          'Support',
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
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Image.asset('assets/Group 1 (1).png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 30),
            const Text(
              'How can we assist you?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 25),
            _buildSupportOption(
              icon: Icons.email,
              title: 'Email Support',
              onTap: () {
                // Uncomment below when ready
                /*
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@propple.com',
                  queryParameters: {'subject': 'Support Request'},
                );
                launchUrl(emailUri);
                */

                // For now, show message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email: support@propple.com')),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildSupportOption(
              icon: Icons.phone,
              title: 'Call Us',
              onTap: () {
                // Uncomment below when ready
                /*
                final Uri phoneUri = Uri(scheme: 'tel', path: '+1234567890');
                launchUrl(phoneUri);
                */

                // For now, show message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call: +1-234-567-890')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brand, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
