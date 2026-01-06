class DirectIncomeResponse {
  final bool status;
  final int code;
  final String message;
  final DirectIncomeData? data;

  DirectIncomeResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory DirectIncomeResponse.fromJson(Map<String, dynamic> json) {
    return DirectIncomeResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? DirectIncomeData.fromJson(json['data']) : null,
    );
  }
}

class DirectIncomeData {
  final String totalDirectIncome;
  final int leftDirectCount;
  final int rightDirectCount;

  DirectIncomeData({
    required this.totalDirectIncome,
    required this.leftDirectCount,
    required this.rightDirectCount,
  });

  factory DirectIncomeData.fromJson(Map<String, dynamic> json) {
    return DirectIncomeData(
      totalDirectIncome: json['total_direct_income']?.toString() ?? '0.00',
      leftDirectCount: json['left_direct_count'] ?? 0,
      rightDirectCount: json['right_direct_count'] ?? 0,
    );
  }
}
