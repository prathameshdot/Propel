import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_repository.dart';
import '../models/register_request.dart';
import '../models/create_referral_models.dart';
import 'login_page.dart';
// import 'account_inactive_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Controllers for text fields
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralController = TextEditingController();
  final FocusNode _referralFocusNode = FocusNode();

  // State for password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Referral position / selection state
  bool _showPositionButtons = false;
  String? _selectedPosition; // 'left' or 'right'
  bool _isCheckingPosition = false;
  List<Map<String, dynamic>> _availableUsers = [];
  int? _selectedSubTeamId;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    _referralFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _referralFocusNode.addListener(() {
      setState(() {
        _showPositionButtons = _referralFocusNode.hasFocus;
      });
    });
  }

  Future<void> _selectJoinPosition(String position) async {
    if (_referralController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a referral code first')),
      );
      return;
    }

    setState(() {
      _isCheckingPosition = true;
      _selectedPosition = position;
      _availableUsers = [];
      _selectedSubTeamId = null;
    });

    try {
      final response = await ApiRepository.checkPosition(
        refCode: _referralController.text.trim(),
        joinPosition: position,
      );
      if (response != null && response.status) {
        // data may contain users list or be null
        final dynamic data = response.data;
        if (data != null && data is Map && data['users'] is List) {
          setState(() {
            _availableUsers = (data['users'] as List)
                .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map),
                )
                .toList();
          });
        } else {
          // No users returned; position available directly under the referral
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(response.message)));
          }
          setState(() {
            _availableUsers = [];
            _selectedSubTeamId = 0; // can register directly under referrer
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?.message ?? 'Unable to check position'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error checking position')));
      }
    } finally {
      setState(() {
        _isCheckingPosition = false;
      });
    }
  }

  Future<void> _register() async {
    if (_fullNameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // If referral code used, ensure position chosen when required and a card selected when users exist
    if (_referralController.text.trim().isNotEmpty) {
      if (_selectedPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select position (Left / Right)'),
          ),
        );
        return;
      }
      if (_availableUsers.isNotEmpty && _selectedSubTeamId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a user from available positions'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = RegisterRequest(
        fullName: _fullNameController.text,
        mobile: _mobileController.text,
        email: _emailController.text,
        password: _passwordController.text,
        referralCode: _referralController.text.isNotEmpty
            ? _referralController.text
            : '',
        position: _selectedPosition,
        subTeamId: _selectedSubTeamId,
      );
      final response = await ApiRepository.register(request);

      if (!mounted) return;

      if (response != null && response.status) {
        // Successful registration
        if (!mounted) return;

        // If user provided a referral code, create referral entry
        if (_referralController.text.isNotEmpty &&
            response.data?.user != null) {
          try {
            // The API will auto-assign left/right position based on existing referrals
            final createReferralRequest = CreateReferralRequest(
              referralCode: _referralController.text,
              firstName: _fullNameController.text.split(' ').first,
              lastName: _fullNameController.text.split(' ').length > 1
                  ? _fullNameController.text.split(' ').sublist(1).join(' ')
                  : '',
            );
            await ApiRepository.createReferral(createReferralRequest);
          } catch (e) {
            // Silently handle referral creation error
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      } else {
        // Failed registration
        String errorMessage = 'Registration failed. Please try again.';
        if (response != null) {
          // Handle message as array or string
          if (response.message is List) {
            errorMessage = (response.message as List).join(', ');
          } else {
            errorMessage = response.message;
          }
        }
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3979D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Create New Account",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Page Header
              Text(
                "Create New Account",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 25),

              // Full Name
              _buildCustomTextField(
                hintText: "Full Name",
                prefixIcon: Icons.person,
                controller: _fullNameController,
              ),
              const SizedBox(height: 15),

              // Mobile
              _buildCustomTextField(
                hintText: "Mobile",
                prefixIcon: Icons.phone,
                controller: _mobileController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              // Email
              _buildCustomTextField(
                hintText: "Email",
                prefixIcon: Icons.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Password
              _buildCustomTextField(
                hintText: "Password",
                prefixIcon: Icons.lock,
                controller: _passwordController,
                isPassword: true,
                isObscured: !_isPasswordVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Confirm Password
              _buildCustomTextField(
                hintText: "Confirm Password",
                prefixIcon: Icons.lock,
                controller: _confirmPasswordController,
                isPassword: true,
                isObscured: !_isConfirmPasswordVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Referral Code
              _buildCustomTextField(
                hintText: "# Referral Code (Optional)",
                prefixIcon: Icons.tag, // Using tag/hash icon
                controller: _referralController,
                focusNode: _referralFocusNode,
                onTap: () {
                  setState(() {
                    _showPositionButtons = true;
                  });
                },
              ),

              // Show position buttons when referral field focused/tapped
              if (_showPositionButtons) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectJoinPosition('left'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPosition == 'left'
                              ? const Color(0xFF3979D3)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Left',
                          style: GoogleFonts.poppins(
                            color: _selectedPosition == 'left'
                                ? Colors.white
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectJoinPosition('right'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPosition == 'right'
                              ? const Color(0xFF3979D3)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Right',
                          style: GoogleFonts.poppins(
                            color: _selectedPosition == 'right'
                                ? Colors.white
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_isCheckingPosition)
                  const Center(child: CircularProgressIndicator())
                else if (_availableUsers.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Users',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _availableUsers.length,
                        itemBuilder: (context, index) {
                          final user = _availableUsers[index];
                          final userId = (user['id'] is int)
                              ? user['id'] as int
                              : int.tryParse(user['id'].toString()) ?? 0;
                          final isSelected = _selectedSubTeamId == userId;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSubTeamId = userId;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFe8f0ff)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF3979D3)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: user['image'] != null
                                        ? NetworkImage(user['image'])
                                              as ImageProvider
                                        : const AssetImage(
                                            'assets/profile.avif',
                                          ),
                                    backgroundColor: const Color(0xFFE0E0E0),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['name'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Code: ${user['referral_code'] ?? '-'}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (user['available_positions'] is List)
                                    Text(
                                      (user['available_positions'] as List)
                                          .join(', '),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                else if (_selectedPosition != null &&
                    !_isCheckingPosition &&
                    _selectedSubTeamId == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Position available. You can register directly under this referral.',
                      style: GoogleFonts.poppins(color: Colors.green[700]),
                    ),
                  ),

                const SizedBox(height: 18),
              ] else
                const SizedBox(height: 30),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3979D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Register (Free)",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Footer Text
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                color: Colors.grey.shade50, // Slight background for footer area
                child: Text(
                  "Registration is free. Activation is \nrequired to unlock income.",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create the identical text fields
  Widget _buildCustomTextField({
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        focusNode: focusNode,
        onTap: onTap,
        controller: controller,
        obscureText: isObscured,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),

          // The Prefix Icon
          prefixIcon: Icon(prefixIcon, color: Colors.grey[500], size: 22),

          // The Eye Icon (Only for passwords)
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.blue.withAlpha(128), // 0.5 * 255 ≈ 128
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,

          // Border Styling
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: const Color(0xFF3979D3), width: 1.5),
          ),
        ),
      ),
    );
  }
}
