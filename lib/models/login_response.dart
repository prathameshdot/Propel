class LoginResponse {
  final bool status;
  final int code;
  final dynamic message;
  final LoginData? data;

  LoginResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final Map<String, dynamic> user;
  final String token;

  LoginData({required this.user, required this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(user: json['user'] ?? {}, token: json['token'] ?? '');
  }
}
