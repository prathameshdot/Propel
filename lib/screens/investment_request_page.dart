import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_repository.dart';
import '../utils/colors.dart';
import '../models/user_deposit_models.dart';
import '../routes/app_router.dart';

class InvestmentRequestPage extends StatefulWidget {
  const InvestmentRequestPage({super.key});

  @override
  State<InvestmentRequestPage> createState() => _InvestmentRequestPageState();
}

class _InvestmentRequestPageState extends State<InvestmentRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionHashController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _transactionHashController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitInvestmentRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('User not found. Please login again.')),
        );
        return;
      }

      final userId = int.parse(userIdStr);
      final request = CreateDepositRequest(
        userId: userId,
        amount: double.parse(_amountController.text.trim()),
        transactionHash: _transactionHashController.text.trim(),
        remarks: _remarksController.text.trim(),
      );

      final response = await ApiRepository.createDeposit(request);

      if (response != null && response.status) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Investment request submitted successfully!')),
        );
        // Clear form
        _amountController.clear();
        _transactionHashController.clear();
        _remarksController.clear();
        // Navigate to deposit history to show submitted request
        navigator.pushNamed(AppRouter.topupDetails);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(response?.message ?? 'Failed to submit investment request')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
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
        title: Text(
          'Investment Request',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Submit Investment Request',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Fill in the details to submit your investment request',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 30),

            // Amount
            Text(
              'Investment Amount (USD)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount in USD',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF999999),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF007BFF)),
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: Colors.grey,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter investment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount greater than 0';
                }
                if (amount < 10) {
                  return 'Minimum investment amount is \$10';
                }
                if (amount > 10000) {
                  return 'Maximum investment amount is \$10,000';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Transaction Hash
            Text(
              'Transaction Hash',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _transactionHashController,
              decoration: InputDecoration(
                hintText: 'Enter transaction hash from USDT transfer',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF999999),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF007BFF)),
                ),
                prefixIcon: Icon(
                  Icons.receipt_long,
                  color: Colors.grey,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter transaction hash';
                }
                if (value.length < 20) {
                  return 'Transaction hash seems too short (minimum 20 characters)';
                }
                if (value.length > 100) {
                  return 'Transaction hash seems too long (maximum 100 characters)';
                }
                // Check if it contains only valid characters for a hash
                final hashRegex = RegExp(r'^[a-fA-F0-9]+$');
                if (!hashRegex.hasMatch(value.replaceAll('0x', ''))) {
                  return 'Transaction hash should contain only hexadecimal characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Remarks
            Text(
              'Remarks (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any additional notes...',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF999999),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF007BFF)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Important Information',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Please ensure the transaction hash is correct and matches your USDT transfer.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Investment amount must be between \$10 and \$10,000.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Requests will be reviewed by our team within 24-48 hours.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Make sure to send USDT to the correct wallet address provided.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitInvestmentRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit Investment Request',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}