import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:smooth_app/bottom_sheet_views/user_contribution_view.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/data_models/profile_page_model.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_AlertDialog.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';

Launcher launcher = Launcher();

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<ProfilePageModel>(
        create: (BuildContext context) => ProfilePageModel(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 46.0, right: 16.0, left: 16.0, bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      S.of(context).testerSettingTitle,
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

            //Use ML Kit
            Container(
              height: 60.0,
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.black.withAlpha(10),
                  borderRadius: const BorderRadius.all(Radius.circular(20.0))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    S.of(context).useMLKitText,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Consumer<ProfilePageModel>(
                    builder: (BuildContext context,
                        ProfilePageModel profilePageModel, Widget child) {
                      if (profilePageModel.useMlKit != null) {
                        return SmoothToggle(
                          value: profilePageModel.useMlKit,
                          width: 80.0,
                          height: 38.0,
                          textLeft: S.of(context).yes,
                          textRight: S.of(context).no,
                          onChanged: (bool newValue) {
                            profilePageModel.setMlKitState(newValue);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),

            //Configure Preferences
            SmoothListTile(
              text: S.of(context).configurePreferences,
              onPressed: () => showCupertinoModalBottomSheet<Widget>(
                expand: false,
                context: context,
                backgroundColor: Colors.transparent,
                bounce: true,
                barrierColor: Colors.black45,
                builder:
                    (BuildContext context, ScrollController scrollController) =>
                        UserPreferencesView(scrollController),
              ),
            ),

            //Contribute
            SmoothListTile(
              text: S.of(context).contribute,
              onPressed: () => showCupertinoModalBottomSheet<Widget>(
                expand: false,
                context: context,
                backgroundColor: Colors.transparent,
                bounce: true,
                barrierColor: Colors.black45,
                builder:
                    (BuildContext context, ScrollController scrollController) =>
                        UserContributionView(scrollController),
              ),
            ),

            //More Links
            SmoothListTile(
              text: S.of(context).support,
              Widgeticon: const Icon(Icons.launch),
              onPressed: () => launcher.launchURL(
                  context, 'https://openfoodfacts.uservoice.com/', false),
            ),

            //About
            SmoothListTile(
              text: S.of(context).about,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    //ToDo: Show App Icon  !!! 2x !!! + onTap open App in Store https://pub.dev/packages/open_appstore

                    return SmoothAlertDialog(
                      close: false,
                      context: context,
                      body: Column(
                        children: [
                          FutureBuilder<PackageInfo>(
                              future: _getPubspecData(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<PackageInfo> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('${S.of(context).error} #0'));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData)
                                  return Center(
                                      child: Text(
                                        '${S.of(context).error} #1',
                                        )
                                      );

                                return Column(
                                  children: [
                                    ListTile(
                                      leading:
                                          const Icon(Icons.no_sim_outlined),
                                      title: Text(
                                        snapshot.data.appName.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                      ),
                                      subtitle: Text(
                                        snapshot.data.version.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      '${S.of(context).whatIsOff}',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    FlatButton(
                                      onPressed: () {},
                                      child: Text(
                                        '${S.of(context).learnMore}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    FlatButton(
                                      onPressed: () => launcher.launchURL(
                                          context,
                                          'https://openfoodfacts.org/terms-of-use',
                                          true),
                                      child: Text(
                                        '${S.of(context).termsOfUse}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        ],
                      ),
                      actions: <SmoothSimpleButton>[
                        SmoothSimpleButton(
                          onPressed: () {
                            showLicensePage(context: context);
                          },
                          text: '${S.of(context).licenses}',
                          width: 100,
                        ),
                        SmoothSimpleButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                          text: '${S.of(context).okay}',
                          width: 100,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<PackageInfo> _getPubspecData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo;
  }
}
