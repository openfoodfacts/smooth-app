import 'dart:ui';

class AppNews {
  const AppNews({required this.news, required this.feed});

  final AppNewsList news;
  final AppNewsFeed feed;

  bool get hasContent => news._news.isNotEmpty && feed.news.isNotEmpty;

  AppNewsItem? get donation {
    for (final AppNewsFeedItem item in feed.news) {
      if (item.news.isDonation) {
        return item.news;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'AppNews{news: $news, feed: $feed}';
  }
}

class AppNewsList {
  const AppNewsList(Map<String, AppNewsItem> news) : _news = news;

  final Map<String, AppNewsItem> _news;

  AppNewsItem? operator [](String key) => _news[key];

  @override
  String toString() {
    return 'AppNewsList{_news: $_news}';
  }
}

class AppNewsItem {
  const AppNewsItem({
    required this.id,
    required this.title,
    required this.message,
    required this.url,
    this.buttonLabel,
    this.minLaunches,
    this.startDate,
    this.endDate,
    this.minAppVersion,
    this.maxAppVersion,
    this.image,
    this.darkImage,
    this.style,
    this.raised,
    this.goal,
    this.currency,
    this.donationAmounts,
    this.donationScansPerUnit,
    this.donationWhereItGoes,
  });

  final String id;
  final String title;
  final String message;
  final String url;
  final String? buttonLabel;
  final int? minLaunches;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? minAppVersion;
  final String? maxAppVersion;
  final AppNewsImage? image;
  final AppNewsImage? darkImage;
  final AppNewsStyle? style;
  final num? raised;
  final num? goal;
  final String? currency;
  final List<int>? donationAmounts;
  final int? donationScansPerUnit;
  final List<String>? donationWhereItGoes;

  AppNewsFunding? get funding => AppNewsFunding.tryFrom(raised, goal, currency);

  bool get isDonation => id.toLowerCase().startsWith('donation');

  int? get monthsLeft {
    final DateTime? end = endDate;
    if (end == null) {
      return null;
    }

    final int days = end.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : (days / (365 / 12)).round();
  }

  @override
  String toString() {
    return 'AppNewsItem'
        '(id:$id'
        ',title:$title'
        ',message:$message'
        ',url:$url'
        ',buttonLabel:$buttonLabel'
        ',minLaunches:$minLaunches'
        ',startDate:$startDate'
        ',endDate:$endDate'
        ',minAppVersion:$minAppVersion'
        ',maxAppVersion:$maxAppVersion'
        ',image:$image'
        ',darkImage:$darkImage'
        ',style:$style'
        ',raised:$raised'
        ',goal:$goal'
        ',currency:$currency'
        ',donationAmounts:$donationAmounts'
        ',donationScansPerUnit:$donationScansPerUnit'
        ',donationWhereItGoes:$donationWhereItGoes)';
  }
}

class AppNewsFunding {
  const AppNewsFunding._({
    required this.raised,
    required this.goal,
    required this.currency,
  });

  final num raised;
  final num goal;
  final String currency;

  static AppNewsFunding? tryFrom(num? raised, num? goal, String? currency) {
    if (raised == null || goal == null || currency == null) {
      return null;
    }
    if (!raised.isFinite || !goal.isFinite || raised < 0.0 || goal <= 0.0) {
      return null;
    }
    if (currency.length != 3) {
      return null;
    }
    return AppNewsFunding._(raised: raised, goal: goal, currency: currency);
  }

  double get ratio => raised / goal;

  double get progress => ratio.clamp(0.0, 1.0);

  num get shortfall => goal - raised;

  @override
  String toString() {
    return 'AppNewsFunding'
        '(raised:$raised'
        ',goal:$goal'
        ',currency:$currency)';
  }
}

class AppNewsStyle {
  const AppNewsStyle({
    this.titleBackground,
    this.titleTextColor,
    this.titleIndicatorColor,
    this.messageBackground,
    this.messageTextColor,
    this.buttonBackground,
    this.buttonTextColor,
    this.contentBackgroundColor,
  });

  AppNewsStyle.fromHex({
    String? titleBackground,
    String? titleTextColor,
    String? titleIndicatorColor,
    String? messageBackground,
    String? messageTextColor,
    String? buttonBackground,
    String? buttonTextColor,
    String? contentBackgroundColor,
  }) : titleBackground = _parseColor(titleBackground),
       titleTextColor = _parseColor(titleTextColor),
       titleIndicatorColor = _parseColor(titleIndicatorColor),
       messageBackground = _parseColor(messageBackground),
       messageTextColor = _parseColor(messageTextColor),
       buttonBackground = _parseColor(buttonBackground),
       buttonTextColor = _parseColor(buttonTextColor),
       contentBackgroundColor = _parseColor(contentBackgroundColor);

  final Color? titleBackground;
  final Color? titleTextColor;
  final Color? titleIndicatorColor;
  final Color? messageBackground;
  final Color? messageTextColor;
  final Color? buttonBackground;
  final Color? buttonTextColor;
  final Color? contentBackgroundColor;

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.length != 7) {
      return null;
    }
    final int? rgb = int.tryParse(hex.substring(1), radix: 16);
    return rgb == null ? null : Color(0xFF000000 | rgb);
  }

  @override
  String toString() {
    return 'AppNewsStyle{titleBackground: $titleBackground, titleTextColor: $titleTextColor, titleIndicatorColor: $titleIndicatorColor, messageBackground: $messageBackground, messageTextColor: $messageTextColor, buttonBackground: $buttonBackground, buttonTextColor: $buttonTextColor, contentBackgroundColor: $contentBackgroundColor}';
  }
}

class AppNewsImage {
  const AppNewsImage({required this.src, this.width, this.alt});

  final String? src;
  final double? width;
  final String? alt;

  @override
  String toString() {
    return 'AppNewsImage{src: $src, width: $width, alt: $alt}';
  }
}

class AppNewsFeed {
  const AppNewsFeed(this.news);

  final List<AppNewsFeedItem> news;

  bool get isNotEmpty => news.isNotEmpty;

  @override
  String toString() {
    return 'TagLineFeed{news: $news}';
  }
}

class AppNewsFeedItem {
  const AppNewsFeedItem({required this.news, this._startDate, this._endDate});

  final AppNewsItem news;
  final DateTime? _startDate;
  final DateTime? _endDate;

  String get id => news.id;

  DateTime? get startDate => _startDate ?? news.startDate;

  DateTime? get endDate => _endDate ?? news.endDate;

  @override
  String toString() {
    return 'AppNewsFeedItem{news: $news, _startDate: $_startDate, _endDate: $_endDate}';
  }
}
