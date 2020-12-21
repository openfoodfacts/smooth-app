import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/food_preferences_model.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';

class FoodPreferencesView extends StatelessWidget {
  const FoodPreferencesView(this._scrollController, {this.callback});

  final ScrollController _scrollController;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider<FoodPreferencesModel>(
        create: (BuildContext context) => FoodPreferencesModel(),
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
                            UserPreferencesVariableExtension.getVariables()
                                .length,
                                (int index) => _generatePreferenceRow(
                              UserPreferencesVariableExtension.getVariables()
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
                        child: Consumer<FoodPreferencesModel>(
                          builder: (BuildContext context,
                              FoodPreferencesModel foodPreferencesModel,
                              Widget child) {
                            return SmoothMainButton(
                              text: S.of(context).saveButtonText,
                              onPressed: () {
                                foodPreferencesModel.saveUserPreferences();
                                Navigator.pop(context);
                                callback();
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

  Widget _generatePreferenceRow(UserPreferencesVariable variable) {
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
              Text(variable.name),
            ],
          ),
          Consumer<FoodPreferencesModel>(
            builder: (BuildContext context,
                FoodPreferencesModel foodPreferencesModel, Widget child) {
              if (foodPreferencesModel.dataLoaded) {
                return SliderTheme(
                  data: SliderThemeData(
                    //thumbColor: Colors.black,
                    activeTrackColor: Colors.black54,
                    valueIndicatorColor:
                    foodPreferencesModel.getVariable(variable).color,
                    trackHeight: 5.0,
                    inactiveTrackColor: Colors.black12,
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: 3.0,
                    divisions: 3,
                    value: foodPreferencesModel
                        .getVariable(variable)
                        .value
                        .toDouble(),
                    onChanged: (double value) => foodPreferencesModel
                        .setVariable(variable, value.toInt()),
                    activeColor: Colors.black,
                    label: foodPreferencesModel.getVariable(variable).label,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
