import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_app/data_models/github_contributors_model.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/list_helper.dart';

class UserContributionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<ListHelper> tileData = <ListHelper>[
      //Contribute
      ListHelper(
        onTap: () => _contribute(context),
        title: appLocalizations.contribute_improve_header,
      ),

      //Develop
      ListHelper(
        onTap: () => _develop(context),
        title: appLocalizations.contribute_sw_development,
      ),

      //Translate
      ListHelper(
        onTap: () => _translate(context),
        title: appLocalizations.contribute_translate_header,
      ),

      //Donate
      ListHelper(
        icon: const Icon(Icons.open_in_new),
        onTap: () => _donate(context),
        title: appLocalizations.contribute_donate_header,
      ),

      //Contributors list
      ListHelper(
        onTap: () => _contributors(context),
        title: appLocalizations.contributors,
      ),
    ];
    return Material(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
              child: Text(
                appLocalizations.contribute,
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: tileData.length,
                itemBuilder: (BuildContext context, int index) {
                  return SmoothListTile(
                    text: tileData[index].title,
                    onPressed: tileData[index].onTap,
                    leadingWidget: tileData[index].icon,
                  );
                },
              ),
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
        final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
        return SmoothAlertDialog.advanced(
          close: false,
          maxHeight: MediaQuery.of(context).size.height * 0.35,
          title: appLocalizations.contribute_improve_header,
          body: Column(
            children: <Widget>[
              Text(
                appLocalizations.contribute_improve_text,
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () => LaunchUrlHelper.launchURL(
                    'https://world.openfoodfacts.org/state/to-be-completed',
                    false),
                child: Text(
                  appLocalizations.contribute_improve_ProductsToBeCompleted,
                ),
              ),
            ],
          ),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              text: appLocalizations.okay,
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
        final AppLocalizations applocalization = AppLocalizations.of(context)!;
        return SmoothAlertDialog.advanced(
          maxHeight: MediaQuery.of(context).size.height * 0.35,
          title: applocalization.contribute_sw_development,
          body: Column(
            children: <Widget>[
              Text(
                applocalization.contribute_develop_text,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                applocalization.contribute_develop_text_2,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () => LaunchUrlHelper.launchURL(
                        'https://slack.openfoodfacts.org/', false),
                    child: const Text(
                      'Slack',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => LaunchUrlHelper.launchURL(
                        'https://github.com/openfoodfacts', false),
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
          actions: <SmoothActionButton>[
            SmoothActionButton(
              onPressed: () => Navigator.pop(context),
              text: applocalization.okay,
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
        final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
        return SmoothAlertDialog.advanced(
          title: appLocalizations.contribute_translate_header,
          maxHeight: MediaQuery.of(context).size.height * 0.25,
          body: Column(
            children: <Widget>[
              Text(
                appLocalizations.contribute_translate_text,
              ),
              Text(
                appLocalizations.contribute_translate_text_2,
              ),
            ],
          ),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              onPressed: () => LaunchUrlHelper.launchURL(
                  'https://translate.openfoodfacts.org/', false),
              text: appLocalizations.contribute_translate_link_text,
              minWidth: 200,
            ),
          ],
        );
      },
    );
  }

  Future<void> _donate(BuildContext context) async {
    await LaunchUrlHelper.launchURL(
      AppLocalizations.of(context)!.donate_url,
      false,
    );
  }

  Future<void> _contributors(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog.advanced(
          title: AppLocalizations.of(context)!.contributors,
          maxHeight: MediaQuery.of(context).size.height * 0.45,
          body: FutureBuilder<http.Response>(
            future: http.get(
              Uri.https(
                'api.github.com',
                '/repos/openfoodfacts/smooth-app/contributors',
              ),
            ),
            builder: (BuildContext context, AsyncSnapshot<http.Response> snap) {
              if (snap.hasData) {
                final List<dynamic> contributors =
                    jsonDecode(snap.data!.body) as List<dynamic>;
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: contributors.map((dynamic contributorsData) {
                    final ContributorsModel _contributor =
                        ContributorsModel.fromJson(
                            contributorsData as Map<String, dynamic>);
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        onTap: () {
                          LaunchUrlHelper.launchURL(
                              _contributor.profilePath, false);
                        },
                        child: CircleAvatar(
                          foregroundImage: NetworkImage(_contributor.avatarUrl),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(growable: false),
                );
              }

              return const CircularProgressIndicator();
            },
          ),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              onPressed: () => LaunchUrlHelper.launchURL(
                  'https://github.com/openfoodfacts/smooth-app', false),
              text: AppLocalizations.of(context)!.contribute,
              minWidth: 200,
            ),
          ],
        );
      },
    );
  }
}
