import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_horizontal_list.dart';

class HomePageHorizontalList<T> extends StatelessWidget {
  const HomePageHorizontalList({
    required this.items,
    this.onItemTap,
    this.onSeeMoreLabel,
    this.onSeeMoreTap,
    super.key,
  }) : assert(onSeeMoreLabel == null || onSeeMoreTap != null);

  static const double ITEM_HEIGHT = 180.0;
  static const double ITEM_WIDTH = 200.0;

  final Iterable<HomePageHorizontalListItem<T>> items;
  final Function(HomePageHorizontalListItem<T> item)? onItemTap;
  final String? onSeeMoreLabel;
  final VoidCallback? onSeeMoreTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: const CardThemeData(
          margin: EdgeInsetsDirectional.zero,
          shape: RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      child: SmoothHorizontalList(
        itemCount: items.length,
        itemWidth: ITEM_WIDTH,
        itemHeight: ITEM_HEIGHT,
        itemBuilder: (BuildContext context, int position) {
          final HomePageHorizontalListItem<T> product = items.elementAt(
            position,
          );
          return _HistoryItem<T>(
            product: product,
            onTap: onItemTap != null ? () => onItemTap!.call(product) : null,
          );
        },
        lastItemBuilder: onSeeMoreTap != null
            ? (_) =>
                  _LastHistoryItem(label: onSeeMoreLabel, onTap: onSeeMoreTap!)
            : null,
      ),
    );
  }
}

class HomePageHorizontalListItem<T> {
  const HomePageHorizontalListItem({
    required this.value,
    required this.line1,
    this.line2,
    this.background,
  });

  final T value;
  final String line1;
  final String? line2;
  final Widget? background;
}

class _HistoryItem<T> extends StatelessWidget {
  const _HistoryItem({required this.product, this.onTap});

  final HomePageHorizontalListItem<T> product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (product.background != null)
          Positioned.fill(child: product.background!),
        Positioned.fill(
          child: SizedBox.expand(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: ROUNDED_BORDER_RADIUS,
                child: Ink(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: ROUNDED_BORDER_RADIUS,
                      gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                        stops: const <double>[0.5, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 10.0,
          start: 10.0,
          end: 10.0,
          child: RichText(
            text: TextSpan(
              text: product.line1,
              children: product.line2 != null
                  ? <TextSpan>[
                      TextSpan(
                        text: '\n${product.line2}',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ]
                  : <TextSpan>[],
              style: DefaultTextStyle.of(context).style.merge(
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LastHistoryItem extends StatelessWidget {
  const _LastHistoryItem({required this.onTap, this.label});

  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return InkWell(
      onTap: onTap,
      borderRadius: ROUNDED_BORDER_RADIUS,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.primaryLight,
          borderRadius: ROUNDED_BORDER_RADIUS,
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 1.0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
                    child: icons.CircledArrow.horizontalDirectional(
                      context,
                      type: icons.CircledArrowType.thin,
                      size: 40.0,
                      color: theme.primaryBlack,
                    ),
                  ),
                  Text(
                    label ??
                        AppLocalizations.of(
                          context,
                        ).homepage_horizontal_list_view_more_button,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
