import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/colors.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/packages_list_response.dart';
import '../models/superadmin_wallet_response.dart';
import '../models/payment_models.dart';
import 'dashboard_page.dart';

class PackageActivationPage extends StatefulWidget {
  final Package package;

  const PackageActivationPage({super.key, required this.package});

  @override
  State<PackageActivationPage> createState() => _PackageActivationPageState();
}

class _PackageActivationPageState extends State<PackageActivationPage> {
  final int _selectedPaymentMethod = 1; // 1 = UPI, 2 = Bank Transfer
  bool _isSubmitting = false;
  File? _paymentProofImage;
  final ImagePicker _picker = ImagePicker();

  // Superadmin Wallet data
  SuperadminWalletResponse? _walletData;
  bool _isLoadingWallet = true;
  String? _walletErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final response = await ApiRepository.getSuperadminWallet();
      if (response != null && response.status) {
        setState(() {
          _walletData = response;
          _isLoadingWallet = false;
        });
      } else {
        setState(() {
          _isLoadingWallet = false;
          _walletErrorMessage = response?.message ?? 'Payment details are currently unavailable.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingWallet = false;
        _walletErrorMessage = 'An error occurred while loading payment details.';
      });
    }
  }

  Future<void> _pickPaymentProof() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _paymentProofImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Package Activation",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // --- Section: Selected Package ---
            Text(
              "Selected Package",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\$${_formatPrice(widget.package.price)}",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Direct Percentage: ${widget.package.directPercentage}%",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    "Matching Eligible: ${(widget.package.matchingEligible ?? false) ? 'Yes' : 'No'}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Section: Payment Details ---
            Text(
              "Payment Details",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            _isLoadingWallet
                ? const Center(child: CircularProgressIndicator())
                : _walletData != null && _walletData!.status && _walletData!.data != null
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Send USDT to the following address:",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            // QR Code
                            if (_walletData!.data!.qrImage.isNotEmpty && _walletData!.data!.qrImage != "")
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Image.network(
                                  _walletData!.data!.qrImage,
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.qr_code,
                                      size: 150,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),
                            // Wallet Address
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "USDT Address (TRC20)",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _walletData!.data!.address,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF333333),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Amount to send: \$${_formatPrice(widget.package.price)}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brand,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _walletErrorMessage ?? 'Payment details are currently unavailable. Please try again later.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

            const SizedBox(height: 25),

            // --- Payment Proof Upload ---
            Text(
              "Upload Payment Proof",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickPaymentProof,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _paymentProofImage != null
                        ? AppColors.brand
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    if (_paymentProofImage != null)
                      Column(
                        children: [
                          Image.file(
                            _paymentProofImage!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Proof Selected',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload payment proof',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE8F1FC,
                ), // Light blue background similar to image
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align icon to top of text
                children: [
                  Icon(Icons.info, color: AppColors.brand, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Payment will be approved by \nadmin after verification.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                        // Validate payment proof
                        if (_paymentProofImage == null) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Please upload payment proof'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isSubmitting = true;
                        });

                        try {
                          final userIdString = await AuthService.getUserId();
                          if (!mounted) return;
                          
                          if (userIdString == null) {
                            if (mounted) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('User not logged in'),
                                ),
                              );
                            }
                            setState(() {
                              _isSubmitting = false;
                            });
                            return;
                          }

                          // Upload payment proof image first
                          final imageFile = await http.MultipartFile.fromPath(
                            'image',
                            _paymentProofImage!.path,
                          );

                          final uploadResponse =
                              await ApiRepository.uploadMasterImage(imageFile);

                          if (!mounted) return;

                          if (uploadResponse == null ||
                              !uploadResponse.status) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    uploadResponse?.message ??
                                        'Failed to upload payment proof',
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              _isSubmitting = false;
                            });
                            return;
                          }

                          // Proceed with payment creation
                          final userId = int.tryParse(userIdString) ?? 0;
                          final request = CreatePaymentRequest(
                            userId: userId,
                            packageId: widget.package.id,
                            amount: double.parse(widget.package.price),
                            paymentMethod: _selectedPaymentMethod == 1
                                ? 'UPI'
                                : 'Bank Transfer',
                            referenceId:
                                'REF${DateTime.now().millisecondsSinceEpoch}',
                            status:
                                'completed', // Always completed as per user requirement
                          );

                          final response = await ApiRepository.createPayment(
                            request,
                          );

                          if (!mounted) return;

                          if (response != null && response.status) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(response.message)),
                              );
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const DashboardPage(),
                                ),
                              );
                            }
                          } else {
                            String errorMessage =
                                'Payment failed. Please try again.';
                            if (response != null) {
                              if (response.message is List) {
                                errorMessage = (response.message as List).join(
                                  ', ',
                                );
                              } else {
                                errorMessage = response.message;
                              }
                            }
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'An error occurred. Please try again.',
                                ),
                              ),
                            );
                          }
                        } finally {
                            if (mounted) {
                              setState(() {
                                _isSubmitting = false;
                              });
                            }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit Payment",
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

  String _formatPrice(String val) {
    final d = double.tryParse(val) ?? 0.0;
    if (d % 1 == 0) return d.toInt().toString();
    var s = d.toString();
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}
