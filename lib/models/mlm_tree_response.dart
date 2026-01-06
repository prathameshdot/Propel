class MlmNode {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String? image;
  final String position;
  final String? status;
  final String? directIncome;
  final String? matchingIncome;
  final String? gtIncome;
  final String? referralCode;
  final int sponsorId;
  final int parentId;
  final String joinedAt;

  MlmNode({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.image,
    required this.position,
    this.status,
    this.directIncome,
    this.matchingIncome,
    this.gtIncome,
    this.referralCode,
    required this.sponsorId,
    required this.parentId,
    required this.joinedAt,
  });

  factory MlmNode.fromJson(Map<String, dynamic> json) {
    return MlmNode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      image: json['image'],
      position: json['position'] ?? '',
      status: json['status'],
      directIncome: json['direct_income'],
      matchingIncome: json['matching_income'],
      gtIncome: json['gt_income'],
      referralCode: json['referral_code'],
      sponsorId: json['sponsor_id'] ?? 0,
      parentId: json['parent_id'] ?? 0,
      joinedAt: json['joined_at'] ?? '',
    );
  }
}

class FiltersApplied {
  final String usedmyrefrencecode;
  final String? fromDate;
  final String? toDate;
  final String? side;
  final String? status;

  FiltersApplied({
    required this.usedmyrefrencecode,
    this.fromDate,
    this.toDate,
    this.side,
    this.status,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(
      usedmyrefrencecode: json['usedmyrefrencecode'] ?? 'all',
      fromDate: json['from_date'],
      toDate: json['to_date'],
      side: json['side'],
      status: json['status'],
    );
  }
}

class MlmTreeResponse {
  final bool status;
  final int code;
  final dynamic message;
  final List<MlmNode> data;
  final FiltersApplied? filtersApplied;
  final int? totalRecords;

  MlmTreeResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.filtersApplied,
    this.totalRecords,
  });

  factory MlmTreeResponse.fromJson(dynamic json) {
    final dataList = <MlmNode>[];
    if (json is Map<String, dynamic>) {
      if (json['data'] is List) {
        dataList.addAll(
          (json['data'] as List).map(
            (e) => MlmNode.fromJson(e as Map<String, dynamic>),
          ),
        );
      }
      return MlmTreeResponse(
        status: json['status'] ?? false,
        code: json['code'] ?? 0,
        message: json['message'],
        data: dataList,
        filtersApplied: json['filters_applied'] != null
            ? FiltersApplied.fromJson(json['filters_applied'])
            : null,
        totalRecords: json['total_records'],
      );
    } else if (json is List) {
      dataList.addAll(
        (json).map((e) => MlmNode.fromJson(e as Map<String, dynamic>)),
      );
      return MlmTreeResponse(
        status: true,
        code: 200,
        message: '',
        data: dataList,
      );
    }

    return MlmTreeResponse(
      status: false,
      code: 0,
      message: 'Invalid response',
      data: [],
    );
  }
}
