import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 46.0, right: 16.0, left: 16.0, bottom: 4.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).testerSettingTitle,
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            height: 60.0,
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.black.withAlpha(5),
                borderRadius: const BorderRadius.all(Radius.circular(20.0))),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(AppLocalizations.of(context).useMLKitText),
                SmoothToggle(
                    value: userPreferences.getMlKitState(),
                    width: 80.0,
                    height: 38.0,
                    textLeft: AppLocalizations.of(context).yes,
                    textRight: AppLocalizations.of(context).no,
                    onChanged: (bool newValue) async =>
                        userPreferences.setMlKitState(newValue)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showCupertinoModalBottomSheet<Widget>(
              expand: false,
              context: context,
              backgroundColor: Colors.transparent,
              bounce: true,
              barrierColor: Colors.black45,
              builder:
                  (BuildContext context, ScrollController scrollController) =>
                      UserPreferencesView(scrollController),
            ),
            child: Container(
              height: 60.0,
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.black.withAlpha(5),
                  borderRadius: const BorderRadius.all(Radius.circular(20.0))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(AppLocalizations.of(context).configurePreferences),
                  SvgPicture.asset(
                    'assets/misc/right_arrow.svg',
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
