import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_attribute_group.dart';
import 'package:smooth_app/pages/preferences/user_preferences_food_search_helper.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/widgets/text/text_style_extensions.dart';

/// Collapsed/expanded display of attribute groups for the preferences page.
class UserPreferencesFood {
  UserPreferencesFood({
    required this.productPreferences,
    required this.context,
    required this.userPreferences,
    required this.appLocalizations,
    required this.themeData,
  });

  final ProductPreferences productPreferences;
  final BuildContext context;
  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;
  final ThemeData themeData;

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
    AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  String getTitleString() => appLocalizations.myPreferences_food_title;

  String? getHeaderAsset() => 'assets/onboarding/preferences.svg';

  Color? getHeaderColor() => const Color(0xFFEBF1FF);

  List<Widget>? getActions() => <Widget>[
    IconButton(
      icon: const Icon(Icons.rotate_left),
      onPressed: () async => _confirmReset(),
    ),
  ];

  List<UserPreferencesItem> getChildren() => <UserPreferencesItem>[
    // we don't want this on the onboarding
    UserPreferencesItemSimple(
      labels: <String>[appLocalizations.reset_food_prefs],
      builder: (final BuildContext context) => ListTile(
        title: Text(appLocalizations.reset_food_prefs),
        onTap: () async => _confirmReset(),
        leading: Icon(
          Icons.rotate_left,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    ),
    ..._getOnboardingBody(collapsed: false),
  ];

  List<AttributeGroup> _reorderGroups(List<AttributeGroup> groups) {
    final List<AttributeGroup> result = <AttributeGroup>[];
    for (final String id in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      result.addAll(groups.where((AttributeGroup g) => g.id == id));
    }
    result.addAll(
      groups.where(
        (AttributeGroup g) => !_ORDERED_ATTRIBUTE_GROUP_IDS.contains(g.id),
      ),
    );
    return result;
  }

  Future<void> _confirmReset() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalizations.confirmResetPreferences),
        positiveAction: SmoothActionButton(
          text: appLocalizations.yes,
          onPressed: () async {
            await context.read<ProductPreferences>().resetImportances();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.no,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Returns a slightly different version of [getContent] for the onboarding.
  List<Widget> getOnboardingContent() {
    final List<Widget> result = <Widget>[
      Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: LARGE_SPACE),
        child: Text(getTitleString(), style: themeData.textTheme.displayMedium),
      ),
    ];
    for (final UserPreferencesItem item in _getOnboardingBody()) {
      result.add(
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SMALL_SPACE,
          ),
          child: item.builder(context),
        ),
      );
    }
    return result;
  }

  List<UserPreferencesItem> _getOnboardingBody({final bool? collapsed}) {
    final List<AttributeGroup> groups = _reorderGroups(
      productPreferences.attributeGroups!,
    );
    final List<UserPreferencesItem> result = <UserPreferencesItem>[
      UserPreferencesItemSimple(
        labels: <String>[appLocalizations.myPreferences_food_comment],
        builder: (_) => ListTile(
          title: Text(
            appLocalizations.myPreferences_food_comment,
            style: WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED,
          ),
        ),
      ),
    ];
    for (final AttributeGroup group in groups) {
      result.addAll(
        UserPreferencesAttributeGroup(
          productPreferences: productPreferences,
          group: group,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        ).getItems(collapsed: collapsed),
      );
    }
    return result;
  }

  List<PreferenceTile> searchTiles(BuildContext context, String query) {
    final List<PreferenceTile> result = <PreferenceTile>[];
    final UserPreferencesFoodSearchHelper helper =
        UserPreferencesFoodSearchHelper(query);

    final List<AttributeGroup> groups = _reorderGroups(
      productPreferences.attributeGroups!,
    );

    if (helper.matches(<String?>[
      appLocalizations.myPreferences_food_title,
      appLocalizations.myPreferences_food_subtitle,
      appLocalizations.myPreferences_food_comment,
    ])) {
      result.add(
        helper.getPreferenceTile(
          title: appLocalizations.myPreferences_food_title,
          context: context,
        ),
      );
    }
    for (final AttributeGroup group in groups) {
      result.addAll(
        UserPreferencesAttributeGroup(
          productPreferences: productPreferences,
          group: group,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        ).searchTiles(context, helper),
      );
    }
    return result;
  }
}
