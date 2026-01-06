import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RankEntry {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String name;
  final String requirement;

  RankEntry({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.name,
    required this.requirement,
  });
}

class RankSystemPage extends StatefulWidget {
  const RankSystemPage({super.key});

  @override
  State<RankSystemPage> createState() => _RankSystemPageState();
}

class _RankSystemPageState extends State<RankSystemPage> {
  final Color brandColor = const Color(0xFF3979D3);

  final List<RankEntry> _rankList = [
    RankEntry(
      icon: Icons.star,
      iconColor: Colors.white,
      iconBgColor: const Color(0xFFB0B7C3),
      name: 'Silver Star',
      requirement: 'Matched Business',
    ),
    RankEntry(
      icon: Icons.star,
      iconColor: Colors.white,
      iconBgColor: const Color(0xFFEBC137),
      name: 'Gold Star',
      requirement: 'Matched Business',
    ),
    RankEntry(
      icon: Icons.diamond,
      iconColor: Colors.white,
      iconBgColor: const Color(0xFF3979D3),
      name: 'Sapphire',
      requirement: 'Matched Business',
    ),
    RankEntry(
      icon: Icons.diamond,
      iconColor: Colors.white,
      iconBgColor: const Color(0xFFE74C3C),
      name: 'Ruby',
      requirement: 'Matched Business',
    ),
    RankEntry(
      icon: Icons.diamond,
      iconColor: Colors.white,
      iconBgColor: const Color(0xFF2ECC71),
      name: 'Emerald',
      requirement: 'Matched Business',
    ),
  ];

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
        title: Text(
          'Rank System',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            'Current Rank',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.verified, color: brandColor, size: 28),
                const SizedBox(width: 15),
                Text(
                  'Associate',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rankList.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey[200], height: 1),
              itemBuilder: (context, index) => _buildRankTile(_rankList[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankTile(RankEntry item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.iconBgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(item.icon, color: item.iconColor, size: 20),
      ),
      title: Text(
        item.name,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      ),
      subtitle: Text(
        item.requirement,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }
}
