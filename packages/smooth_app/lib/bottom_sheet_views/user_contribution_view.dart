import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';
import 'package:smooth_app/functions/launchURL.dart';

class UserContributionView extends StatelessWidget {
  final Launcher launcher = Launcher();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
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
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
                        child: Text(
                          AppLocalizations.of(context)!.contribute,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <SmoothListTile>[
                          //Contribute
                          SmoothListTile(
                              text: AppLocalizations.of(context)!
                                  .contribute_improve_header,
                              onPressed: () => _contribute(context)),

                          //Develop
                          SmoothListTile(
                            text: AppLocalizations.of(context)!
                                .contribute_develop,
                            onPressed: () => _develop(context),
                          ),

                          //Translate
                          SmoothListTile(
                            text: AppLocalizations.of(context)!
                                .contribute_translate_header,
                            onPressed: () => _translate(context),
                          ),

                          //Donate
                          SmoothListTile(
                            text: AppLocalizations.of(context)!
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
          title: AppLocalizations.of(context)!.contribute_improve_header,
          body: Column(
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.contribute_improve_text,
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () => launcher.launchURL(
                    context,
                    'https://world.openfoodfacts.org/state/to-be-completed',
                    false),
                child: Text(
                  AppLocalizations.of(context)!
                      .contribute_improve_ProductsToBeCompleted,
                ),
              ),
            ],
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              text: '${AppLocalizations.of(context)!.okay}',
              minWidth: 100,
            ),
          ],
        );
      },
    );
  }

  Future<void> _develop(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: AppLocalizations.of(context)!.contribute_develop,
          body: Column(
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.contribute_develop_text,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context)!.contribute_develop_text_2,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () => launcher.launchURL(
                        context, 'https://slack.openfoodfacts.org/', false),
                    child: const Text(
                      'Slack',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => launcher.launchURL(
                        context, 'https://github.com/openfoodfacts', false),
                    child: const Text(
                      'Github',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              onPressed: () => Navigator.pop(context),
              text: AppLocalizations.of(context)!.okay,
              minWidth: 100,
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
          title: AppLocalizations.of(context)!.contribute_translate_header,
          body: Column(
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.contribute_translate_text,
              ),
              Text(
                AppLocalizations.of(context)!.contribute_translate_text_2,
              ),
            ],
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              onPressed: () => launcher.launchURL(
                  context, 'https://translate.openfoodfacts.org/', false),
              text:
                  AppLocalizations.of(context)!.contribute_translate_link_text,
              minWidth: 200,
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
                AppLocalizations.of(context)!.featureInProgress,
              ),
            ],
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: AppLocalizations.of(context)!.okay,
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop('dialog'),
              minWidth: 150,
            )
          ],
        );
      },
    );
  }
}
