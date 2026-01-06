class PackageDetail {
  final int id;
  final int userId;
  final String userName;
  final int packageId;
  final String packageName;
  final String price;
  final String status;
  final String purchasedAt;

  PackageDetail({
    required this.id,
    required this.userId,
    required this.userName,
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.status,
    required this.purchasedAt,
  });

  factory PackageDetail.fromJson(Map<String, dynamic> json) {
    return PackageDetail(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      packageId: json['package_id'] ?? 0,
      packageName: json['package_name'] ?? '',
      price: json['price'] ?? '0.00',
      status: json['status'] ?? '',
      purchasedAt: json['purchased_at'] ?? '',
    );
  }
}

class RootPackageDetailMeta {
  final int totalCount;
  final String typeApplied;

  RootPackageDetailMeta({
    required this.totalCount,
    required this.typeApplied,
  });

  factory RootPackageDetailMeta.fromJson(Map<String, dynamic> json) {
    return RootPackageDetailMeta(
      totalCount: json['total_count'] ?? 0,
      typeApplied: json['type_applied'] ?? '',
    );
  }
}

class RootPackageDetailResponse {
  final bool status;
  final int code;
  final String message;
  final List<PackageDetail> data;
  final RootPackageDetailMeta? meta;

  RootPackageDetailResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.meta,
  });

  factory RootPackageDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataList = <PackageDetail>[];
    if (json['data'] is List) {
      dataList.addAll(
        (json['data'] as List).map(
          (e) => PackageDetail.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return RootPackageDetailResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: dataList,
      meta: json['meta'] != null
          ? RootPackageDetailMeta.fromJson(json['meta'])
          : null,
    );
  }
}