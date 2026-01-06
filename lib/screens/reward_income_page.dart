import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/rewards_response.dart';

class RewardIncomePage extends StatefulWidget {
  const RewardIncomePage({super.key});

  @override
  State<RewardIncomePage> createState() => _RewardIncomePageState();
}

class _RewardIncomePageState extends State<RewardIncomePage> {
  List<Reward> _rewardList = [];
  bool _isLoading = true;
  double _totalRewardIncome = 0.0;
  Map<String, dynamic>? _rewardDataMap;

  @override
  void initState() {
    super.initState();
    _fetchRewardIncome();
  }

  Future<void> _fetchRewardIncome() async {
    setState(() => _isLoading = true);
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) {
        setState(() => _isLoading = false);
        return;
      }
      final userId = int.tryParse(userIdStr) ?? 0;
      final resp = await ApiRepository.getRewardIncome(userId);
      if (resp != null && resp.status) {
        setState(() {
          // resp.data may be Map or List; handle both
          if (resp.data is List) {
            // If server returns list of reward items
            _rewardList = (resp.data as List).map((e) => Reward.fromJson(e)).toList();
            _totalRewardIncome = 0.0;
            for (final r in _rewardList) {
              final val = double.tryParse(r.rewardValue) ?? 0.0;
              _totalRewardIncome += val;
            }
          } else if (resp.data is Map) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(resp.data);
            _rewardDataMap = map;
            // If API provides total under known key
            final total = map['total_reward_income'] ?? map['total'] ?? map['total_income'];
            if (total != null) {
              _totalRewardIncome = double.tryParse(total.toString()) ?? 0.0;
            }
            // If the map contains key 'rewards' as list, parse it
            if (map['rewards'] is List) {
              _rewardList = (map['rewards'] as List).map((e) => Reward.fromJson(e)).toList();
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatAmount(String value) {
    final number = double.tryParse(value);
    if (number == null) return value;
    
    // If it's a whole number, show without decimals
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    // Otherwise show with 2 decimal places
    return number.toStringAsFixed(2);
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
          "Reward Income",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Total Income: \$${_totalRewardIncome.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF555555),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Table headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Reward',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Required',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Value',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Updating reward income...'),
                ],
              ),
            )
          else if (_rewardDataMap != null)
            // Render map key:value pairs from API
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _rewardDataMap!.entries.map((e) {
                  final val = e.value;
                  final display = val is String || val is num ? val.toString() : (val is Map || val is List ? val.toString() : val.toString());
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${e.key}',
                            style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            display,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(color: AppColors.brand),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else if (_rewardList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'No rewards available',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _rewardList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) =>
                    _buildRewardTile(_rewardList[index]),
              ),
            ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Income',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '\$${_totalRewardIncome.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRewardTile(Reward item) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.icon != null
                    ? Image.network(
                        item.icon!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      )
                    : const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            _formatAmount(item.requiredMatchingBusiness),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            item.rewardType == 'amount'
                ? '\$${double.tryParse(item.rewardValue)?.toStringAsFixed(0) ?? item.rewardValue}'
                : item.rewardValue,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.brand,
            ),
          ),
        ),
      ],
    );
  }
}
