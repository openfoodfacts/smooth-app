class ContributorsModel {
  ContributorsModel({required this.avatarUrl, required this.profilePath});

  ContributorsModel.fromJson(Map<String, dynamic> json)
      : profilePath = json['html_url'] as String,
        avatarUrl = json['avatar_url'] as String;

  final String avatarUrl;
  final String profilePath;
}
