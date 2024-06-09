import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/tagline/tagline_model.dart';
import 'package:smooth_app/data_models/tagline/tagline_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/helpers/strings_helper.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ScanTagLine extends StatelessWidget {
  const ScanTagLine({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_ScanTagLineProvider>(
      create: (BuildContext context) => _ScanTagLineProvider(context),
      child: Consumer<_ScanTagLineProvider>(
        builder: (
          BuildContext context,
          _ScanTagLineProvider scanTagLineProvider,
          Widget? child,
        ) {
          final _ScanTagLineState state = scanTagLineProvider.value;

          return switch (state) {
            _ScanTagLineStateLoading() => const _ScanTagLineLoading(),
            _ScanTagLineStateNoContent() => EMPTY_WIDGET,
            _ScanTagLineStateLoaded() => _ScanTagLineContent(
                news: state.tagLine,
              ),
          };
        },
      ),
    );
  }
}

class _ScanTagLineLoading extends StatelessWidget {
  const _ScanTagLineLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context)
          .extension<SmoothColorsThemeExtension>()!
          .primaryMedium,
      highlightColor: Colors.white,
      child: const SmoothCard(
        child: SizedBox(
          width: double.infinity,
          height: 200.0,
        ),
      ),
    );
  }
}

class _ScanTagLineContent extends StatefulWidget {
  const _ScanTagLineContent({
    required this.news,
  });

  final Iterable<TagLineNewsItem> news;

  @override
  State<_ScanTagLineContent> createState() => _ScanTagLineContentState();
}

class _ScanTagLineContentState extends State<_ScanTagLineContent> {
  Timer? _timer;
  int _index = -1;

  @override
  void initState() {
    super.initState();
    _rotateNews();
  }

  void _rotateNews() {
    _timer?.cancel();

    _index++;
    if (_index >= widget.news.length) {
      _index = 0;
    }

    _timer = Timer(const Duration(minutes: 30), () => _rotateNews());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final TagLineNewsItem currentNews = widget.news.elementAt(_index);

    // Default values seem weird
    const Radius radius = Radius.circular(16.0);

    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: currentNews.style?.titleBackground ??
                (themeProvider.isLightTheme
                    ? theme.primarySemiDark
                    : theme.primaryBlack),
            borderRadius: const BorderRadiusDirectional.only(
              topStart: radius,
              topEnd: radius,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: VERY_SMALL_SPACE,
              horizontal: MEDIUM_SPACE,
            ),
            child: _TagLineContentTitle(
              title: currentNews.title,
              backgroundColor: currentNews.style?.titleBackground,
              indicatorColor: currentNews.style?.titleIndicatorColor,
              titleColor: currentNews.style?.titleTextColor,
            ),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: currentNews.style?.contentBackgroundColor ??
                  (themeProvider.isLightTheme
                      ? theme.primaryMedium
                      : theme.primaryDark),
              borderRadius: const BorderRadiusDirectional.only(
                bottomStart: radius,
                bottomEnd: radius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: SMALL_SPACE,
                horizontal: MEDIUM_SPACE,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: _TagLineContentBody(
                      message: currentNews.message,
                      textColor: currentNews.style?.messageTextColor,
                      image: currentNews.image,
                    ),
                  ),
                  const SizedBox(height: SMALL_SPACE),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: _TagLineContentButton(
                      link: currentNews.url,
                      label: currentNews.buttonLabel,
                      backgroundColor: currentNews.style?.buttonBackground,
                      foregroundColor: currentNews.style?.buttonTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _TagLineContentTitle extends StatelessWidget {
  const _TagLineContentTitle({
    required this.title,
    this.backgroundColor,
    this.indicatorColor,
    this.titleColor,
  });

  final String title;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 30.0),
      child: Row(
        children: <Widget>[
          SizedBox.square(
            dimension: 11.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: indicatorColor ?? theme.secondaryLight,
                borderRadius: const BorderRadius.all(ROUNDED_RADIUS),
              ),
            ),
          ),
          const SizedBox(width: SMALL_SPACE),
          Expanded(
              child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: titleColor ?? Colors.white,
            ),
          ))
        ],
      ),
    );
  }
}

class _TagLineContentBody extends StatelessWidget {
  const _TagLineContentBody({
    required this.message,
    this.textColor,
    this.image,
  });

  final String message;
  final Color? textColor;
  final TagLineImage? image;

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    final Widget text = FormattedText(
      text: message,
      textStyle: TextStyle(
        color: textColor ??
            (themeProvider.isLightTheme
                ? theme.primarySemiDark
                : theme.primaryLight),
      ),
    );

    if (image == null) {
      return text;
    }

    final int imageFlex = ((image!.width ?? 0.2) * 10).toInt();
    return Row(
      children: <Widget>[
        Expanded(
          flex: imageFlex,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.06,
            ),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: _image(),
            ),
          ),
        ),
        const SizedBox(width: MEDIUM_SPACE),
        Expanded(
          flex: 10 - imageFlex,
          child: text,
        ),
      ],
    );
  }

  Widget _image() {
    if (image!.src.endsWith('svg')) {
      return SvgCache(
        image!.src,
        semanticsLabel: image!.alt,
      );
    } else {
      return Image.network(
        semanticLabel: image!.alt,
        image!.src,
      );
    }
  }
}

class _TagLineContentButton extends StatelessWidget {
  const _TagLineContentButton({
    required this.link,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String link;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.primaryBlack,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: VERY_SMALL_SPACE,
          horizontal: MEDIUM_SPACE,
        ),
        minimumSize: const Size(0, 20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label ?? localizations.tagline_feed_news_button),
          const SizedBox(width: MEDIUM_SPACE),
          const Arrow.right(
            size: 12.0,
          ),
        ],
      ),
      onPressed: () => LaunchUrlHelper.launchURL(link),
    );
  }
}

/// Listen to [TagLineProvider] feed and provide a list of [TagLineNewsItem]
/// randomly sorted by unread, then displayed and clicked news.
class _ScanTagLineProvider extends ValueNotifier<_ScanTagLineState> {
  _ScanTagLineProvider(BuildContext context)
      : _tagLineProvider = context.read<TagLineProvider>(),
        _userPreferences = context.read<UserPreferences>(),
        super(const _ScanTagLineStateLoading()) {
    _tagLineProvider.addListener(_onTagLineStateChanged);
    // Refresh with the current state
    _onTagLineStateChanged();
  }

  final TagLineProvider _tagLineProvider;
  final UserPreferences _userPreferences;

  void _onTagLineStateChanged() {
    switch (_tagLineProvider.state) {
      case TagLineLoading():
        emit(const _ScanTagLineStateLoading());
      case TagLineError():
        emit(const _ScanTagLineStateNoContent());
      case TagLineLoaded():
        _onTagLineContentAvailable(
            (_tagLineProvider.state as TagLineLoaded).tagLineContent);
    }
  }

  Future<void> _onTagLineContentAvailable(TagLine tagLine) async {
    if (!tagLine.feed.isNotEmpty) {
      emit(const _ScanTagLineStateNoContent());
      return;
    }

    final List<TagLineNewsItem> unreadNews = <TagLineNewsItem>[];
    final List<TagLineNewsItem> displayedNews = <TagLineNewsItem>[];
    final List<TagLineNewsItem> clickedNews = <TagLineNewsItem>[];

    final List<String> taglineFeedAlreadyClickedNews =
        _userPreferences.taglineFeedClickedNews;
    final List<String> taglineFeedAlreadyDisplayedNews =
        _userPreferences.taglineFeedDisplayedNews;

    for (final TagLineFeedItem feedItem in tagLine.feed.news) {
      if (taglineFeedAlreadyClickedNews.contains(feedItem.id)) {
        clickedNews.add(feedItem.news);
      } else if (taglineFeedAlreadyDisplayedNews.contains(feedItem.id)) {
        displayedNews.add(feedItem.news);
      } else {
        unreadNews.add(feedItem.news);
      }
    }

    emit(
      _ScanTagLineStateLoaded(
        <TagLineNewsItem>[
          ...unreadNews..shuffle(),
          ...displayedNews..shuffle(),
          ...clickedNews..shuffle(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tagLineProvider.removeListener(_onTagLineStateChanged);
    super.dispose();
  }
}

sealed class _ScanTagLineState {
  const _ScanTagLineState();
}

class _ScanTagLineStateLoading extends _ScanTagLineState {
  const _ScanTagLineStateLoading();
}

class _ScanTagLineStateNoContent extends _ScanTagLineState {
  const _ScanTagLineStateNoContent();
}

class _ScanTagLineStateLoaded extends _ScanTagLineState {
  const _ScanTagLineStateLoaded(this.tagLine);

  final Iterable<TagLineNewsItem> tagLine;
}
