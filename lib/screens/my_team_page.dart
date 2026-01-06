import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/mlm_tree_response.dart';
import '../models/my_team_response.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  final Color brandColor = const Color(0xFF3979D3);
  MyTeamData? _teamData;
  List<MlmNode> _allMembers = [];
  bool _isLoading = true;
  String _selectedLevel = "0";
  String _selectedFromDate = "";
  String _selectedToDate = "";
  String _selectedSide = "All";

  @override
  void initState() {
    super.initState();
    _fetchTeam();
  }

  Future<void> _fetchTeam() async {
    setState(() => _isLoading = true);
    final userId = await AuthService.getUserId();
    if (userId != null) {
      final response = await ApiRepository.getMyTeam(int.parse(userId.toString()));
      if (response != null && response.data != null) {
        setState(() {
          _teamData = response.data;
          _allMembers = [];
          _allMembers.addAll(response.data!.leftTeam);
          _allMembers.addAll(response.data!.rightTeam);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<MlmNode> _getFilteredMembers() {
    return _allMembers.where((member) {
      // Filter by side
      if (_selectedSide != "All" && member.position != _selectedSide.toLowerCase()) {
        return false;
      }
      // Filter by date range if dates are selected
      if (_selectedFromDate.isNotEmpty && _selectedToDate.isNotEmpty) {
        try {
          final memberDate = DateTime.parse(member.joinedAt);
          final fromDate = DateTime.parse(_selectedFromDate);
          final toDate = DateTime.parse(_selectedToDate);
          if (memberDate.isBefore(fromDate) || memberDate.isAfter(toDate)) {
            return false;
          }
        } catch (e) {
          // Skip date filtering if parsing fails
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = _getFilteredMembers();

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
          "Team Details",
          style: GoogleFonts.poppins(
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
                  Text(
                    'Level:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedLevel,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['0', '1', '2', '3', '4', '5'].map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text('Level $level'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedLevel = value!);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  Text(
                    'Side',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSide,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['All', 'Left', 'Right'].map((side) {
                        return DropdownMenuItem(
                          value: side,
                          child: Text(side),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSide = value!);
                      },
                    ),
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

            // Summary cards
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Direct Income', style: GoogleFonts.poppins(color: Colors.grey[700])),
                        const SizedBox(height: 6),
                        Text('\$${_teamData?.directIncome ?? '0'}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: brandColor)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Matching Income', style: GoogleFonts.poppins(color: Colors.grey[700])),
                        const SizedBox(height: 6),
                        Text('\$${_teamData?.matchingIncome ?? '0'}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: brandColor)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Team', style: GoogleFonts.poppins(color: Colors.grey[700])),
                        const SizedBox(height: 6),
                        Text('${_allMembers.length}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: brandColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Inline loading or results
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Updating team data...')
                    ],
                  ),
                ),
              )
            else if (filteredMembers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No team members found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              // Cards view of team members
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0,2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 26, backgroundImage: member.image != null && member.image != '' ? NetworkImage(member.image!) : const AssetImage('assets/profile.avif') as ImageProvider),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(member.email ?? '-', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 6),
                              Row(children: [
                                Text('ID: ${member.id}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                const SizedBox(width: 8),
                                Text(member.position.toUpperCase(), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                              ]),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(member.directIncome ?? '0', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.green)),
                            const SizedBox(height: 6),
                            Text(member.matchingIncome ?? '0', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blue)),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }




}
