import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_repository.dart';
import '../utils/colors.dart';
import '../models/user_deposit_models.dart';

class TopupDetailsPage extends StatefulWidget {
  const TopupDetailsPage({super.key});

  @override
  State<TopupDetailsPage> createState() => _TopupDetailsPageState();
}

class _TopupDetailsPageState extends State<TopupDetailsPage> {
  bool _isLoading = true;
  List<DepositItem> _deposits = [];

  @override
  void initState() {
    super.initState();
    _loadDepositHistory();
  }

  Future<void> _loadDepositHistory() async {
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) return;

      final userId = int.parse(userIdStr);
      final response = await ApiRepository.getDeposits(userId);

      if (response != null && response.status) {
        setState(() {
          _deposits = response.data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response?.message ?? 'Failed to load deposit history')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while loading deposit history')),
        );
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
          'Deposit History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDepositHistory,
        child: _deposits.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLoading ? 'Loading deposits...' : 'No deposit history found',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: _deposits.length,
                itemBuilder: (context, index) {
                  final deposit = _deposits[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show exact API keys and values
                        _buildKeyValue('id', deposit.id.toString()),
                        _buildKeyValue('amount', deposit.amount),
                        _buildKeyValue('transaction_hash', deposit.transactionHash),
                        _buildKeyValue('remarks', deposit.remarks),
                        _buildKeyValue('status', deposit.status),
                        _buildKeyValue('approve_date', deposit.approveDate ?? ''),
                        _buildKeyValue('admin_notes', deposit.adminNotes ?? ''),
                        _buildKeyValue('created_at', deposit.createdAt),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Color _getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'pending':
  //       return Colors.orange;
  //     case 'approved':
  //       return Colors.green;
  //     case 'rejected':
  //       return Colors.red;
  //     default:
  //       return Colors.grey;
  //   }
  // }
  

  Widget _buildKeyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$key:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}