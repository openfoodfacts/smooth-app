import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';

class UserPreferencesView extends StatelessWidget {
  const UserPreferencesView(this._scrollController, {this.callback});

  final ScrollController _scrollController;
  final Function callback;

  static final Map<String, Color> _colors = <String, Color>{
    PreferencesValue.NOT_IMPORTANT: Colors.black87,
    PreferencesValue.IMPORTANT: Colors.green.withOpacity(0.87),
    PreferencesValue.VERY_IMPORTANT: Colors.deepOrangeAccent.withOpacity(0.87),
    PreferencesValue.MANDATORY: Colors.redAccent.withOpacity(0.87),
  };
  static const Color _COLOR_DEFAULT = Colors.black26;

  static Color getColor(final String value) => _colors[value] ?? _COLOR_DEFAULT;

  @override
  Widget build(BuildContext context) {
    final List<String> preferencesVariables =
        UserPreferencesModel.getVariables();
    return Material(
      child: ChangeNotifierProvider<UserPreferencesModel>(
        create: (BuildContext context) => UserPreferencesModel(context),
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
                          margin:
                              const EdgeInsets.only(top: 20.0, bottom: 24.0),
                          child: Text(
                            S.of(context).myPreferences,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(
                            preferencesVariables.length,
                            (int index) => _generatePreferenceRow(
                              preferencesVariables[index],
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
                                if (callback != null) {
                                  callback();
                                }
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

  Widget _generatePreferenceRow(String variable) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.black.withAlpha(5),
          borderRadius: const BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(UserPreferencesModel.getVariableName(variable)),
            ],
          ),
          Consumer<UserPreferencesModel>(
            builder: (BuildContext context,
                UserPreferencesModel userPreferencesModel, Widget child) {
              if (!userPreferencesModel.dataLoaded) {
                return Container();
              }
              return SliderTheme(
                data: SliderThemeData(
                  //thumbColor: Colors.black,
                  activeTrackColor: Colors.black54,
                  valueIndicatorColor:
                      getColor(userPreferencesModel.getStringValue(variable)),
                  trackHeight: 5.0,
                  inactiveTrackColor: Colors.black12,
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: Slider(
                  min: 0.0,
                  max: 3.0,
                  divisions: 3,
                  value:
                      userPreferencesModel.getScoreIndex(variable).toDouble(),
                  onChanged: (double value) =>
                      userPreferencesModel.setValue(variable, value.toInt()),
                  activeColor: Colors.black,
                  label: userPreferencesModel.getValueName(variable),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
