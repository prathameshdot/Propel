class MlmCheckPositionResponse {
  final bool status;
  final int code;
  final dynamic message;
  final dynamic data;

  MlmCheckPositionResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory MlmCheckPositionResponse.fromJson(Map<String, dynamic> json) {
    return MlmCheckPositionResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'],
    );
  }
}
