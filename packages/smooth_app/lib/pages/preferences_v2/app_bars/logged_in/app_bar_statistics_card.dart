import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class AppBarStatisticsCard extends StatefulWidget {
  AppBarStatisticsCard({
    required this.imagePath,
    required this.description,
    required this.lazyCounter,
    super.key,
  })  : assert(
          imagePath.isNotEmpty,
          'AppBarStatisticsCard imagePath must not be empty.',
        ),
        assert(
          description.isNotEmpty,
          'AppBarStatisticsCard description must not be empty.',
        );

  final String imagePath;
  final String description;
  final LazyCounter lazyCounter;

  @override
  State<StatefulWidget> createState() => _AppBarStatisticsCardState();
}

class _AppBarStatisticsCardState extends State<AppBarStatisticsCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    return Consumer<UserPreferences>(
      builder: (
        BuildContext context,
        UserPreferences userPreferences,
        Widget? child,
      ) {
        final int? count = widget.lazyCounter.getLocalCount(userPreferences);
        return InkWell(
          borderRadius: ROUNDED_BORDER_RADIUS,
          onTap: () => _asyncLoad(),
          child: Container(
            height: STATISTICS_CARD_HEIGHT,
            padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
            decoration: BoxDecoration(
              borderRadius: ROUNDED_BORDER_RADIUS,
              color: themeExtension.secondaryVibrant.withValues(
                alpha: 0.8,
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Row(
                    children: <Widget>[
                      SvgPicture.asset(
                        widget.imagePath,
                        height: 32.0,
                      ),
                      const SizedBox(width: MEDIUM_SPACE),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    widget.description,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  end: 0.0,
                  top: 0.0,
                  child: _loading
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 16.0,
                        ),
                ),
              ],
            ),
          ),
        );
      },
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
      debugPrint('Error loading data: $e');
    } finally {
      _loading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
