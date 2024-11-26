import 'dart:ui';

class AppNews {
  const AppNews({
    required this.news,
    required this.feed,
  });

  final AppNewsList news;
  final AppNewsFeed feed;

  bool get hasContent => news._news.isNotEmpty && feed.news.isNotEmpty;

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
    this.startDate,
    this.endDate,
    this.minAppVersion,
    this.maxAppVersion,
    this.image,
    this.style,
  });

  final String id;
  final String title;
  final String message;
  final String url;
  final String? buttonLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? minAppVersion;
  final String? maxAppVersion;
  final AppNewsImage? image;
  final AppNewsStyle? style;

  @override
  String toString() {
    return 'AppNewsItem{id: $id, title: $title, message: $message, url: $url, buttonLabel: $buttonLabel, startDate: $startDate, endDate: $endDate, minAppVersion: $minAppVersion, maxAppVersion: $maxAppVersion, image: $image, style: $style}';
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
  })  : titleBackground = _parseColor(titleBackground),
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
    return Color(int.parse(hex.substring(1), radix: 16));
  }

  @override
  String toString() {
    return 'AppNewsStyle{titleBackground: $titleBackground, titleTextColor: $titleTextColor, titleIndicatorColor: $titleIndicatorColor, messageBackground: $messageBackground, messageTextColor: $messageTextColor, buttonBackground: $buttonBackground, buttonTextColor: $buttonTextColor, contentBackgroundColor: $contentBackgroundColor}';
  }
}

class AppNewsImage {
  const AppNewsImage({
    required this.src,
    this.width,
    this.alt,
  });

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
  const AppNewsFeedItem({
    required this.news,
    DateTime? startDate,
    DateTime? endDate,
  })  : _startDate = startDate,
        _endDate = endDate;

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
