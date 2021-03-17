// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';

// Project imports:
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/temp/preference_importance.dart';
import 'package:smooth_app/temp/product_preferences.dart';
import 'package:smooth_app/temp/user_preferences.dart';

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

  static void showModal(
    final BuildContext context, {
    final Function callback,
  }) =>
      showCupertinoModalBottomSheet<Widget>(
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        bounce: true,
        barrierColor: Colors.black45,
        builder: (BuildContext context) => UserPreferencesView(
          ModalScrollController.of(context),
          callback: callback,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final double buttonWidth =
        (screenSize.width - _TYPICAL_PADDING_OR_MARGIN * 3) / 2;
    return Material(
      child: Container(
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
                        productPreferences,
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
                            onPressed: () => userPreferences.resetImportances(
                              productPreferences,
                            ),
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
    final Attribute attribute,
    final double screenWidth,
    final ProductPreferences productPreferences,
  ) {
    final double iconWidth =
        (screenWidth - _TYPICAL_PADDING_OR_MARGIN * 5) * _PCT_ICON;
    final double sliderWidth =
        (screenWidth - _TYPICAL_PADDING_OR_MARGIN * 5) * (1 - _PCT_ICON);
    final PreferenceImportance importance =
        productPreferences.getPreferenceImportance(attribute.id);
    return Container(
      padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
      margin: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
      width: screenWidth,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(20.0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: iconWidth,
            child: SvgCache(attribute.iconUrl, width: iconWidth),
          ),
          Container(width: _TYPICAL_PADDING_OR_MARGIN),
          Container(
            width: sliderWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  attribute.settingName,
                ),
                SliderTheme(
                  data: SliderThemeData(
                    //thumbColor: Colors.red,
                    activeTrackColor: Colors.black54,
                    valueIndicatorColor: getColor(productPreferences
                        .getAttributeImportanceIndex(attribute.id)),
                    trackHeight: 5.0,
                    inactiveTrackColor: Colors.black12,
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: 3.0,
                    divisions: 3,
                    value: productPreferences
                        .getAttributeImportanceIndex(attribute.id)
                        .toDouble(),
                    onChanged: (double value) =>
                        productPreferences.saveImportance(
                      attribute.id,
                      value.toInt(),
                    ),
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
    final ProductPreferences productPreferences,
  ) {
    final List<AttributeGroup> groups = productPreferences.attributeGroups;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
          groups.length,
          (int index) => _generateGroup(
                context,
                groups[index],
                screenWidth,
                userPreferences,
                productPreferences,
              )),
    );
  }

  Widget _generateGroup(
    final BuildContext context,
    final AttributeGroup group,
    final double screenWidth,
    final UserPreferences userPreferences,
    final ProductPreferences productPreferences,
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
                            productPreferences,
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
            width: double.infinity,
            padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
            child: ListTile(
              title: Text(group.name),
              trailing: Icon(
                userPreferences.isAttributeGroupVisible(group)
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
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
