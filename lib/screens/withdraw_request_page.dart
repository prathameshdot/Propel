import 'package:flutter/material.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/withdraw_models.dart';

class WithdrawRequestPage extends StatefulWidget {
  const WithdrawRequestPage({super.key});

  @override
  State<WithdrawRequestPage> createState() => _WithdrawRequestPageState();
}

class _WithdrawRequestPageState extends State<WithdrawRequestPage> {
  final Color brandColor = const Color(0xFF3979D3);
  final TextEditingController _amountController = TextEditingController(
    text: '\$1,000',
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usdtController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _usdtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Withdraw Request',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  '\$1,000',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _amountController,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  prefixIcon: Icon(Icons.payments, color: brandColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // USDT / Wallet address
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _usdtController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'USDT / Withdraw Address',
                  prefixIcon: Icon(Icons.account_balance_wallet, color: brandColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            GestureDetector(
              onTap: () {
                // TODO: open bank account picker / add bank flow
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: brandColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add Bank Account',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '*****',
                  hintStyle: const TextStyle(fontSize: 18, letterSpacing: 2),
                  prefixIcon: Icon(Icons.lock, color: brandColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final amountText = _amountController.text
                      .replaceAll('\$', '')
                      .replaceAll(',', '')
                      .trim();
                  final address = _usdtController.text.trim();
                  final password = _passwordController.text.trim();

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  if (amountText.isEmpty || address.isEmpty || password.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final userIdStr = await AuthService.getUserId();
                  if (userIdStr == null) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }

                  final body = {
                    'user_id': int.tryParse(userIdStr) ?? 0,
                    'wallet_type': 'income_wallet',
                    'amount': double.tryParse(amountText) ?? 0,
                    'usdt_address': address,
                    'status': 'pending',
                  };

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Submitting withdraw request...')),
                  );

                  final CreateWithdrawResponse? response = await ApiRepository.createWithdraw(body);
                  if (!mounted) return;
                  if (response != null && response.status) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(response.message)),
                    );
                    navigator.pop();
                  } else {
                    final msg = response?.message ?? 'Failed to submit request';
                    messenger.showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Request',
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
    );
  }
}
