import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_app/data_models/github_contributors_model.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/widgets/modal_bottomsheet_header.dart';

class UserContributionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            ModalBottomSheetHeader(
                title: AppLocalizations.of(context)!.contribute),
            SmoothListTile(
              text: AppLocalizations.of(context)!.contribute_improve_header,
              onPressed: () => _contribute(context),
            ),

            //Develop
            SmoothListTile(
              text: AppLocalizations.of(context)!.contribute_sw_development,
              onPressed: () => _develop(context),
            ),

            //Translate
            SmoothListTile(
              text: AppLocalizations.of(context)!.contribute_translate_header,
              onPressed: () => _translate(context),
            ),

            //Donate
            SmoothListTile(
              text: AppLocalizations.of(context)!.contribute_donate_header,
              leadingWidget: const Icon(Icons.open_in_new),
              onPressed: () => _donate(context),
            ),

            //Contributors list
            SmoothListTile(
              text: AppLocalizations.of(context)!.contributors,
              onPressed: () => _contributors(context),
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
          close: true,
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
                onPressed: () => LaunchUrlHelper.launchURL(
                    'https://world.openfoodfacts.org/state/to-be-completed',
                    false),
                child: Text(
                  AppLocalizations.of(context)!
                      .contribute_improve_ProductsToBeCompleted,
                ),
              ),
            ],
          ),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              text: AppLocalizations.of(context)!.okay,
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
          title: AppLocalizations.of(context)!.contribute_sw_development,
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
          actions: <SmoothActionButton>[
            SmoothActionButton(
              onPressed: () => LaunchUrlHelper.launchURL(
                  'https://translate.openfoodfacts.org/', false),
              text:
                  AppLocalizations.of(context)!.contribute_translate_link_text,
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
        return SmoothAlertDialog(
          title: AppLocalizations.of(context)!.contributors,
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

                return SingleChildScrollView(
                  child: Wrap(
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
                            foregroundImage:
                                NetworkImage(_contributor.avatarUrl),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
