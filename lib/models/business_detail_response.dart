class BusinessDetailItem {
  final String date;
  final String leftPV;
  final String rightPV;
  final String totalPoints;

  BusinessDetailItem({
    required this.date,
    required this.leftPV,
    required this.rightPV,
    required this.totalPoints,
  });

  factory BusinessDetailItem.fromJson(Map<String, dynamic> json) {
    return BusinessDetailItem(
      date: json['date'] ?? '',
      leftPV: json['leftPV']?.toString() ?? '0',
      rightPV: json['rightPV']?.toString() ?? '0',
      totalPoints: json['totalpoints']?.toString() ?? '0',
    );
  }
}

class BusinessDetailResponse {
  final bool status;
  final int code;
  final String message;
  final List<BusinessDetailItem> data;

  BusinessDetailResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory BusinessDetailResponse.fromJson(dynamic json) {
    final items = <BusinessDetailItem>[];
    if (json is Map<String, dynamic> && json['data'] is List) {
      items.addAll((json['data'] as List).map((e) => BusinessDetailItem.fromJson(e as Map<String, dynamic>)));
      return BusinessDetailResponse(
        status: json['status'] ?? false,
        code: json['code'] ?? 0,
        message: json['message'] ?? '',
        data: items,
      );
    }
    return BusinessDetailResponse(status: false, code: 0, message: 'Invalid response', data: []);
  }
}