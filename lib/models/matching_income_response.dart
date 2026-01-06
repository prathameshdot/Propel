class MatchingIncomeResponse {
  final bool status;
  final int code;
  final String message;
  final MatchingIncomeData? data;

  MatchingIncomeResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory MatchingIncomeResponse.fromJson(Map<String, dynamic> json) {
    return MatchingIncomeResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? MatchingIncomeData.fromJson(json['data']) : null,
    );
  }
}

class MatchingIncomeData {
  final String totalMatchingIncome;
  final int leftTeamCount;
  final int rightTeamCount;
  final List<dynamic> leftTeam;
  final List<dynamic> rightTeam;

  MatchingIncomeData({
    required this.totalMatchingIncome,
    required this.leftTeamCount,
    required this.rightTeamCount,
    required this.leftTeam,
    required this.rightTeam,
  });

  factory MatchingIncomeData.fromJson(Map<String, dynamic> json) {
    return MatchingIncomeData(
      totalMatchingIncome: json['total_matching_income']?.toString() ?? '0.00',
      leftTeamCount: json['left_team_count'] ?? 0,
      rightTeamCount: json['right_team_count'] ?? 0,
      leftTeam: json['left_team'] ?? [],
      rightTeam: json['right_team'] ?? [],
    );
  }
}
