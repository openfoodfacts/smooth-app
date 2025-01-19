part of 'newsfeed_provider.dart';

/// Content from the JSON and converted to what's in "newsfeed_model.dart"

class _TagLineJSON {
  _TagLineJSON.fromJson(Map<dynamic, dynamic> json)
      : news = (json['news'] as Map<dynamic, dynamic>).map(
          (dynamic id, dynamic value) => MapEntry<String, _TagLineItemNewsItem>(
            id,
            _TagLineItemNewsItem.fromJson(id, value),
          ),
        ),
        taglineFeed = _TaglineJSONFeed.fromJson(json['tagline_feed']);

  final _TagLineJSONNewsList news;
  final _TaglineJSONFeed taglineFeed;

  Future<AppNews> toTagLine(
    String locale,
    String appVersion,
    int appLaunches,
  ) async {
    final Map<String, AppNewsItem> tagLineNews = _getAppNewsItem(
      locale,
      appVersion,
      appLaunches,
    );

    final _TagLineJSONFeedLocale localizedFeed = taglineFeed.loadNews(locale);
    final Iterable<AppNewsFeedItem> feed =
        _getAppNewsFeedItems(localizedFeed, locale);

    return AppNews(
      news: AppNewsList(tagLineNews),
      feed: AppNewsFeed(
        feed.toList(growable: false),
      ),
    );
  }

  Map<String, AppNewsItem> _getAppNewsItem(
    String locale,
    String appVersion,
    int appLaunches,
  ) {
    final Map<String, AppNewsItem> tagLineNews = news.map(
      (String key, _TagLineItemNewsItem value) => MapEntry<String, AppNewsItem>(
        key,
        value.toTagLineItem(locale),
      ),
    );
    final Iterable<AppNewsItem> values =
        List<AppNewsItem>.of(tagLineNews.values);

    final int? appVersionNumber = _extractVersionNumber(appVersion);

    for (final AppNewsItem item in values) {
      if (item.minLaunches != null && appLaunches < item.minLaunches!) {
        tagLineNews.remove(item.id);
        continue;
      }

      if (item.minAppVersion != null) {
        final int? minVersionNumber = _extractVersionNumber(item.minAppVersion);

        if (minVersionNumber != null && appVersionNumber != null) {
          if (appVersionNumber < minVersionNumber) {
            tagLineNews.remove(item.id);
            continue;
          }
        }
      }
      if (item.maxAppVersion != null) {
        final int? maxVersionNumber = _extractVersionNumber(item.maxAppVersion);

        if (maxVersionNumber != null && appVersionNumber != null) {
          if (appVersionNumber > maxVersionNumber) {
            tagLineNews.remove(item.id);
            continue;
          }
        }
      }
    }
    return tagLineNews;
  }

  Iterable<AppNewsFeedItem> _getAppNewsFeedItems(
      _TagLineJSONFeedLocale localizedFeed, String locale) {
    final Iterable<AppNewsFeedItem> feed = localizedFeed.news
        .map((_TagLineJSONFeedLocaleItem item) {
          if (news[item.id] == null) {
            // The asked ID doesn't exist in the news
            return null;
          }
          return item.overrideNewsItem(news[item.id]!, locale);
        })
        .where((AppNewsFeedItem? item) =>
            item != null &&
            (item.startDate == null ||
                item.startDate!.isBefore(DateTime.now())) &&
            (item.endDate == null || item.endDate!.isAfter(DateTime.now())))
        .nonNulls;
    return feed;
  }

  int? _extractVersionNumber(String? version) {
    if (version == null) {
      return null;
    }
    return int.tryParse(version.replaceAll(r'.', '').trim());
  }
}

typedef _TagLineJSONNewsList = Map<String, _TagLineItemNewsItem>;

class _TagLineItemNewsItem {
  const _TagLineItemNewsItem._({
    required this.id,
    required this.url,
    required _TagLineItemNewsTranslations translations,
    this.minLaunches,
    this.startDate,
    this.endDate,
    this.minVersion,
    this.maxVersion,
    this.style,
  }) : _translations = translations;

  _TagLineItemNewsItem.fromJson(this.id, Map<dynamic, dynamic> json)
      : assert((json['url'] as String).isNotEmpty),
        url = json['url'],
        assert((json['translations'] as Map<dynamic, dynamic>)
            .containsKey('default')),
        _translations = (json['translations'] as Map<dynamic, dynamic>)
            .map((dynamic key, dynamic value) {
          if (key == 'default') {
            return MapEntry<String, _TagLineItemNewsTranslation>(
                key, _TagLineItemNewsTranslationDefault.fromJson(value));
          } else {
            return MapEntry<String, _TagLineItemNewsTranslation>(
              key,
              _TagLineItemNewsTranslation.fromJson(value),
            );
          }
        }),
        minLaunches = json['min_launches'] is int ? json['min_launches'] : null,
        startDate = DateTime.tryParse(json['start_date']),
        endDate = DateTime.tryParse(json['end_date']),
        minVersion = json['min_version'],
        maxVersion = json['max_version'],
        style = json['style'] == null
            ? null
            : _TagLineNewsStyle.fromJson(json['style']);

  final String id;
  final String url;
  final int? minLaunches;
  final _TagLineItemNewsTranslations _translations;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? minVersion;
  final String? maxVersion;
  final _TagLineNewsStyle? style;

  _TagLineItemNewsTranslation loadTranslation(String locale) {
    _TagLineItemNewsTranslation? translation;
    // Direct match
    if (_translations.containsKey(locale)) {
      translation = _translations[locale];
    } else if (locale.contains('_')) {
      final List<String> splittedLocale = locale.split('_');
      final String languageCode = splittedLocale.first;
      final String countryCode = '_${splittedLocale.last}';
      if (_translations.containsKey(languageCode)) {
        translation = _translations[languageCode];
      } else if (_translations.containsKey(countryCode)) {
        translation = _translations[countryCode];
      }
    }

    return _translations['default']!.merge(translation);
  }

  AppNewsItem toTagLineItem(String locale) {
    final _TagLineItemNewsTranslation translation = loadTranslation(locale);
    // We can assume the default translation has a non-null title and message
    return AppNewsItem(
      id: id,
      title: translation.title!,
      message: translation.message!,
      url: translation.url ?? url,
      buttonLabel: translation.buttonLabel,
      minLaunches: minLaunches,
      startDate: startDate,
      endDate: endDate,
      minAppVersion: minVersion,
      maxAppVersion: maxVersion,
      style: style?.toTagLineStyle(),
      image: translation.image?.overridesContent == true
          ? translation.image?.toTagLineImage()
          : null,
    );
  }

  _TagLineItemNewsItem copyWith({
    String? url,
    _TagLineItemNewsTranslations? translations,
    int? minLaunches,
    DateTime? startDate,
    DateTime? endDate,
    String? minVersion,
    String? maxVersion,
    _TagLineNewsStyle? style,
  }) {
    return _TagLineItemNewsItem._(
      id: id,
      // Still the same
      url: url ?? this.url,
      translations: translations ?? _translations,
      minLaunches: minLaunches ?? this.minLaunches,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minVersion: minVersion ?? this.minVersion,
      maxVersion: maxVersion ?? this.maxVersion,
      style: style ?? this.style,
    );
  }
}

typedef _TagLineItemNewsTranslations = Map<String, _TagLineItemNewsTranslation>;

class _TagLineItemNewsTranslation {
  _TagLineItemNewsTranslation._({
    this.title,
    this.message,
    this.url,
    this.buttonLabel,
    this.image,
  });

  _TagLineItemNewsTranslation.fromJson(Map<dynamic, dynamic> json)
      : assert(json['title'] == null || (json['title'] as String).isNotEmpty),
        assert(
            json['message'] == null || (json['message'] as String).isNotEmpty),
        assert(json['url'] == null || (json['url'] as String).isNotEmpty),
        assert(json['button_label'] == null ||
            (json['button_label'] as String).isNotEmpty),
        title = json['title'],
        message = json['message'],
        url = json['url'],
        buttonLabel = json['button_label'],
        image = json['image'] == null
            ? null
            : _TagLineNewsImage.fromJson(json['image']);
  final String? title;
  final String? message;
  final String? url;
  final String? buttonLabel;
  final _TagLineNewsImage? image;

  _TagLineItemNewsTranslation copyWith({
    String? title,
    String? message,
    String? url,
    String? buttonLabel,
    _TagLineNewsImage? image,
  }) {
    return _TagLineItemNewsTranslation._(
      title: title ?? this.title,
      message: message ?? this.message,
      url: url ?? this.url,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      image: image ?? this.image,
    );
  }

  _TagLineItemNewsTranslation merge(_TagLineItemNewsTranslation? other) {
    if (other == null) {
      return this;
    }

    return copyWith(
      title: other.title,
      message: other.message,
      url: other.url,
      buttonLabel: other.buttonLabel,
      image: other.image,
    );
  }
}

class _TagLineItemNewsTranslationDefault extends _TagLineItemNewsTranslation {
  _TagLineItemNewsTranslationDefault.fromJson(super.json)
      : assert((json['title'] as String).isNotEmpty),
        assert((json['message'] as String).isNotEmpty),
        assert(json['image'] == null ||
            ((json['image'] as Map<String, dynamic>)['url'] as String)
                .isNotEmpty),
        super.fromJson();
}

class _TagLineNewsImage {
  _TagLineNewsImage.fromJson(Map<dynamic, dynamic> json)
      : assert(json['width'] == null ||
            ((json['width'] as num) >= 0.0 && (json['width'] as num) <= 1.0)),
        assert(json['alt'] == null || (json['alt'] as String).isNotEmpty),
        url = json['url'],
        width = json['width'],
        alt = json['alt'];

  final String? url;
  final double? width;
  final String? alt;

  AppNewsImage toTagLineImage() {
    return AppNewsImage(
      src: url,
      width: width,
      alt: alt,
    );
  }

  bool get overridesContent => url != null || width != null || alt != null;
}

class _TagLineNewsStyle {
  _TagLineNewsStyle._({
    this.titleBackground,
    this.titleTextColor,
    this.titleIndicatorColor,
    this.messageBackground,
    this.messageTextColor,
    this.buttonBackground,
    this.buttonTextColor,
    this.contentBackgroundColor,
  });

  _TagLineNewsStyle.fromJson(Map<dynamic, dynamic> json)
      : assert(json['title_background'] == null ||
            (json['title_background'] as String).startsWith('#')),
        assert(json['title_text_color'] == null ||
            (json['title_text_color'] as String).startsWith('#')),
        assert(json['title_indicator_color'] == null ||
            (json['title_indicator_color'] as String).startsWith('#')),
        assert(json['message_background'] == null ||
            (json['message_background'] as String).startsWith('#')),
        assert(json['message_text_color'] == null ||
            (json['message_text_color'] as String).startsWith('#')),
        assert(json['button_background'] == null ||
            (json['button_background'] as String).startsWith('#')),
        assert(json['button_text_color'] == null ||
            (json['button_text_color'] as String).startsWith('#')),
        assert(json['content_background_color'] == null ||
            (json['content_background_color'] as String).startsWith('#')),
        titleBackground = json['title_background'],
        titleTextColor = json['title_text_color'],
        titleIndicatorColor = json['title_indicator_color'],
        messageBackground = json['message_background'],
        messageTextColor = json['message_text_color'],
        buttonBackground = json['button_background'],
        buttonTextColor = json['button_text_color'],
        contentBackgroundColor = json['content_background_color'];

  final String? titleBackground;
  final String? titleTextColor;
  final String? titleIndicatorColor;
  final String? messageBackground;
  final String? messageTextColor;
  final String? buttonBackground;
  final String? buttonTextColor;
  final String? contentBackgroundColor;

  _TagLineNewsStyle copyWith({
    String? titleBackground,
    String? titleTextColor,
    String? titleIndicatorColor,
    String? messageBackground,
    String? messageTextColor,
    String? buttonBackground,
    String? buttonTextColor,
    String? contentBackgroundColor,
  }) {
    return _TagLineNewsStyle._(
      titleBackground: titleBackground ?? this.titleBackground,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      titleIndicatorColor: titleIndicatorColor ?? this.titleIndicatorColor,
      messageBackground: messageBackground ?? this.messageBackground,
      messageTextColor: messageTextColor ?? this.messageTextColor,
      buttonBackground: buttonBackground ?? this.buttonBackground,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      contentBackgroundColor:
          contentBackgroundColor ?? this.contentBackgroundColor,
    );
  }

  AppNewsStyle toTagLineStyle() => AppNewsStyle.fromHex(
        titleBackground: titleBackground,
        titleTextColor: titleTextColor,
        titleIndicatorColor: titleIndicatorColor,
        messageBackground: messageBackground,
        messageTextColor: messageTextColor,
        buttonBackground: buttonBackground,
        buttonTextColor: buttonTextColor,
        contentBackgroundColor: contentBackgroundColor,
      );
}

class _TaglineJSONFeed {
  _TaglineJSONFeed.fromJson(Map<dynamic, dynamic> json)
      : assert(json.containsKey('default')),
        _news = json.map(
          (dynamic key, dynamic value) =>
              MapEntry<String, _TagLineJSONFeedLocale>(
            key,
            _TagLineJSONFeedLocale.fromJson(value),
          ),
        );

  final _TagLineJSONFeedList _news;

  _TagLineJSONFeedLocale loadNews(String locale) {
    // Direct match
    if (_news.containsKey(locale)) {
      return _news[locale]!;
    }

    // Try by language
    if (locale.contains('_')) {
      final List<String> splittedLocale = locale.split('_');
      final String languageCode = splittedLocale.first;
      final String countryCode = '_${splittedLocale.last}';
      if (_news.containsKey(languageCode)) {
        return _news[languageCode]!;
      } else if (_news.containsKey(countryCode)) {
        return _news[countryCode]!;
      }
    }

    return _news['default']!;
  }
}

typedef _TagLineJSONFeedList = Map<String, _TagLineJSONFeedLocale>;

class _TagLineJSONFeedLocale {
  _TagLineJSONFeedLocale.fromJson(Map<dynamic, dynamic> json)
      : assert(json['news'] is Iterable<dynamic>),
        news = (json['news'] as Iterable<dynamic>)
            .map((dynamic json) => _TagLineJSONFeedLocaleItem.fromJson(json));

  final Iterable<_TagLineJSONFeedLocaleItem> news;
}

class _TagLineJSONFeedLocaleItem {
  _TagLineJSONFeedLocaleItem.fromJson(Map<dynamic, dynamic> json)
      : assert((json['id'] as String).isNotEmpty),
        id = json['id'],
        overrideContent = json['override'] != null
            ? _TagLineJSONFeedNewsItemOverride.fromJson(
                json['override'] as Map<dynamic, dynamic>)
            : null;

  final String id;
  final _TagLineJSONFeedNewsItemOverride? overrideContent;

  AppNewsFeedItem overrideNewsItem(
    _TagLineItemNewsItem newsItem,
    String locale,
  ) {
    _TagLineItemNewsItem item = newsItem;

    if (overrideContent != null) {
      item = newsItem.copyWith(
        url: overrideContent!.url ?? newsItem.url,
        startDate: overrideContent!.startDate ?? newsItem.startDate,
        endDate: overrideContent!.endDate ?? newsItem.endDate,
        style: overrideContent!.style ?? newsItem.style,
      );
    }

    final AppNewsItem tagLineItem = item.toTagLineItem(locale);

    return AppNewsFeedItem(
      news: tagLineItem,
      startDate: tagLineItem.startDate,
      endDate: tagLineItem.endDate,
    );
  }
}

class _TagLineJSONFeedNewsItemOverride {
  _TagLineJSONFeedNewsItemOverride.fromJson(Map<dynamic, dynamic> json)
      : assert(json['url'] == null || (json['url'] as String).isNotEmpty),
        url = json['url'],
        startDate = json['start_date'] != null
            ? DateTime.tryParse(json['start_date'])
            : null,
        endDate = json['end_date'] != null
            ? DateTime.tryParse(json['end_date'])
            : null,
        style = json['style'] == null
            ? null
            : _TagLineNewsStyle.fromJson(json['style']);

  final String? url;
  final DateTime? startDate;
  final DateTime? endDate;
  final _TagLineNewsStyle? style;
}
