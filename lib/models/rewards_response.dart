class Reward {
  final int id;
  final String title;
  final String? icon;
  final String requiredMatchingBusiness;
  final String rewardValue;
  final String rewardType;

  Reward({
    required this.id,
    required this.title,
    this.icon,
    required this.requiredMatchingBusiness,
    required this.rewardValue,
    required this.rewardType,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'],
      requiredMatchingBusiness:
          json['required_matching_business']?.toString() ?? '0',
      rewardValue: json['reward_value']?.toString() ?? '0',
      rewardType: json['reward_type'] ?? '',
    );
  }
}

class RewardsResponse {
  final bool status;
  final int code;
  final dynamic message;
  final List<Reward> data;

  RewardsResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory RewardsResponse.fromJson(dynamic json) {
    final List<Reward> list = [];
    if (json is Map<String, dynamic>) {
      if (json['data'] is List) {
        list.addAll(
          (json['data'] as List).map(
            (e) => Reward.fromJson(e as Map<String, dynamic>),
          ),
        );
      }
      return RewardsResponse(
        status: json['status'] ?? false,
        code: json['code'] ?? 0,
        message: json['message'],
        data: list,
      );
    } else if (json is List) {
      list.addAll(json.map((e) => Reward.fromJson(e as Map<String, dynamic>)));
      return RewardsResponse(status: true, code: 200, message: '', data: list);
    }

    return RewardsResponse(
      status: false,
      code: 0,
      message: 'Invalid response',
      data: [],
    );
  }
}
