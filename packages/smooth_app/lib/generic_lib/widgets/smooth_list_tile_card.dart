import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/themes/constant_icons.dart';

class SmoothListTileCard extends StatelessWidget {
  const SmoothListTileCard({
    required this.title,
    this.imageProvider,
    this.onTap,
  });

  final String title;
  final ImageProvider? imageProvider;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return SmoothCard(
      child: ListTile(
        onTap: onTap,
        leading: imageProvider != null
            ? Image(
                image: imageProvider!,
                fit: BoxFit.cover,
                width: 100,
              )
            : SvgPicture.asset(
                'assets/product/product_not_found.svg',
                fit: BoxFit.cover,
                width: 100,
              ),
        title: Text(
          title,
          style: themeData.textTheme.headline4,
        ),
        trailing: Icon(ConstantIcons.instance.getForwardIcon()),
      ),
    );
  }
}
