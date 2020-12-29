import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_AlertDialog.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';

Launcher launcher = Launcher();

class UserContributionView extends StatelessWidget {
  const UserContributionView(this._scrollController, {this.callback});

  final ScrollController _scrollController;
  final Function callback;

  static final List<Color> _colors = <Color>[
    Colors.black87,
    Colors.green.withOpacity(0.87),
    Colors.deepOrangeAccent.withOpacity(0.87),
    Colors.redAccent.withOpacity(0.87),
  ];
  static const Color _COLOR_DEFAULT = Colors.black26;

  static Color getColor(final int index) => _colors[index] ?? _COLOR_DEFAULT;

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
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
                        child: Text(
                          S.of(context).contribute,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Column(
                        /// NGO FEE
                        /// https://stackoverflow.com/questions/46505660/how-to-create-a-google-play-console-developper-account-for-our-ngo
                        ///

                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //Contribute
                          SmoothListTile(
                              text: S.of(context).contribute_contribute_header,
                              onPressed: () => showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SmoothAlertDialog(
                                      context: context,
                                      title: S
                                          .of(context)
                                          .contribute_contribute_header,
                                      body: Column(
                                        children: [
                                          Text(
                                            S
                                                .of(context)
                                                .contribute_contribute_text,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                          FlatButton(
                                            onPressed: () => launcher.launchURL(
                                                context,
                                                'https://world.openfoodfacts.org/state/to-be-completed',
                                                false),
                                            child: Text(
                                              S
                                                  .of(context)
                                                  .contribute_contribute_toBeCompleted,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () => launcher.launchURL(
                                                context,
                                                'https://wiki.openfoodfacts.org/Contribution_missions',
                                                false),
                                            child: Text(
                                              S
                                                  .of(context)
                                                  .contribute_contribute_contributionMissions,
                                              style: const TextStyle(
                                                  color: Colors.blue),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () => launcher.launchURL(
                                                context,
                                                'https://wiki.openfoodfacts.org/Quality',
                                                false),
                                            child: Text(
                                              S
                                                  .of(context)
                                                  .contribute_contribute_qualityIssues,
                                              style: const TextStyle(
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        SmoothSimpleButton(
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                          },
                                          text: '${S.of(context).okay}',
                                          width: 100,
                                        ),
                                      ],
                                    );
                                  })),

                          //Develope
                          SmoothListTile(
                            text: S.of(context).contribute_develop,
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SmoothAlertDialog(
                                  title: S.of(context).contribute_develop,
                                  context: context,
                                  body: Column(
                                    children: [
                                      Text(
                                        S.of(context).contribute_develop_text,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        S.of(context).contribute_develop_text_2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      FlatButton(
                                        onPressed: () => launcher.launchURL(
                                            context,
                                            'https://wiki.openfoodfacts.org/Software_Development',
                                            true),
                                        child: Text(
                                          '${S.of(context).learnMore}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    SmoothSimpleButton(
                                      onPressed: () => launcher.launchURL(
                                          context,
                                          'https://slack.openfoodfacts.org/',
                                          false),
                                      text: 'GitHub',
                                      width: 100,
                                    ),
                                    SmoothSimpleButton(
                                      onPressed: () => launcher.launchURL(
                                          context,
                                          'https://github.com/openfoodfacts',
                                          false),
                                      text: 'Slack',
                                      width: 100,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          //Translate
                          SmoothListTile(
                            text: S.of(context).contribute_translate_header,
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SmoothAlertDialog(
                                  title:
                                      S.of(context).contribute_translate_header,
                                  context: context,
                                  body: Column(
                                    children: [
                                      Text(
                                        S.of(context).contribute_translate_text,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Text(
                                        S
                                            .of(context)
                                            .contribute_translate_text_2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    SmoothSimpleButton(
                                      onPressed: () => launcher.launchURL(
                                          context,
                                          'https://slack.openfoodfacts.org/',
                                          false),
                                      text: S
                                          .of(context)
                                          .contribute_translate_link_text,
                                      width: 200,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          //Donate
                          SmoothListTile(
                            text: S.of(context).contribute_donate_header,
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SmoothAlertDialog(
                                  context: context,
                                  body: Column(
                                    children: [
                                      Text(
                                        S.of(context).featureInProgress,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    SmoothSimpleButton(
                                      text: S.of(context).okay,
                                      onPressed: () => Navigator.of(context,
                                              rootNavigator: true)
                                          .pop('dialog'),
                                      width: 150,
                                    )
                                  ],
                                );
                              },
                            ),
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
}
