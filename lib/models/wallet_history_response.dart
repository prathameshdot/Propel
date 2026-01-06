class WalletHistoryResponse {
  final bool status;
  final int code;
  final String message;
  final WalletHistoryData? data;

  WalletHistoryResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WalletHistoryResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? WalletHistoryData.fromJson(json['data']) : null,
    );
  }
}

class WalletHistoryData {
  final int currentPage;
  final List<dynamic> data;
  final int total;

  WalletHistoryData({
    required this.currentPage,
    required this.data,
    required this.total,
  });

  factory WalletHistoryData.fromJson(Map<String, dynamic> json) {
    return WalletHistoryData(
      currentPage: json['current_page'] ?? 1,
      data: json['data'] ?? [],
      total: json['total'] ?? 0,
    );
  }
}
