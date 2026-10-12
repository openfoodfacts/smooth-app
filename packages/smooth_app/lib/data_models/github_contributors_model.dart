class ContributorsModel {
  ContributorsModel({
    required this.avatarUrl,
    required this.profilePath,
    required this.login,
  });

  ContributorsModel.fromJson(Map<String, dynamic> json)
    : profilePath = json['html_url'].toString(),
      login = json['login'].toString(),
      avatarUrl = json['avatar_url'].toString();

  final String avatarUrl;
  final String profilePath;
  final String login;
}
