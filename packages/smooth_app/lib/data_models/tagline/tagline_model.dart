import 'dart:ui';

class TagLine {
  const TagLine({
    required this.news,
    required this.feed,
  });

  final TagLineNewsList news;
  final TagLineFeed feed;

  @override
  String toString() {
    return 'TagLine{news: $news, feed: $feed}';
  }
}

class TagLineNewsList {
  const TagLineNewsList(Map<String, TagLineNewsItem> news) : _news = news;

  final Map<String, TagLineNewsItem> _news;

  TagLineNewsItem? operator [](String key) => _news[key];

  @override
  String toString() {
    return 'TagLineNewsList{_news: $_news}';
  }
}

class TagLineNewsItem {
  const TagLineNewsItem({
    required this.title,
    required this.message,
    required this.url,
    this.buttonLabel,
    this.startDate,
    this.endDate,
    this.image,
    this.style,
  });

  final String title;
  final String message;
  final String url;
  final String? buttonLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final TagLineImage? image;
  final TagLineStyle? style;

  @override
  String toString() {
    return 'TagLineNewsItem{title: $title, message: $message, url: $url, buttonLabel: $buttonLabel, startDate: $startDate, endDate: $endDate, image: $image, style: $style}';
  }
}

class TagLineStyle {
  const TagLineStyle({
    this.titleBackground,
    this.titleTextColor,
    this.messageBackground,
    this.messageTextColor,
    this.buttonBackground,
    this.buttonTextColor,
  });

  TagLineStyle.fromHexa({
    String? titleBackground,
    String? titleTextColor,
    String? messageBackground,
    String? messageTextColor,
    String? buttonBackground,
    String? buttonTextColor,
  })  : titleBackground = _parseColor(titleBackground),
        titleTextColor = _parseColor(titleTextColor),
        messageBackground = _parseColor(messageBackground),
        messageTextColor = _parseColor(messageTextColor),
        buttonBackground = _parseColor(buttonBackground),
        buttonTextColor = _parseColor(buttonTextColor);

  final Color? titleBackground;
  final Color? titleTextColor;
  final Color? messageBackground;
  final Color? messageTextColor;
  final Color? buttonBackground;
  final Color? buttonTextColor;

  static Color? _parseColor(String? hexa) {
    if (hexa == null || hexa.length != 7) {
      return null;
    }
    return Color(int.parse(hexa.substring(1), radix: 16));
  }

  @override
  String toString() {
    return 'TagLineStyle{titleBackground: $titleBackground, titleTextColor: $titleTextColor, messageBackground: $messageBackground, messageTextColor: $messageTextColor, buttonBackground: $buttonBackground, buttonTextColor: $buttonTextColor}';
  }
}

class TagLineImage {
  const TagLineImage({required this.src, this.width});

  final String src;
  final double? width;

  @override
  String toString() {
    return 'TagLineImage{src: $src, width: $width}';
  }
}

class TagLineFeed {
  const TagLineFeed(this.news);

  final List<TagLineFeedItem> news;

  @override
  String toString() {
    return 'TagLineFeed{news: $news}';
  }
}

class TagLineFeedItem {
  const TagLineFeedItem({
    required this.news,
    DateTime? startDate,
    DateTime? endDate,
  })  : _startDate = startDate,
        _endDate = endDate;

  final TagLineNewsItem news;
  final DateTime? _startDate;
  final DateTime? _endDate;

  DateTime? get startDate => _startDate ?? news.startDate;

  DateTime? get endDate => _endDate ?? news.endDate;

  @override
  String toString() {
    return 'TagLineFeedItem{news: $news, _startDate: $_startDate, _endDate: $_endDate}';
  }
}
