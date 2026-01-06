import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../routes/app_router.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int? _kycVerified;

  @override
  void initState() {
    super.initState();
    _loadCachedStatus();
    _refreshKYCStatus(); // Refresh in background
  }

  Future<void> _loadCachedStatus() async {
    try {
      final cachedVerified = await AuthService.getKycVerified();
      if (mounted && cachedVerified != null) {
        setState(() {
          _kycVerified = cachedVerified;
        });
      }
    } catch (e) {
      // Silently handle error
    }
  }

  Future<void> _refreshKYCStatus() async {
    try {
      final userIdString = await AuthService.getUserId();
      if (userIdString != null) {
        final userId = int.tryParse(userIdString);
        if (userId != null) {
          final response = await ApiRepository.getKyc(userId);

          if (response != null && response.status && response.data != null) {
            // status can be true/false (boolean) or "pending"/"verified" (string)
            final statusStr = response.data!.status.toString().toLowerCase();
            final isVerified =
                statusStr == 'true' ||
                statusStr == 'verified' ||
                statusStr == 'approved';
            final verified = isVerified ? 1 : 0;
            await AuthService.setKycStatus(
              verified,
              isVerified ? 'Verified' : 'Pending',
            );

            if (mounted) {
              setState(() {
                _kycVerified = verified;
              });
            }
          }
        }
      }
    } catch (e) {
      // Silently handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.brand),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/Group 1 (1).png',
                        fit: BoxFit.cover,
                        width: 65,
                        height: 65,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.account_circle,
                            size: 65,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Propel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.home);
            },
          ),

          // Complete KYC - Show only if KYC is pending (0)
          if (_kycVerified == 0)
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Complete KYC'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRouter.completeKYC);
              },
            ),

          // // Package Activation
          // ListTile(
          //   leading: const Icon(Icons.card_giftcard_outlined),
          //   title: const Text('Package Activation'),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(context).pushNamed(AppRouter.activationPackages);
          //   },
          // ),

          // Packages ExpansionTile for sub-menu
          ExpansionTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Packages'),
            children: [
              ListTile(
                leading: const Icon(Icons.add_shopping_cart_outlined),
                title: const Text('Top Up'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRouter.activationPackages);
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Top Up Details'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRouter.topupDetails);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up_outlined),
                title: const Text('Investment Request'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRouter.investmentRequest);
                },
              ),
            ],
          ),

          const Divider(),

          // Income Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'INCOME REPORTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person_add_alt_outlined),
            title: const Text('Direct Referral Income'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.directReferralIncome);
            },
          ),

          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Matching Income'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.matchingIncome);
            },
          ),

          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Reward Income'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.rewardIncome);
            },
          ),

          ListTile(
            leading: const Icon(Icons.public_outlined),
            title: const Text('Global Income'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.globalTurnover);
            },
          ),

          const Divider(),

          // Genealogy Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'GENEALOGY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),

          // Genealogy ExpansionTile for sub-menu
          ExpansionTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('Genealogy'),
            children: [
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('Referrals'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRouter.referrals);
                },
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('Team'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRouter.myTeam);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_tree),
                title: const Text('Binary Tree'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRouter.binaryTree);
                },
              ),
              ListTile(
                leading: const Icon(Icons.business_center_outlined),
                title: const Text('Business Details'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRouter.businessDetails);
                },
              ),
            ],
          ),

          const Divider(),

          // Settings Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.military_tech_outlined),
            title: const Text('Rank System'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.rankSystem);
            },
          ),

          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Profile & KYC'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.profile);
            },
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.terms);
            },
          ),

          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Support'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.support);
            },
          ),
              ],
            ),
          ),
          
          // Logout Button at the bottom
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  // Clear all user data
                  await AuthService.clearToken();
                  await AuthService.clearUserId();
                  await AuthService.setLoggedIn(false);
                  
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.login,
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
