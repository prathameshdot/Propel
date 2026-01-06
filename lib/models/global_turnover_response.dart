class GlobalTurnoverResponse {
  final bool status;
  final int code;
  final String message;
  final GlobalTurnoverData? data;

  GlobalTurnoverResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory GlobalTurnoverResponse.fromJson(Map<String, dynamic> json) {
    return GlobalTurnoverResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? GlobalTurnoverData.fromJson(json['data']) : null,
    );
  }
}

class GlobalTurnoverData {
  final String totalTurnover;
  final String leftTeamTurnover;
  final String rightTeamTurnover;
  final String matchedTurnover;

  GlobalTurnoverData({
    required this.totalTurnover,
    required this.leftTeamTurnover,
    required this.rightTeamTurnover,
    required this.matchedTurnover,
  });

  factory GlobalTurnoverData.fromJson(Map<String, dynamic> json) {
    return GlobalTurnoverData(
      totalTurnover: json['total_turnover']?.toString() ?? '0.00',
      leftTeamTurnover: json['left_team_turnover']?.toString() ?? '0.00',
      rightTeamTurnover: json['right_team_turnover']?.toString() ?? '0.00',
      matchedTurnover: json['matched_turnover']?.toString() ?? '0.00',
    );
  }
}
