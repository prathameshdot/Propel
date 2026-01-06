class RewardIncomeResponse {
  final bool status;
  final int code;
  final String message;
  final dynamic data; // can be Map or List

  RewardIncomeResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory RewardIncomeResponse.fromJson(Map<String, dynamic> json) {
    return RewardIncomeResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
