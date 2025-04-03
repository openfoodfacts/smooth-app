import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

const double TOOLBAR_HEIGHT = 92.0;
const double BOTTOM_HEIGHT = 86.0;

class LoggedInAppBar extends StatelessWidget {
  const LoggedInAppBar();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    return SliverAppBar(
      title: Row(
        children: <Widget>[
          Container(
            width: 68.0,
            height: 68.0,
            padding: const EdgeInsetsDirectional.all(8.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/app/release_icon_light_transparent_no_border.svg',
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        OpenFoodAPIConfiguration.globalUser?.userId ??
                            "Nom d'utilisateur",
                        style: TextStyle(
                          color: themeExtension.secondaryNormal,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Membre depuis juillet 2019!',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.none,
        background: Padding(
          padding: const EdgeInsetsDirectional.only(bottom: BOTTOM_HEIGHT),
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 0.0,
                left: 0.0,
                width: 240.0,
                height: 240.0,
                child: Transform.translate(
                  offset: const Offset(-100.0, 40.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white10,
                        width: 10.0,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                width: 220.0,
                height: 220.0,
                child: Transform.translate(
                  offset: const Offset(80.0, -40.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white10,
                        width: 10.0,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        TOOLBAR_HEIGHT +
                        MEDIUM_SPACE),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: MEDIUM_SPACE,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildStatisticCard(
                            imagePath: 'assets/preferences/ingredients.png',
                            count: '150+',
                            description: 'Produits modifiés',
                            themeExtension: themeExtension,
                          ),
                        ),
                        const SizedBox(width: MEDIUM_SPACE),
                        Expanded(
                          child: _buildStatisticCard(
                            imagePath: 'assets/preferences/cash.png',
                            count: '950+',
                            description: 'Prix ajoutés',
                            themeExtension: themeExtension,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              const UserPreferencesPage(),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(top: MEDIUM_SPACE),
                        padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
                        decoration: const BoxDecoration(
                          borderRadius: ROUNDED_BORDER_RADIUS,
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Voir d'autres statistiques",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: MEDIUM_SPACE),
                            Icon(
                              Icons.arrow_circle_right,
                              size: 24.0,
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(BOTTOM_HEIGHT),
        child: SizedBox(
          height: BOTTOM_HEIGHT,
          child: CustomPaint(
            painter: _BottomPainter(
              color: themeExtension.primaryMedium,
              radius: ROUNDED_RADIUS,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: LARGE_SPACE * 2,
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
                bottom: MEDIUM_SPACE,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SmoothTextFormField(
                      type: TextFieldTypes.PLAIN_TEXT,
                      controller: TextEditingController(),
                      hintText: 'Rechercher un paramètre (ex: NutriScore)',
                      outlined: true,
                      suffixIcon: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: ROUNDED_BORDER_RADIUS,
                          color: theme.primaryColor,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                      onChanged: (String? value) {
                        context
                            .read<PreferencesRootSearchController>()
                            .search(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      toolbarHeight: TOOLBAR_HEIGHT,
      pinned: true,
      floating: true,
      expandedHeight: 310.0,
      backgroundColor: theme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: ROUNDED_RADIUS,
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String imagePath,
    required String count,
    required String description,
    required SmoothColorsThemeExtension themeExtension,
  }) {
    return Container(
      height: 68.0,
      padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      decoration: BoxDecoration(
        borderRadius: ROUNDED_BORDER_RADIUS,
        color: themeExtension.secondaryVibrant.withValues(
          alpha: 0.8,
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            height: 32.0,
          ),
          const SizedBox(width: MEDIUM_SPACE),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        count,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        description,
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
    );
  }
}

class _BottomPainter extends CustomPainter {
  _BottomPainter({
    required Color color,
    required this.radius,
  }) : _paint = Paint()..color = color;

  final Radius radius;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..arcToPoint(
        Offset(radius.x, radius.y),
        radius: radius,
        clockwise: false,
      )
      ..lineTo(size.width - radius.x, radius.y)
      ..arcToPoint(
        Offset(size.width, 0),
        radius: radius,
        clockwise: false,
      )
      ..lineTo(size.width, size.height - radius.y)
      ..arcToPoint(
        Offset(size.width - radius.x, size.height),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(radius.x, size.height)
      ..arcToPoint(
        Offset(0, size.height - radius.y),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(
    _BottomPainter oldDelegate,
  ) =>
      radius != oldDelegate.radius;

  @override
  bool shouldRebuildSemantics(
    _BottomPainter oldDelegate,
  ) =>
      false;
}
