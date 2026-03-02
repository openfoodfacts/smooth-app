import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Widget displaying a Lazy Counter: cached value, refresh button, and loading.
class LazyCounterWidget extends StatefulWidget {
  const LazyCounterWidget(this.lazyCounter);

  final LazyCounter lazyCounter;

  @override
  State<LazyCounterWidget> createState() => _LazyCounterWidgetState();
}

class _LazyCounterWidgetState extends State<LazyCounterWidget> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final UserPreferences userPreferences = context.read<UserPreferences>();
    final int? count = widget.lazyCounter.getLocalCount(userPreferences);
    if (count == null) {
      unawaited(_asyncLoad());
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final int? count = widget.lazyCounter.getLocalCount(userPreferences);

    return Material(
      borderRadius: ANGULAR_BORDER_RADIUS,
      color: lightTheme ? extension.primaryLight : extension.primaryDark,
      child: InkWell(
        borderRadius: ANGULAR_BORDER_RADIUS,
        onTap: () => _asyncLoad(),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: MEDIUM_SPACE,
            end: MEDIUM_SPACE,
            top: 5.0,
            bottom: 6.0,
          ),
          child: Row(
            spacing: SMALL_SPACE,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (count != null)
                Text(
                  NumberFormat.decimalPattern(
                    ProductQuery.getLocaleString(),
                  ).format(count),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              if (_loading)
                SizedBox.square(
                  dimension: 14.0,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      extension.secondaryVibrant,
                    ),
                  ),
                )
              else
                const icons.Reload(size: 16.0),
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
      //
    } finally {
      _loading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
