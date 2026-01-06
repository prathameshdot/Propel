class RegisterResponse {
  final bool status;
  final int code;
  final dynamic
  message; // message can be String, List or Map (validation errors)
  final RegisterData? data;

  RegisterResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

class RegisterData {
  final Map<String, dynamic> user;
  final String token;

  RegisterData({required this.user, required this.token});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(user: json['user'] ?? {}, token: json['token'] ?? '');
  }
}
