import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  static const String _iconLightAssetPath =
      'assets/app/release_icon_light_transparent_no_border.svg';
  static const String _iconDarkAssetPath =
      'assets/app/release_icon_dark_transparent_no_border.svg';

  @override
  Widget build(BuildContext context) {
    return SmoothBrightnessOverride(
      brightness: context.lightTheme() ? Brightness.dark : Brightness.light,
      child: SmoothScaffold(
        body: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            final PackageInfo? packageInfo = snapshot.data;
            if (packageInfo == null) {
              return const CircularProgressIndicator.adaptive();
            }

            return LicensePage(
              applicationName: packageInfo.appName,
              applicationVersion: packageInfo.version,
              applicationIcon: SvgPicture.asset(
                context.lightTheme() ? _iconLightAssetPath : _iconDarkAssetPath,
                height: MediaQuery.sizeOf(context).height * 0.1,
              ),
            );
          },
        ),
      ),
    );
  }
}
