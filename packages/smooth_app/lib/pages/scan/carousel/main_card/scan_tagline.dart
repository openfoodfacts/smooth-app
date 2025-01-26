import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_app_logo.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class ScanTagLine extends StatelessWidget {
  const ScanTagLine({required this.dense, super.key});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<_ScanNewsFeedProvider>(
          create: (BuildContext context) => _ScanNewsFeedProvider(context),
        ),
        Provider<_ScanTagLineDensity>(
          create: (_) =>
              dense ? _ScanTagLineDensity.dense : _ScanTagLineDensity.normal,
        ),
      ],
      child: Consumer<_ScanNewsFeedProvider>(
        builder: (
          BuildContext context,
          _ScanNewsFeedProvider scanTagLineProvider,
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

enum _ScanTagLineDensity {
  dense,
  normal,
}

class _ScanTagLineLoading extends StatelessWidget {
  const _ScanTagLineLoading();

  @override
  Widget build(BuildContext context) {
    final _ScanTagLineDensity density = context.read<_ScanTagLineDensity>();

    return Shimmer.fromColors(
      baseColor: context.extension<SmoothColorsThemeExtension>().primaryMedium,
      highlightColor: Colors.white,
      child: SmoothCard(
        margin: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          height:
              density == _ScanTagLineDensity.dense ? 200.0 : double.infinity,
        ),
      ),
    );
  }
}

class _ScanTagLineContent extends StatefulWidget {
  const _ScanTagLineContent({
    required this.news,
  });

  final Iterable<AppNewsItem> news;

  @override
  State<_ScanTagLineContent> createState() => _ScanTagLineContentState();
}

class _ScanTagLineContentState extends State<_ScanTagLineContent> {
  // Default values seem weird
  static const Radius radius = Radius.circular(16.0);

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
    final AppNewsItem currentNews = widget.news.elementAt(_index);

    final bool dense =
        context.read<_ScanTagLineDensity>() == _ScanTagLineDensity.dense;

    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: currentNews.style?.titleBackground ??
                (!themeProvider.isDarkMode(context)
                    ? theme.primarySemiDark
                    : theme.primaryBlack),
            borderRadius: const BorderRadiusDirectional.only(
              topStart: radius,
              topEnd: radius,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: dense ? LARGE_SPACE : MEDIUM_SPACE,
              end: dense ? MEDIUM_SPACE : BALANCED_SPACE,
              top: VERY_SMALL_SPACE,
              bottom: VERY_SMALL_SPACE,
            ),
            child: _TagLineContentTitle(
              title: currentNews.title,
              backgroundColor: currentNews.style?.titleBackground,
              indicatorColor: currentNews.style?.titleIndicatorColor,
              titleColor: currentNews.style?.titleTextColor,
              dense: dense,
            ),
          ),
        ),
        _buildCard(currentNews, themeProvider, context, theme, dense),
      ],
    );
  }

  Widget _buildCard(
    AppNewsItem currentNews,
    ThemeProvider themeProvider,
    BuildContext context,
    SmoothColorsThemeExtension theme,
    bool dense,
  ) {
    Widget body = _TagLineContentBody(
      message: currentNews.message,
      textColor: currentNews.style?.messageTextColor,
      image: currentNews.image,
      dense: dense,
    );

    if (!dense) {
      body = Expanded(child: body);
    }

    final Widget card = Material(
      type: MaterialType.card,
      color: currentNews.style?.contentBackgroundColor ??
          (!themeProvider.isDarkMode(context)
              ? theme.primaryMedium
              : theme.primaryDark),
      borderRadius: const BorderRadius.vertical(bottom: radius),
      child: InkWell(
        borderRadius: const BorderRadius.vertical(bottom: radius),
        onTap: () => LaunchUrlHelper.launchURLAndFollowDeepLinks(
          context,
          currentNews.url,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            vertical: dense ? 6.0 : SMALL_SPACE,
            horizontal: MEDIUM_SPACE,
          ),
          child: Column(
            children: <Widget>[
              body,
              SizedBox(height: dense ? VERY_SMALL_SPACE : SMALL_SPACE),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _TagLineContentButton(
                  label: currentNews.buttonLabel,
                  backgroundColor: currentNews.style?.buttonBackground,
                  foregroundColor: currentNews.style?.buttonTextColor,
                  dense: dense,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (dense) {
      return card;
    } else {
      return Expanded(child: card);
    }
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
    required this.dense,
    this.backgroundColor,
    this.indicatorColor,
    this.titleColor,
  });

  final String title;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? titleColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Semantics(
      label: localizations.scan_tagline_news_item_accessibility(title),
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: dense ? 28.0 : 30.0),
        child: Row(
          children: <Widget>[
            SizedBox.square(
              dimension: 11.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: indicatorColor ?? Colors.white,
                  borderRadius: const BorderRadius.all(ROUNDED_RADIUS),
                ),
              ),
            ),
            const SizedBox(width: BALANCED_SPACE),
            Expanded(
              child: AutoSizeText(
                title,
                maxLines: 1,
                minFontSize: 8.0,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: titleColor ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagLineContentBody extends StatefulWidget {
  const _TagLineContentBody({
    required this.message,
    required this.dense,
    this.textColor,
    this.image,
  });

  final String message;
  final bool dense;
  final Color? textColor;
  final AppNewsImage? image;

  @override
  State<_TagLineContentBody> createState() => _TagLineContentBodyState();
}

class _TagLineContentBodyState extends State<_TagLineContentBody> {
  bool _imageError = false;

  static const EdgeInsetsGeometry _contentPadding = EdgeInsetsDirectional.only(
    top: SMALL_SPACE,
    bottom: VERY_SMALL_SPACE,
  );

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    final Widget text = TextWithBoldParts(
      text: widget.message,

      /// We have to force a maxLines
      maxLines: widget.dense ? 500 : null,
      overflow: widget.dense ? TextOverflow.ellipsis : null,
      textStyle: TextStyle(
        color: widget.textColor ??
            (!themeProvider.isDarkMode(context)
                ? theme.primarySemiDark
                : theme.primaryLight),
        fontSize: 15.0,
      ),
    );

    if (widget.image == null || _imageError) {
      return Padding(
        padding: _contentPadding,
        child: text,
      );
    }

    final int imageFlex = ((widget.image!.width ?? 0.2) * 10).toInt();
    return Padding(
      padding: _contentPadding,
      child: Row(
        children: <Widget>[
          if (!_imageError) ...<Widget>[
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
            SizedBox(width: widget.dense ? SMALL_SPACE : MEDIUM_SPACE),
          ],
          Expanded(
            flex: 10 - imageFlex,
            child: text,
          ),
        ],
      ),
    );
  }

  Widget _image() {
    if (widget.image!.src?.endsWith('svg') == true) {
      return SvgCache(
        widget.image!.src,
        semanticsLabel: widget.image!.alt,
        loadingBuilder: (_) => _onLoading(),
        errorBuilder: (_, __) => _onError(),
      );
    } else {
      return Image.network(
        semanticLabel: widget.image!.alt,
        loadingBuilder: (
          _,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return _onLoading();
          }

          return child;
        },
        errorBuilder: (_, __, ___) => _onError(),
        widget.image!.src ?? '-',
      );
    }
  }

  Widget _onLoading() {
    return const SmoothAnimatedLogo();
  }

  Widget _onError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_imageError != true) {
        setState(() => _imageError = true);
      }
    });

    return EMPTY_WIDGET;
  }
}

class _TagLineContentButton extends StatelessWidget {
  const _TagLineContentButton({
    required this.dense,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: SMALL_SPACE),
      child: Semantics(
        button: true,
        label: label ?? localizations.tagline_feed_news_button,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(ROUNDED_RADIUS),
            color: backgroundColor ?? theme.primaryBlack,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: VERY_SMALL_SPACE,
              horizontal: VERY_LARGE_SPACE,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 1.0),
                  child: Text(
                    label ?? localizations.tagline_feed_news_button,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: MEDIUM_SPACE),
                CircledArrow.right(
                  type: CircledArrowType.normal,
                  size: 18.0 * context.textScaler(),
                  color: backgroundColor ?? theme.primaryBlack,
                  padding: EdgeInsets.all(4.0 * context.textScaler()),
                  circleColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Listen to [AppNewsProvider] feed and provide a list of [AppNewsItem]
/// randomly sorted by unread, then displayed and clicked news.
class _ScanNewsFeedProvider extends ValueNotifier<_ScanTagLineState> {
  _ScanNewsFeedProvider(BuildContext context)
      : _newsFeedProvider = context.read<AppNewsProvider>(),
        _userPreferences = context.read<UserPreferences>(),
        super(const _ScanTagLineStateLoading()) {
    _newsFeedProvider.addListener(_onNewsFeedStateChanged);
    // Refresh with the current state
    _onNewsFeedStateChanged();
  }

  final AppNewsProvider _newsFeedProvider;
  final UserPreferences _userPreferences;

  void _onNewsFeedStateChanged() {
    switch (_newsFeedProvider.state) {
      case AppNewsStateLoading():
        emit(const _ScanTagLineStateLoading());
      case AppNewsStateError():
        emit(const _ScanTagLineStateNoContent());
      case AppNewsStateLoaded():
        _onTagLineContentAvailable(
            (_newsFeedProvider.state as AppNewsStateLoaded).content);
    }
  }

  Future<void> _onTagLineContentAvailable(AppNews tagLine) async {
    if (!tagLine.feed.isNotEmpty) {
      emit(const _ScanTagLineStateNoContent());
      return;
    }

    final List<AppNewsItem> unreadNews = <AppNewsItem>[];
    final List<AppNewsItem> displayedNews = <AppNewsItem>[];
    final List<AppNewsItem> clickedNews = <AppNewsItem>[];

    final List<String> taglineFeedAlreadyClickedNews =
        _userPreferences.taglineFeedClickedNews;
    final List<String> taglineFeedAlreadyDisplayedNews =
        _userPreferences.taglineFeedDisplayedNews;

    for (final AppNewsFeedItem feedItem in tagLine.feed.news) {
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
        <AppNewsItem>[
          ...unreadNews..shuffle(),
          ...displayedNews..shuffle(),
          ...clickedNews..shuffle(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newsFeedProvider.removeListener(_onNewsFeedStateChanged);
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

  final Iterable<AppNewsItem> tagLine;
}
