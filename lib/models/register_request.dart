class RegisterRequest {
  final String fullName;
  final String mobile;
  final String email;
  final String password;
  final String referralCode;
  final String? position; // 'left' or 'right'
  final int?
  subTeamId; // ID of the selected user in that position (sub_team_id)

  RegisterRequest({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.password,
    required this.referralCode,
    this.position,
    this.subTeamId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'mobile': mobile,
      'email': email,
      'password': password,
      'referrel_code':
          referralCode, // Note: API has 'referrel_code' with double 'r'
      // If no referral code is provided, send empty position to match API example
      'position': referralCode.trim().isNotEmpty ? (position ?? '') : '',
    };

    // Only include sub_team_id when a referral code is provided and subTeamId is set
    if (subTeamId != null && referralCode.trim().isNotEmpty) {
      data['sub_team_id'] = subTeamId;
    }

    return data;
  }
}
