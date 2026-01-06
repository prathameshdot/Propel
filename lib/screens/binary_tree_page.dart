import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_repository.dart';
import '../utils/colors.dart';
import '../models/mlm_tree_response.dart';

class BinaryTreePage extends StatefulWidget {
  const BinaryTreePage({super.key});

  @override
  State<BinaryTreePage> createState() => _BinaryTreePageState();
}

class _BinaryTreePageState extends State<BinaryTreePage> {
  bool _isLoading = true;
  MlmTreeResponse? _treeData;
  int? _currentUserId;
  List<int> _navigationStack = []; // Stack to track navigation history

  // Filters
  String _usedMyRefCode = 'all'; // 'yes', 'no', 'all'
  String? _fromDate;
  String? _toDate;
  String? _side; // 'left' or 'right' or null
  String? _status; // 'active' or 'inactive' or null

  @override
  void initState() {
    super.initState();
    _loadInitialTree();
  }

  Future<void> _loadInitialTree() async {
    try {
      final userIdStr = await AuthService.getUserId();
      if (userIdStr == null) return;

      final userId = int.parse(userIdStr);
      setState(() {
        _currentUserId = userId;
        _navigationStack = [userId]; // Start with current user
      });

      await _loadTreeData(userId);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load tree data')),
        );
      }
    }
  }

  Future<void> _loadTreeData(int userId) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiRepository.getMlmTree(
        userId,
        usedMyReferenceCode: _usedMyRefCode,
        fromDate: _fromDate,
        toDate: _toDate,
        side: _side,
        status: _status,
      );
      if (response != null && response.status) {
        // Ensure the root node corresponds to the requested userId.
        // If the API returned a node matching userId, move it to first position.
        final dataList = List.of(response.data);
        final rootIndex = dataList.indexWhere((n) => n.id == userId);
        if (rootIndex > 0) {
          final rootNode = dataList.removeAt(rootIndex);
          dataList.insert(0, rootNode);
        }

        // If no node for current user exists, insert a synthetic root using profile info
        if (dataList.isEmpty || dataList[0].id != userId) {
          try {
            final profileResp = await ApiRepository.getUserProfile(userId);
            final rootName = profileResp?.data?.basicInfo.fullName ?? 'You';
            final rootNode = MlmNode(
              id: userId,
              name: rootName,
              username: profileResp?.data?.basicInfo.username ?? '',
              position: '',
              joinedAt: profileResp?.data?.basicInfo.createdAt ?? DateTime.now().toIso8601String(),
              sponsorId: 0,
              parentId: 0,
            );
            dataList.insert(0, rootNode);
          } catch (_) {}
        }

        setState(() {
          _treeData = MlmTreeResponse(
            status: response.status,
            code: response.code,
            message: response.message,
            data: dataList,
            filtersApplied: response.filtersApplied,
            totalRecords: response.totalRecords,
          );
          _isLoading = false;
        });
      } else {
        // Even if API fails or returns empty, create a placeholder tree with just the current user
        setState(() {
          _treeData = MlmTreeResponse(
            status: true,
            code: 200,
            message: 'Tree data loaded',
            data: [
              MlmNode(
                id: userId,
                name: 'Current User',
                username: '',
                position: '',
                joinedAt: DateTime.now().toIso8601String(),
                sponsorId: 0,
                parentId: 0,
              )
            ]
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      // On error, still show the current user node
      setState(() {
        _treeData = MlmTreeResponse(
          status: true,
          code: 200,
          message: 'Tree data loaded',
          data: [
            MlmNode(
              id: userId,
              name: 'Current User',
              username: '',
              position: '',
              joinedAt: DateTime.now().toIso8601String(),
              sponsorId: 0,
              parentId: 0,
            )
          ]
        );
        _isLoading = false;
      });
    }
  }

  void _navigateToNode(int userId) {
    setState(() {
      _navigationStack.add(userId);
      _currentUserId = userId;
    });
    _loadTreeData(userId);
  }

  void _goBack() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        _currentUserId = _navigationStack.last;
      });
      _loadTreeData(_currentUserId!);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String localRefCode = _usedMyRefCode;
        String? localSide = _side;
        String? localStatus = _status;
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Reference Filter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                    DropdownButton<String>(
                      value: localRefCode,
                      underline: const SizedBox(),
                      items: ['all', 'yes', 'no'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setModalState(() => localRefCode = v ?? 'all'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Side', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                    DropdownButton<String?>(
                      value: localSide,
                      underline: const SizedBox(),
                      items: [null, 'left', 'right'].map((e) => DropdownMenuItem(value: e, child: Text(e ?? 'Any'))).toList(),
                      onChanged: (v) => setModalState(() => localSide = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                    DropdownButton<String?>(
                      value: localStatus,
                      underline: const SizedBox(),
                      items: [null, 'active', 'inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e ?? 'Any'))).toList(),
                      onChanged: (v) => setModalState(() => localStatus = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _usedMyRefCode = localRefCode;
                            _side = localSide;
                            _status = localStatus;
                          });
                          Navigator.of(context).pop();
                          if (_currentUserId != null) _loadTreeData(_currentUserId!);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  MlmNode _getCurrentNode() {
    if (_treeData != null && _treeData!.data.isNotEmpty) {
      return _treeData!.data[0];
    }
    // Return a placeholder node for the current user
    return MlmNode(
      id: _currentUserId ?? 0,
      name: 'Current User',
      username: '',
      position: '',
      joinedAt: '',
      sponsorId: 0,
      parentId: 0,
    );
  }

  MlmNode? _getLeftChild() {
    if (_treeData != null && _treeData!.data.length > 1) {
      // Find direct children (not grandchildren)
      final directChildren = _treeData!.data.where((node) =>
        node.parentId == _currentUserId &&
        node.position == 'left'
      ).toList();
      return directChildren.isNotEmpty ? directChildren.first : null;
    }
    return null;
  }

  MlmNode? _getRightChild() {
    if (_treeData != null && _treeData!.data.length > 1) {
      // Find direct children (not grandchildren)
      final directChildren = _treeData!.data.where((node) =>
        node.parentId == _currentUserId &&
        node.position == 'right'
      ).toList();
      return directChildren.isNotEmpty ? directChildren.first : null;
    }
    return null;
  }

  Widget _buildChildNodeSection(String label, MlmNode? node) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        if (node != null)
          _buildTreeNode(node)
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Empty',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  int _getTotalReferrals() {
    int count = 0;
    if (_getLeftChild() != null) count++;
    if (_getRightChild() != null) count++;
    return count;
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
          onPressed: _goBack,
        ),
        title: Text(
          'Binary Tree',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _openFilterSheet(),
          ),
        ],
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Tree visualization
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        // Root node (current user)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Root node
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Root Node',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTreeNode(_getCurrentNode(), isRoot: true),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Left and Right child nodes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left child
                            Expanded(
                              child: _buildChildNodeSection('Left', _getLeftChild()),
                            ),
                            const SizedBox(width: 20),
                            // Right child
                            Expanded(
                              child: _buildChildNodeSection('Right', _getRightChild()),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filters and Tree statistics
                  if (_treeData?.filtersApplied != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text('Filter: ${_treeData!.filtersApplied!.usedmyrefrencecode}')),
                          Expanded(child: Text('Side: ${_treeData!.filtersApplied!.side ?? 'any'}')),
                          Expanded(child: Text('Status: ${_treeData!.filtersApplied!.status ?? 'any'}')),
                        ],
                      ),
                    ),

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
                          'Tree Statistics',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Total Direct', _getTotalReferrals().toString()),
                            _buildStatItem('Left Child', _getLeftChild() != null ? "Active" : "Empty"),
                            _buildStatItem('Right Child', _getRightChild() != null ? "Active" : "Empty"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTreeNode(MlmNode node, {bool isRoot = false}) {
    return GestureDetector(
      onTap: isRoot ? null : () => _navigateToNode(node.id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRoot ? AppColors.brand : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRoot ? AppColors.brand : Colors.blue.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isRoot ? Colors.white24 : Colors.grey.shade200,
              child: Text(
                node.name.isNotEmpty ? node.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isRoot ? Colors.white : AppColors.brand,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              node.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isRoot ? Colors.white : const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${node.id}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isRoot ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 20,
              alignment: Alignment.center,
              child: node.status == 'active'
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isRoot ? Colors.white24 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isRoot ? Colors.white : Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.brand,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}