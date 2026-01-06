class SuperadminWalletData {
  final String qrImage;
  final String address;

  SuperadminWalletData({
    required this.qrImage,
    required this.address,
  });

  factory SuperadminWalletData.fromJson(Map<String, dynamic> json) {
    return SuperadminWalletData(
      qrImage: json['qr_image'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class SuperadminWalletResponse {
  final bool status;
  final int code;
  final String message;
  final SuperadminWalletData? data;

  SuperadminWalletResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory SuperadminWalletResponse.fromJson(Map<String, dynamic> json) {
    return SuperadminWalletResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SuperadminWalletData.fromJson(json['data'])
          : null,
    );
  }
}