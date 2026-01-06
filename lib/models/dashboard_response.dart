class DashboardResponse {
  final bool status;
  final int code;
  final dynamic message;
  final DashboardData? data;

  DashboardResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }
}

class DashboardData {
  final String walletBalance;
  final String directIncome;
  final String matchingIncome;
  final int leftTeamCount;
  final int rightTeamCount;
  final String leftTeamBusiness;
  final String rightTeamBusiness;
  final List<dynamic> leftTeam;
  final List<dynamic> rightTeam;

  DashboardData({
    required this.walletBalance,
    required this.directIncome,
    required this.matchingIncome,
    required this.leftTeamCount,
    required this.rightTeamCount,
    required this.leftTeamBusiness,
    required this.rightTeamBusiness,
    required this.leftTeam,
    required this.rightTeam,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      walletBalance: json['wallet_balance']?.toString() ?? '0.00',
      directIncome: json['direct_income']?.toString() ?? '0.00',
      matchingIncome: json['matching_income']?.toString() ?? '0.00',
      leftTeamCount: json['left_team_count'] ?? 0,
      rightTeamCount: json['right_team_count'] ?? 0,
      leftTeamBusiness: json['left_team_business']?.toString() ?? '0.00',
      rightTeamBusiness: json['right_team_business']?.toString() ?? '0.00',
      leftTeam: json['left_team'] ?? [],
      rightTeam: json['right_team'] ?? [],
    );
  }
}
