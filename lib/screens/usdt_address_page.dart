import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';

class UsdtAddressPage extends StatefulWidget {
  const UsdtAddressPage({super.key});

  @override
  State<UsdtAddressPage> createState() => _UsdtAddressPageState();
}

class _UsdtAddressPageState extends State<UsdtAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _usdtAddressController = TextEditingController();
  final _confirmAddressController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usdtAddressController.dispose();
    _confirmAddressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUsdt();
  }

  Future<void> _loadCurrentUsdt() async {
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) return;
      final userId = int.parse(userIdStr);
      final profile = await ApiRepository.getUserProfile(userId);
      if (profile != null && profile.status && profile.data != null) {
        final addr = profile.data?.usdt?.address;
        if (addr != null && addr.isNotEmpty) {
          if (mounted) {
            setState(() {
              _usdtAddressController.text = addr;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveUsdtAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) throw Exception('User not logged in');

      final userId = int.parse(userIdStr);
      final address = _usdtAddressController.text.trim();

      final resp = await ApiRepository.editUserProfile(
        userId: userId,
        usdtAddress: address,
      );

      if (!mounted) return;

      if (resp != null && resp.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('USDT address saved successfully')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp?.message ?? 'Failed to save address')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
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
          'USDT Address',
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
                'Manage your USDT wallet address',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF666666),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please ensure your USDT address is correct. Withdrawals will be sent to this address.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // USDT Address
              Text(
                'USDT Address (TRC20)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usdtAddressController,
                decoration: InputDecoration(
                  hintText: 'Enter your USDT wallet address',
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
                    Icons.account_balance_wallet,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your USDT address';
                  }
                  // Basic USDT address validation (should start with T and be 34 characters)
                  if (!value.startsWith('T') || value.length != 34) {
                    return 'Please enter a valid USDT address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Confirm USDT Address
              Text(
                'Confirm USDT Address',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmAddressController,
                decoration: InputDecoration(
                  hintText: 'Confirm your USDT wallet address',
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
                    Icons.account_balance_wallet,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your USDT address';
                  }
                  if (value != _usdtAddressController.text) {
                    return 'Addresses do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Current Address Display (if exists)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current USDT Address',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                          Text(
                            _usdtAddressController.text.isEmpty
                                ? 'No USDT address saved'
                                : _usdtAddressController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUsdtAddress,
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
                          'Save USDT Address',
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
      ),
    );
  }
}