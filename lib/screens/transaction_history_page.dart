import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_repository.dart';
import '../utils/colors.dart';
import '../models/user_deposit_models.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  bool _isLoading = true;
  // Unified transaction record list (deposits + withdraws)
  List<_TransactionRecord> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
  }

  Future<void> _loadTransactionHistory() async {
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) return;

      final userId = int.parse(userIdStr);
      final depositsResp = await ApiRepository.getDeposits(userId);
      final withdrawsResp = await ApiRepository.getWithdraws(userId);

      final List<_TransactionRecord> txs = [];

      if (depositsResp != null && depositsResp.status) {
        txs.addAll(depositsResp.data.map((d) => _TransactionRecord.fromDeposit(d)));
      }

      if (withdrawsResp != null && withdrawsResp.status) {
        txs.addAll(withdrawsResp.data.map((w) => _TransactionRecord.fromWithdraw(w)));
      }

      // sort by createdAt desc
      txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _transactions = txs;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while loading transaction history')),
        );
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
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactionHistory,
        child: _transactions.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _isLoading ? 'Loading transactions...' : 'No Transactions Yet',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  return _buildUnifiedTransactionCard(tx);
                },
              ),
      ),
    );
  }

  Widget _buildUnifiedTransactionCard(_TransactionRecord tx) {
    final isDeposit = tx.type == 'deposit';
    final isCompleted = tx.status.toLowerCase() == 'approved' || tx.status.toLowerCase() == 'completed';
    final statusText = tx.status.toLowerCase() == 'approved' ? 'Completed' : tx.status.toLowerCase() == 'pending' ? 'Pending' : tx.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDeposit ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isDeposit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDeposit ? 'Deposit' : 'Withdraw',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.description.isNotEmpty ? tx.description : (isDeposit ? 'Package Activation' : 'Withdraw Request'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(tx.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isDeposit ? '+' : '-'}\$${tx.amount}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDeposit ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

}

class _TransactionRecord {
  final String type; // 'deposit' or 'withdraw'
  final String id;
  final String amount;
  final String status;
  final String createdAt;
  final String description;

  _TransactionRecord({required this.type, required this.id, required this.amount, required this.status, required this.createdAt, required this.description});

  factory _TransactionRecord.fromDeposit(DepositItem d) {
    return _TransactionRecord(
      type: 'deposit',
      id: d.id.toString(),
      amount: d.amount,
      status: d.status,
      createdAt: d.createdAt,
      description: d.remarks,
    );
  }

  factory _TransactionRecord.fromWithdraw(dynamic w) {
    // w can be WithdrawItem
    final id = (w.id ?? w.withdrawId ?? w.withdraw_id ?? 0).toString();
    return _TransactionRecord(
      type: 'withdraw',
      id: id,
      amount: w.amount ?? (w as dynamic).amount?.toString() ?? '0',
      status: w.status ?? '',
      createdAt: w.createdAt ?? (w as dynamic).created_at ?? '',
      description: (w.usdtAddress != null && (w.usdtAddress as String).isNotEmpty) ? 'USDT: ${w.usdtAddress}' : '',
    );
  }
  
}
