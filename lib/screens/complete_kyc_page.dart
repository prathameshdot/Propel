import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/colors.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../routes/app_router.dart';

class CompleteKYCPage extends StatefulWidget {
  const CompleteKYCPage({super.key});

  @override
  State<CompleteKYCPage> createState() => _CompleteKYCPageState();
}

class _CompleteKYCPageState extends State<CompleteKYCPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _aadharNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankIfscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _accountHolderNameController = TextEditingController();

  File? _panImage;
  File? _aadharFrontImage;
  File? _aadharBackImage;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _panNumberController.dispose();
    _aadharNumberController.dispose();
    _addressController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (type == 'pan') {
            _panImage = File(image.path);
          } else if (type == 'aadhar_front') {
            _aadharFrontImage = File(image.path);
          } else if (type == 'aadhar_back') {
            _aadharBackImage = File(image.path);
          }
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

  Future<void> _submitKYC() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_panImage == null ||
        _aadharFrontImage == null ||
        _aadharBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required images')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Prepare form fields with all required data
      final fields = <String, String>{
        'user_id': userId,
        'bank_account_number': _bankAccountController.text,
        'bank_ifsc': _bankIfscController.text,
        'bank_name': _bankNameController.text,
        'bank_branch': _bankBranchController.text,
        'account_holder_name': _accountHolderNameController.text,
      };

      // Prepare files
      final files = <http.MultipartFile>[];

      // Add Aadhar front image (adhar_front)
      files.add(
        await http.MultipartFile.fromPath(
          'adhar_front',
          _aadharFrontImage!.path,
        ),
      );

      // Add Aadhar back image (adhar_back)
      files.add(
        await http.MultipartFile.fromPath('adhar_back', _aadharBackImage!.path),
      );

      // Add PAN image (pancard)
      files.add(await http.MultipartFile.fromPath('pancard', _panImage!.path));

      final response = await ApiRepository.submitKyc(fields, files);

      if (!mounted) return;

      if (response != null && response.status) {
        // Refresh KYC status from API to ensure accuracy
        try {
          final kycRefresh = await ApiRepository.getKyc(int.parse(userId));
          if (kycRefresh != null &&
              kycRefresh.status &&
              kycRefresh.data != null) {
            // status can be true/false (boolean) or "pending"/"verified" (string)
            final statusStr = kycRefresh.data!.status.toString().toLowerCase();
            final isVerified =
                statusStr == 'true' ||
                statusStr == 'verified' ||
                statusStr == 'approved';
            await AuthService.setKycStatus(
              isVerified ? 1 : 0,
              isVerified ? 'Verified' : 'Pending',
            );
          }
        } catch (e) {
          // If refresh fails, cache as pending
          await AuthService.setKycStatus(0, 'Pending');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));

        // Check if user already has referral code (package activated)
        final referralResponse = await ApiRepository.getReferralCode(
          int.parse(userId),
        );

        if (!mounted) return;

        if (referralResponse != null &&
            referralResponse.status &&
            referralResponse.data?.referralCode.isNotEmpty == true) {
          // User already has referral code, go directly to dashboard
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        } else {
          // No referral code, go to account inactive page
          Navigator.of(context).pushReplacementNamed(AppRouter.accountInactive);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?.message ?? 'KYC submission failed. Please try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Complete KYC',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // PAN Number
              TextFormField(
                controller: _panNumberController,
                decoration: InputDecoration(
                  labelText: 'PAN Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your PAN number';
                  }
                  if (value.length != 10) {
                    return 'PAN number must be 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Aadhar Number
              TextFormField(
                controller: _aadharNumberController,
                decoration: InputDecoration(
                  labelText: 'Aadhar Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Aadhar number';
                  }
                  if (value.length != 12) {
                    return 'Aadhar number must be 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Bank Account Details Section
              const Text(
                'Bank Account Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),

              // Bank Account Number
              TextFormField(
                controller: _bankAccountController,
                decoration: InputDecoration(
                  labelText: 'Bank Account Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.account_balance),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Bank IFSC Code
              TextFormField(
                controller: _bankIfscController,
                decoration: InputDecoration(
                  labelText: 'Bank IFSC Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.code),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank IFSC code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Bank Name
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Bank Branch
              TextFormField(
                controller: _bankBranchController,
                decoration: InputDecoration(
                  labelText: 'Bank Branch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank branch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Account Holder Name
              TextFormField(
                controller: _accountHolderNameController,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              const Text(
                'Document Upload',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),

              // PAN Card Image
              _buildImageUploadCard(
                title: 'PAN Card',
                image: _panImage,
                onTap: () => _pickImage('pan'),
              ),
              const SizedBox(height: 15),

              // Aadhar Front Image
              _buildImageUploadCard(
                title: 'Aadhar Card (Front)',
                image: _aadharFrontImage,
                onTap: () => _pickImage('aadhar_front'),
              ),
              const SizedBox(height: 15),

              // Aadhar Back Image
              _buildImageUploadCard(
                title: 'Aadhar Card (Back)',
                image: _aadharBackImage,
                onTap: () => _pickImage('aadhar_back'),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitKYC,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit KYC',
                          style: TextStyle(
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

  Widget _buildImageUploadCard({
    required String title,
    required File? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(image, fit: BoxFit.cover),
                    )
                  : Icon(Icons.image, color: Colors.grey[400], size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image != null ? 'Tap to change' : 'Tap to upload',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.upload_file, color: AppColors.brand),
          ],
        ),
      ),
    );
  }
}
