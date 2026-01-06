import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../utils/colors.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/matching_income_response.dart';

class MatchingIncomeEntry {
  final String leftAmount;
  final String rightAmount;
  final String date;
  final String incomeAmount;

  MatchingIncomeEntry({
    required this.leftAmount,
    required this.rightAmount,
    required this.date,
    required this.incomeAmount,
  });
}

class MatchingIncomePage extends StatefulWidget {
  const MatchingIncomePage({super.key});

  @override
  State<MatchingIncomePage> createState() => _MatchingIncomePageState();
}

class _MatchingIncomePageState extends State<MatchingIncomePage> {
  final Color brandColor = const Color(0xFF3979D3);
  String _totalMatchingIncome = '0';
  int _leftTeamCount = 0;
  int _rightTeamCount = 0;
  List<dynamic> _leftTeam = [];
  List<dynamic> _rightTeam = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        backgroundColor: brandColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Matching Income',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Income Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Matching Income: \$${_totalMatchingIncome}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isLoading) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Left Matching Income Section
                  Text(
                    'Left Matching Income',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                        Text(
                          'Left Team Count: $_leftTeamCount',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_leftTeam.isEmpty)
                          Text(
                            'No left team members',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _leftTeam.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final m = _leftTeam[idx];
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: m['image'] != null && m['image'] != ''
                                        ? NetworkImage(m['image'])
                                        : const AssetImage('assets/profile.avif') as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m['name'] ?? '-', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                        Text(m['email'] ?? '-', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Right Matching Income Section
                  Text(
                    'Right Matching Income',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                        Text(
                          'Right Team Count: $_rightTeamCount',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_rightTeam.isEmpty)
                          Text(
                            'No right team members',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _rightTeam.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final m = _rightTeam[idx];
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: m['image'] != null && m['image'] != ''
                                        ? NetworkImage(m['image'])
                                        : const AssetImage('assets/profile.avif') as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m['name'] ?? '-', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                        Text(m['email'] ?? '-', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recent Matching Income History
                  Text(
                    'Recent Matching Income',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                    child: Center(
                      child: Text(
                        _leftTeam.isEmpty && _rightTeam.isEmpty
                            ? 'No matching income history available'
                            : 'Left team: ${_leftTeam.length}  Right team: ${_rightTeam.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userIdStr = await AuthService.getUserId();
    if (userIdStr == null) {
      setState(() => _isLoading = false);
      return;
    }
    final userId = int.tryParse(userIdStr) ?? 0;
    final MatchingIncomeResponse? resp = await ApiRepository.getMatchingIncome(userId);
    if (resp != null && resp.status && resp.data != null) {
      final data = resp.data!;
      setState(() {
        _totalMatchingIncome = data.totalMatchingIncome;
        _leftTeamCount = data.leftTeamCount;
        _rightTeamCount = data.rightTeamCount;
        _leftTeam = data.leftTeam;
        _rightTeam = data.rightTeam;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }
}
