import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class UserPreferencesView extends StatelessWidget {
  const UserPreferencesView(this._scrollController, {this.callback});

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

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;
  static const double _PCT_ICON = .20;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final double buttonWidth =
        (screenSize.width - _TYPICAL_PADDING_OR_MARGIN * 3) / 2;
    return Material(
      child: Container(
        color: Theme.of(context).primaryColor,
        height: screenSize.height * 0.9,
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: screenSize.height * 0.9,
                  child: ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
                        child: Text(
                          AppLocalizations.of(context).myPreferences,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      _generateGroups(
                        context,
                        screenSize.width,
                        userPreferences,
                        userPreferencesModel,
                      ),
                      SizedBox(
                        height: screenSize.height * 0.15,
                      ),
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
                          horizontal: _TYPICAL_PADDING_OR_MARGIN,
                          vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SmoothMainButton(
                            text: 'Reset',
                            minWidth: buttonWidth,
                            important: false,
                            onPressed: () => userPreferences
                                .resetImportances(userPreferencesModel),
                          ),
                          SmoothMainButton(
                            text: 'OK',
                            minWidth: buttonWidth,
                            important: true,
                            onPressed: () {
                              Navigator.pop(context);
                              if (callback != null) {
                                callback();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _generatePreferenceRow(
    final BuildContext context,
    final Attribute variable,
    final double screenWidth,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) {
    final double iconWidth =
        (screenWidth - _TYPICAL_PADDING_OR_MARGIN * 5) * _PCT_ICON;
    final double sliderWidth =
        (screenWidth - _TYPICAL_PADDING_OR_MARGIN * 5) * (1 - _PCT_ICON);
    final PreferencesValue importance =
        userPreferencesModel.getPreferencesValue(
      variable.id,
      userPreferences,
    );
    return Container(
      padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
      margin: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
      width: screenWidth,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(20.0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: iconWidth,
            child: SvgPicture.network(
              variable.iconUrl,
              alignment: Alignment.centerLeft,
              width: iconWidth,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator()),
            ),
          ),
          Container(width: _TYPICAL_PADDING_OR_MARGIN),
          Container(
            width: sliderWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  variable.settingName,
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    //thumbColor: Colors.red,
                    activeTrackColor: Colors.black54,
                    valueIndicatorColor: getColor(userPreferencesModel
                        .getAttributeValueIndex(variable.id, userPreferences)),
                    trackHeight: 5.0,
                    inactiveTrackColor: Colors.black12,
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: 3.0,
                    divisions: 3,
                    value: userPreferencesModel
                        .getAttributeValueIndex(variable.id, userPreferences)
                        .toDouble(),
                    onChanged: (double value) => userPreferences.setImportance(
                        variable.id, value.toInt()),
                    activeColor: Theme.of(context).colorScheme.onSurface,
                    label: importance.name,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _generateGroups(
    final BuildContext context,
    final double screenWidth,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) {
    final List<AttributeGroup> groups = userPreferencesModel.attributeGroups;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
          groups.length,
          (int index) => _generateGroup(
                context,
                groups[index],
                screenWidth,
                userPreferences,
                userPreferencesModel,
              )),
    );
  }

  Widget _generateGroup(
    final BuildContext context,
    final AttributeGroup group,
    final double screenWidth,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) =>
      !userPreferences.isAttributeGroupVisible(group)
          ? _generateGroupTitle(context, group, userPreferences)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                group.attributes.length + 2,
                (int index) => index == 0
                    ? _generateGroupTitle(context, group, userPreferences)
                    : index == 1
                        ? _generateGroupWarning(group.warning)
                        : _generatePreferenceRow(
                            context,
                            group.attributes[index - 2],
                            screenWidth,
                            userPreferences,
                            userPreferencesModel,
                          ),
              ),
            );

  Widget _generateGroupTitle(
    final BuildContext context,
    final AttributeGroup group,
    final UserPreferences userPreferences,
  ) =>
      GestureDetector(
          child: Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
            child: Text(
              group.name,
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
          ),
          onTap: () => userPreferences.setAttributeGroupVisibility(
              group, !userPreferences.isAttributeGroupVisible(group)));

  Widget _generateGroupWarning(final String warning) => warning == null
      ? Container()
      : Container(
          color: Colors.deepOrange,
          width: double.infinity,
          padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
          margin: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
          child: Text(
            warning,
            style: const TextStyle(color: Colors.white),
          ),
        );
}
