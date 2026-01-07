import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:vector_graphics/vector_graphics.dart';

class AppBarStatisticsCard extends StatefulWidget {
  AppBarStatisticsCard({
    required this.imagePath,
    required this.description,
    required this.lazyCounter,
    required this.onTap,
    this.autoSizeGroup,
    super.key,
  }) : assert(imagePath.isNotEmpty, 'imagePath must not be empty.'),
       assert(imagePath.endsWith('.vec'), 'image must be in the vec format'),
       assert(description.isNotEmpty, 'description must not be empty.');

  final String imagePath;
  final String description;
  final LazyCounter lazyCounter;
  final AutoSizeGroup? autoSizeGroup;
  final VoidCallback onTap;

  static const double HEIGHT = 68.0;

  @override
  State<StatefulWidget> createState() => _AppBarStatisticsCardState();
}

class _AppBarStatisticsCardState extends State<AppBarStatisticsCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    final int? count = widget.lazyCounter.getLocalCount(userPreferences);

    return Material(
      borderRadius: ROUNDED_BORDER_RADIUS,
      color: themeExtension.secondaryVibrant.withValues(alpha: 0.95),
      child: SizedBox(
        height: AppBarStatisticsCard.HEIGHT,
        child: InkWell(
          borderRadius: ROUNDED_BORDER_RADIUS,
          onTap: widget.onTap,
          child: CustomMultiChildLayout(
            delegate: _AppBarStaticsCardLayout(MEDIUM_SPACE),
            children: <Widget>[
              LayoutId(
                id: _AppBarStatisticsCardLayoutItem.illustration,
                child: SvgPicture(
                  AssetBytesLoader(widget.imagePath),
                  height: 32.0,
                ),
              ),
              LayoutId(
                id: _AppBarStatisticsCardLayoutItem.counter,
                child: AutoSizeText(
                  count != null
                      ? NumberFormat.decimalPattern(
                          ProductQuery.getLocaleString(),
                        ).format(count)
                      : '0',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              LayoutId(
                id: _AppBarStatisticsCardLayoutItem.description,
                child: AutoSizeText(
                  widget.description,
                  group: widget.autoSizeGroup,
                  minFontSize: 8.0,
                  softWrap: false,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              LayoutId(
                id: _AppBarStatisticsCardLayoutItem.refreshButton,
                child: _AppBarStatisticsCardProgressBar(
                  onTap: () => _asyncLoad(),
                  animate: _loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _asyncLoad() async {
    if (_loading) {
      return;
    }
    _loading = true;
    final UserPreferences userPreferences = context.read<UserPreferences>();
    if (mounted) {
      setState(() {});
    }
    try {
      final int? value = await widget.lazyCounter.getServerCount();
      if (value != null) {
        await widget.lazyCounter.setLocalCount(
          value,
          userPreferences,
          notify: false,
        );
      }
    } catch (e) {
      Logs.e('Error loading data: $e');
    } finally {
      _loading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}

enum _AppBarStatisticsCardLayoutItem {
  illustration,
  counter,
  description,
  refreshButton,
}

class _AppBarStaticsCardLayout extends MultiChildLayoutDelegate {
  _AppBarStaticsCardLayout(this.padding);

  final double padding;

  @override
  void performLayout(Size size) {
    final BoxConstraints availableSize = BoxConstraints.loose(size).deflate(
      EdgeInsetsDirectional.symmetric(horizontal: padding, vertical: padding),
    );

    final Size illustrationSize = layoutChild(
      _AppBarStatisticsCardLayoutItem.illustration,
      availableSize,
    );

    final double buttonWidth = size.height * 0.6;
    final Size counterSize = layoutChild(
      _AppBarStatisticsCardLayoutItem.counter,
      availableSize.deflate(
        EdgeInsetsDirectional.only(
          start: illustrationSize.width + padding * 2 + buttonWidth,
        ),
      ),
    );
    final Size descriptionSize = layoutChild(
      _AppBarStatisticsCardLayoutItem.description,
      availableSize.deflate(
        EdgeInsetsDirectional.only(start: illustrationSize.width + padding * 2),
      ),
    );

    final double verticalSpacing =
        (size.height - counterSize.height - descriptionSize.height) / 2;

    final Size refreshButtonSize = layoutChild(
      _AppBarStatisticsCardLayoutItem.refreshButton,
      BoxConstraints.tight(
        Size(buttonWidth, verticalSpacing + counterSize.height),
      ),
    );

    positionChild(
      _AppBarStatisticsCardLayoutItem.refreshButton,
      Offset(size.width - refreshButtonSize.width, verticalSpacing * 0.5),
    );
    positionChild(
      _AppBarStatisticsCardLayoutItem.illustration,
      Offset(padding, illustrationSize.height / 2),
    );
    positionChild(
      _AppBarStatisticsCardLayoutItem.counter,
      Offset(padding + illustrationSize.width + padding, verticalSpacing),
    );
    positionChild(
      _AppBarStatisticsCardLayoutItem.description,
      Offset(
        padding + illustrationSize.width + padding,
        verticalSpacing + counterSize.height,
      ),
    );
  }

  @override
  bool shouldRelayout(_AppBarStaticsCardLayout oldDelegate) => true;
}

class _AppBarStatisticsCardProgressBar extends StatefulWidget {
  const _AppBarStatisticsCardProgressBar({
    required this.animate,
    required this.onTap,
  });

  final bool animate;
  final VoidCallback onTap;

  @override
  State<_AppBarStatisticsCardProgressBar> createState() =>
      _AppBarStatisticsCardProgressBarState();
}

class _AppBarStatisticsCardProgressBarState
    extends State<_AppBarStatisticsCardProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed && widget.animate) {
            Future<void>.delayed(const Duration(milliseconds: 100), () {
              if (widget.animate) {
                _controller.forward(from: 0.0);
              }
            });
          }
        });

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _updateAnimationController();
  }

  @override
  void didUpdateWidget(_AppBarStatisticsCardProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate == widget.animate) {
      return;
    }

    _updateAnimationController();
  }

  void _updateAnimationController() {
    if (widget.animate || _controller.isAnimating) {
      _controller.forward(from: widget.animate ? 0.0 : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Tooltip(
      message: appLocalizations.label_reload,
      child: RotationTransition(
        turns: _animation,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          child: const Padding(
            padding: EdgeInsetsDirectional.all(MEDIUM_SPACE),
            child: icons.Reload(color: Colors.white, size: 16.0),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
