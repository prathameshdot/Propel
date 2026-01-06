import 'mlm_tree_response.dart';

class MyTeamResponse {
  final bool status;
  final int code;
  final String message;
  final MyTeamData? data;

  MyTeamResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory MyTeamResponse.fromJson(Map<String, dynamic> json) {
    return MyTeamResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? MyTeamData.fromJson(json['data']) : null,
    );
  }
}

class MyTeamData {
  final String directIncome;
  final String matchingIncome;
  final int leftDirectCount;
  final int rightDirectCount;
  final int leftTeamCount;
  final int rightTeamCount;
  final List<MlmNode> leftTeam;
  final List<MlmNode> rightTeam;

  MyTeamData({
    required this.directIncome,
    required this.matchingIncome,
    required this.leftDirectCount,
    required this.rightDirectCount,
    required this.leftTeamCount,
    required this.rightTeamCount,
    required this.leftTeam,
    required this.rightTeam,
  });

  factory MyTeamData.fromJson(Map<String, dynamic> json) {
    final leftList = <MlmNode>[];
    final rightList = <MlmNode>[];
    if (json['left_team'] is List) {
      leftList.addAll((json['left_team'] as List).map((e) => MlmNode.fromJson(e as Map<String, dynamic>)));
    }
    if (json['right_team'] is List) {
      rightList.addAll((json['right_team'] as List).map((e) => MlmNode.fromJson(e as Map<String, dynamic>)));
    }

    return MyTeamData(
      directIncome: json['direct_income']?.toString() ?? '0.00',
      matchingIncome: json['matching_income']?.toString() ?? '0.00',
      leftDirectCount: json['left_direct_count'] ?? 0,
      rightDirectCount: json['right_direct_count'] ?? 0,
      leftTeamCount: json['left_team_count'] ?? 0,
      rightTeamCount: json['right_team_count'] ?? 0,
      leftTeam: leftList,
      rightTeam: rightList,
    );
  }
}
