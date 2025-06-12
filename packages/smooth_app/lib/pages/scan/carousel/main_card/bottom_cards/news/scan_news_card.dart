import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_app_logo.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/scan_bottom_card.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class ScanNewsCard extends StatefulWidget {
  const ScanNewsCard({
    required this.news,
  });

  final Iterable<AppNewsItem> news;

  @override
  State<ScanNewsCard> createState() => _ScanNewsCardState();
}

class _ScanNewsCardState extends State<ScanNewsCard> {
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
    final AppNewsItem currentNews = widget.news.elementAt(_index);
    final bool dense = context.select<ScanBottomCardDensity, bool>(
      (ScanBottomCardDensity density) => density == ScanBottomCardDensity.dense,
    );

    return ScanBottomCardContainer(
      title: currentNews.title,
      titleBackgroundColor: currentNews.style?.titleBackground,
      titleIndicatorColor: currentNews.style?.titleIndicatorColor,
      titleColor: currentNews.style?.titleTextColor,
      body: InkWell(
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
              _TagLineContentBody(
                message: currentNews.message,
                textColor: currentNews.style?.messageTextColor,
                image: currentNews.image,
                darkImage: currentNews.darkImage,
                dense: dense,
              ),
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _TagLineContentBody extends StatefulWidget {
  const _TagLineContentBody({
    required this.message,
    required this.dense,
    this.textColor,
    this.image,
    this.darkImage,
  });

  final String message;
  final bool dense;
  final Color? textColor;
  final AppNewsImage? image;
  final AppNewsImage? darkImage;

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
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    final Widget text = TextWithBoldParts(
      text: widget.message,

      /// We have to force a maxLines
      maxLines: widget.dense ? 500 : null,
      overflow: widget.dense ? TextOverflow.ellipsis : null,
      textStyle: TextStyle(
        color: widget.textColor ??
            (context.lightTheme(listen: true)
                ? theme.primaryBlack
                : theme.primaryLight),
        fontSize: 15.0,
      ),
    );

    // There's no check for the dark image, as it's optional.
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
    final AppNewsImage image = widget.darkImage == null
        ? widget.image!
        : (context.darkTheme() ? widget.darkImage! : widget.image!);

    if (image.src?.endsWith('svg') == true) {
      return SvgCache(
        image.src,
        semanticsLabel: image.alt,
        loadingBuilder: (_) => _onLoading(),
        errorBuilder: (_, __) => _onError(),
      );
    } else {
      return Image.network(
        semanticLabel: image.alt,
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
        image.src ?? '-',
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
            color: backgroundColor ?? theme.primarySemiDark,
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
