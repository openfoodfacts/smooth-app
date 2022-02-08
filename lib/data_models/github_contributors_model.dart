class ContributorsModel {
  ContributorsModel({required this.avatarUrl, required this.profilePath});

  ContributorsModel.fromJson(Map<String, dynamic> json)
      : profilePath = json['html_url'].toString(),
        avatarUrl = json['avatar_url'].toString();

  final String avatarUrl;
  final String profilePath;
}
