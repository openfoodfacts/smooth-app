import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';

Launcher launcher = Launcher();

class UserContributionView extends StatelessWidget {
  const UserContributionView(this._scrollController, {this.callback});

  final ScrollController _scrollController;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
                        child: Text(
                          AppLocalizations.of(context).contribute,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <SmoothListTile>[
                          //Contribute
                          SmoothListTile(
                              text: AppLocalizations.of(context)
                                  .contribute_contribute_header,
                              onPressed: () => _contribute(context)),

                          //Develop
                          SmoothListTile(
                            text:
                                AppLocalizations.of(context).contribute_develop,
                            onPressed: () => _develop(context),
                          ),

                          //Translate
                          SmoothListTile(
                            text: AppLocalizations.of(context)
                                .contribute_translate_header,
                            onPressed: () => _translate(context),
                          ),

                          //Donate
                          SmoothListTile(
                            text: AppLocalizations.of(context)
                                .contribute_donate_header,
                            onPressed: () => _donate(context),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contribute(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SmoothAlertDialog(
            close: false,
            title: AppLocalizations.of(context).contribute_contribute_header,
            body: Column(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).contribute_contribute_text,
                ),
                FlatButton(
                  onPressed: () => launcher.launchURL(
                      context,
                      'https://world.openfoodfacts.org/state/to-be-completed',
                      false),
                  child: Text(
                    AppLocalizations.of(context)
                        .contribute_contribute_toBeCompleted,
                  ),
                ),
                FlatButton(
                  onPressed: () => launcher.launchURL(
                      context,
                      'https://wiki.openfoodfacts.org/Contribution_missions',
                      false),
                  child: Text(
                    AppLocalizations.of(context)
                        .contribute_contribute_contributionMissions,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                FlatButton(
                  onPressed: () => launcher.launchURL(
                      context, 'https://wiki.openfoodfacts.org/Quality', false),
                  child: Text(
                    AppLocalizations.of(context)
                        .contribute_contribute_qualityIssues,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            actions: <SmoothSimpleButton>[
              SmoothSimpleButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                text: '${AppLocalizations.of(context).okay}',
                width: 100,
              ),
            ],
          );
        });
  }

  Future<void> _develop(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: AppLocalizations.of(context).contribute_develop,
          body: Column(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).contribute_develop_text,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context).contribute_develop_text_2,
              ),
              FlatButton(
                onPressed: () => launcher.launchURL(
                    context,
                    'https://wiki.openfoodfacts.org/Software_Development',
                    false),
                child: Text(
                  '${AppLocalizations.of(context).learnMore}',
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              onPressed: () => launcher.launchURL(
                  context, 'https://github.com/openfoodfacts', false),
              text: 'GitHub',
              width: 100,
            ),
            SmoothSimpleButton(
              onPressed: () => launcher.launchURL(
                  context, 'https://slack.openfoodfacts.org/', false),
              text: 'Slack',
              width: 100,
            ),
          ],
        );
      },
    );
  }

  Future<void> _translate(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: AppLocalizations.of(context).contribute_translate_header,
          body: Column(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).contribute_translate_text,
              ),
              Text(
                AppLocalizations.of(context).contribute_translate_text_2,
              ),
            ],
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              onPressed: () => launcher.launchURL(
                  context, 'https://translate.openfoodfacts.org/', false),
              text: AppLocalizations.of(context).contribute_translate_link_text,
              width: 200,
            ),
          ],
        );
      },
    );
  }

  Future<void> _donate(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          body: Column(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).featureInProgress,
              ),
            ],
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: AppLocalizations.of(context).okay,
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop('dialog'),
              width: 150,
            )
          ],
        );
      },
    );
  }
}
