import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/referrals_list_response.dart';

class ReferralsPage extends StatefulWidget {
  const ReferralsPage({super.key});

  @override
  State<ReferralsPage> createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage> {
  final Color brandColor = const Color(0xFF3979D3);
  List<Referral> _referrals = [];
  bool _isLoading = true;
  String _selectedFromDate = '';
  String _selectedToDate = '';

  @override
  void initState() {
    super.initState();
    _fetchReferrals();
  }

  Future<void> _fetchReferrals() async {
    setState(() => _isLoading = true);
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr != null) {
        final userId = int.parse(userIdStr);
        final response = await ApiRepository.getReferralsList(userId: userId);

        if (response != null && response.status && response.data != null) {
          setState(() {
            _referrals = response.data!.referrals;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Referral> _getFilteredReferrals() {
    List<Referral> filtered = _referrals;

    if (_selectedFromDate.isNotEmpty) {
      filtered = filtered.where((referral) {
        try {
          final referralDate = DateTime.parse(referral.createdAt);
          final fromDate = DateTime.parse(_selectedFromDate);
          return referralDate.isAfter(fromDate.subtract(const Duration(days: 1)));
        } catch (e) {
          return true;
        }
      }).toList();
    }

    if (_selectedToDate.isNotEmpty) {
      filtered = filtered.where((referral) {
        try {
          final referralDate = DateTime.parse(referral.createdAt);
          final toDate = DateTime.parse(_selectedToDate);
          return referralDate.isBefore(toDate.add(const Duration(days: 1)));
        } catch (e) {
          return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredReferrals = _getFilteredReferrals();

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
          'My Referrals',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Section
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From Date',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _selectedFromDate = date.toIso8601String().split('T')[0]);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedFromDate.isEmpty ? 'mm/dd/yyyy' : _selectedFromDate,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _selectedFromDate.isEmpty ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To Date',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _selectedToDate = date.toIso8601String().split('T')[0]);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedToDate.isEmpty ? 'mm/dd/yyyy' : _selectedToDate,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _selectedToDate.isEmpty ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Results info
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Page 1 / 1",
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 20),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTableHeader('S.N.', flex: 1),
                  _buildTableHeader('Joining Date', flex: 2),
                  _buildTableHeader('Referral ID', flex: 2),
                  _buildTableHeader('Name', flex: 2),
                  _buildTableHeader('Position', flex: 2),
                  _buildTableHeader('Status', flex: 2),
                  _buildTableHeader('Referral Bonus', flex: 2),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Loading indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredReferrals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No referrals found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              // Table Rows
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredReferrals.length,
                itemBuilder: (context, index) {
                  return _buildTableRow(filteredReferrals[index], index + 1);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(Referral referral, int serialNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTableCell(serialNumber.toString(), flex: 1),
          _buildTableCell(_formatDate(referral.createdAt), flex: 2),
          _buildTableCell(referral.id.toString(), flex: 2),
          _buildTableCell('${referral.firstName} ${referral.lastName}', flex: 2),
          _buildTableCell(referral.positionName, flex: 2),
          _buildTableCell('Active', flex: 2),
          _buildTableCell('\$0.00', flex: 2), // Placeholder for referral bonus
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}