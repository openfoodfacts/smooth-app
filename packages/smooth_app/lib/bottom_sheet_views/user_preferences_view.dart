import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

class UserPreferencesView extends StatelessWidget {
  const UserPreferencesView(this._scrollController);

  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider<UserPreferencesModel>(
        create: (BuildContext context) => UserPreferencesModel(),
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
                          margin: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            S.of(context).mandatory,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(
                            UserPreferencesVariableExtension
                                    .getMandatoryVariables()
                                .length,
                            (int index) => _generateMandatoryRow(
                              UserPreferencesVariableExtension
                                      .getMandatoryVariables()
                                  .elementAt(index),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          margin: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            S.of(context).accountable,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(
                            UserPreferencesVariableExtension
                                    .getAccountableVariables()
                                .length,
                            (int index) => _generateMandatoryRow(
                              UserPreferencesVariableExtension
                                      .getAccountableVariables()
                                  .elementAt(index),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 4.0,
                        sigmaY: 4.0,
                      ),
                      child: Container(
                        color: Colors.black12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 20.0),
                        child: Consumer<UserPreferencesModel>(
                          builder: (BuildContext context,
                              UserPreferencesModel userPreferencesModel,
                              Widget child) {
                            return SmoothMainButton(
                              text: S.of(context).saveButtonText,
                              onPressed: () {
                                userPreferencesModel.saveUserPreferences();
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generateMandatoryRow(UserPreferencesVariable variable) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.black.withAlpha(5),
          borderRadius: const BorderRadius.all(Radius.circular(20.0))),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(variable.name),
          Consumer<UserPreferencesModel>(
            builder: (BuildContext context,
                UserPreferencesModel userPreferencesModel, Widget child) {
              return SmoothToggle(
                value: userPreferencesModel.dataLoaded
                    ? userPreferencesModel.getVariable(variable)
                    : userPreferencesModel.dataLoaded,
                onChanged: (bool newValue) {
                  userPreferencesModel.setVariable(variable, newValue);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
