class ApiResponse {
  final bool status;
  final int code;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}