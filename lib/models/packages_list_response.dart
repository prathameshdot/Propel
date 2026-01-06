class PackagesListResponse {
  final bool status;
  final int code;
  final dynamic message;
  final PackagesData? data;

  PackagesListResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory PackagesListResponse.fromJson(Map<String, dynamic> json) {
    return PackagesListResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? PackagesData.fromJson(json['data']) : null,
    );
  }
}

class PackagesData {
  final List<Package> packages;

  PackagesData({required this.packages});

  factory PackagesData.fromJson(Map<String, dynamic> json) {
    return PackagesData(
      packages:
          (json['packages'] as List<dynamic>?)
              ?.map((e) => Package.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Package {
  final int id;
  final String price;
  final String? directPercentage;
  final bool? matchingEligible;
  final String createdAt;
  final String updatedAt;

  Package({
    required this.id,
    required this.price,
    this.directPercentage,
    this.matchingEligible,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? 0,
      price: json['price'] ?? '',
      directPercentage: json['direct_percentage'],
      matchingEligible: json['matching_eligible'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
