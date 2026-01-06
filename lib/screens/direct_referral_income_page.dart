import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';


class DirectReferralIncomePage extends StatefulWidget {
  const DirectReferralIncomePage({super.key});

  @override
  State<DirectReferralIncomePage> createState() =>
      _DirectReferralIncomePageState();
}

class _DirectReferralIncomePageState extends State<DirectReferralIncomePage> {
  final Color brandColor = const Color(0xFF3979D3);
  bool _isLoading = true;
  String _totalDirectIncome = '0';
  int _leftDirectCount = 0;
  int _rightDirectCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDirectIncome();
  }

  Future<void> _loadDirectIncome() async {
    setState(() => _isLoading = true);
    final userId = await AuthService.getUserId();
    if (userId != null) {
      final response = await ApiRepository.getDirectIncome(int.parse(userId));
      if (response != null && response.status && response.data != null) {
        setState(() {
          _totalDirectIncome = response.data!.totalDirectIncome;
          _leftDirectCount = response.data!.leftDirectCount;
          _rightDirectCount = response.data!.rightDirectCount;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
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
          'Daily Income',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Total Direct Income Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
              child: Column(
                children: [
                  Text(
                    'Total Direct Income',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_totalDirectIncome}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Direct counts
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      children: [
                        Text('Left Direct Count', style: GoogleFonts.poppins(color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text('$_leftDirectCount', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      children: [
                        Text('Right Direct Count', style: GoogleFonts.poppins(color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text('$_rightDirectCount', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Updating direct income...')
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    'No further details available for direct referrals from this endpoint.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
