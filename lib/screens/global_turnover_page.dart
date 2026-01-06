import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/global_turnover_response.dart';

class GlobalTurnoverPage extends StatefulWidget {
  const GlobalTurnoverPage({super.key});

  @override
  State<GlobalTurnoverPage> createState() => _GlobalTurnoverPageState();
}

class _GlobalTurnoverPageState extends State<GlobalTurnoverPage> {
  final Color brandColor = const Color(0xFF3979D3);

  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: brandColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Global Turnover",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_isFetching) const SizedBox(width: 8),
            if (_isFetching) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/Group 1 (1).png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Total Global Turnover: \$$_totalTurnover',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const SizedBox(height: 15),
                _buildTurnoverCard(label: "Left Team Turnover", amount: "\$$_leftTeamTurnover"),
                const SizedBox(height: 15),
                _buildTurnoverCard(label: "Right Team Turnover", amount: "\$$_rightTeamTurnover"),
                const SizedBox(height: 15),
                _buildTurnoverCard(label: "Matched Turnover", amount: "\$$_matchedTurnover"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _totalTurnover = 0.0;
  double _leftTeamTurnover = 0.0;
  double _rightTeamTurnover = 0.0;
  double _matchedTurnover = 0.0;

  Future<void> _loadData() async {
    setState(() => _isFetching = true);
    final userIdStr = await AuthService.getUserId();
    if (userIdStr == null) {
      setState(() => _isFetching = false);
      return;
    }
    final userId = int.tryParse(userIdStr) ?? 0;
    final GlobalTurnoverResponse? resp = await ApiRepository.getGlobalTurnover(userId);
    if (resp != null && resp.status && resp.data != null) {
      final data = resp.data!;
      setState(() {
        _totalTurnover = double.tryParse(data.totalTurnover) ?? 0.0;
        _leftTeamTurnover = double.tryParse(data.leftTeamTurnover) ?? 0.0;
        _rightTeamTurnover = double.tryParse(data.rightTeamTurnover) ?? 0.0;
        _matchedTurnover = double.tryParse(data.matchedTurnover) ?? 0.0;
        _isFetching = false;
      });
    } else {
      setState(() => _isFetching = false);
    }
  }

  Widget _buildTurnoverCard({required String label, required String amount}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: brandColor,
            ),
          ),
        ],
      ),
    );
  }
}
