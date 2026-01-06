class UploadMasterImageResponse {
  final bool status;
  final dynamic message;
  final String imageUrl;

  UploadMasterImageResponse({
    required this.status,
    required this.message,
    required this.imageUrl,
  });

  factory UploadMasterImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadMasterImageResponse(
      status:
          json['status'] ??
          json['message'] != null, // Default to true if message exists
      message: json['message'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}
