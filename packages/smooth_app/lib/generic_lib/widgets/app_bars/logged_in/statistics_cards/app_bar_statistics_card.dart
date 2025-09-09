import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class AppBarStatisticsCard extends StatefulWidget {
  AppBarStatisticsCard({
    required this.imagePath,
    required this.description,
    required this.lazyCounter,
    this.autoSizeGroup,
    super.key,
  }) : assert(imagePath.isNotEmpty, 'imagePath must not be empty.'),
       assert(description.isNotEmpty, 'description must not be empty.');

  final String imagePath;
  final String description;
  final LazyCounter lazyCounter;
  final AutoSizeGroup? autoSizeGroup;

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

    return InkWell(
      borderRadius: ROUNDED_BORDER_RADIUS,
      onTap: () => _asyncLoad(),
      child: SizedBox(
        height: STATISTICS_CARD_HEIGHT,
        child: Material(
          borderRadius: ROUNDED_BORDER_RADIUS,
          color: themeExtension.secondaryVibrant.withValues(alpha: 0.8),
          child: Row(
            children: <Widget>[
              const SizedBox(width: MEDIUM_SPACE),
              SvgPicture.asset(widget.imagePath, height: 32.0),
              const SizedBox(width: MEDIUM_SPACE),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            count != null ? count.toString() : '0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_loading)
                          const SizedBox.square(
                            dimension: 16.0,
                            child: CircularProgressIndicator.adaptive(),
                          )
                        else
                          const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 16.0,
                          ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AutoSizeText(
                            widget.description,
                            group: widget.autoSizeGroup,
                            minFontSize: 8.0,
                            softWrap: false,
                            maxLines: 1,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: MEDIUM_SPACE),
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
