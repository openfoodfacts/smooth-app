import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_attribute_group.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Collapsed/expanded display of attribute groups for the preferences page.
class UserPreferencesFood extends AbstractUserPreferences {
  UserPreferencesFood({
    required this.productPreferences,
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

  final ProductPreferences productPreferences;

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
    AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.FOOD;

  @override
  String getTitleString() => appLocalizations.myPreferences_food_title;

  @override
  String getSubtitleString() => appLocalizations.myPreferences_food_subtitle;

  @override
  IconData getLeadingIconData() => Icons.ramen_dining;

  @override
  String? getHeaderAsset() => 'assets/onboarding/preferences.svg';

  @override
  Color? getHeaderColor() => const Color(0xFFEBF1FF);

  @override
  List<UserPreferencesItem> getChildren() => <UserPreferencesItem>[
        // we don't want this on the onboarding
        UserPreferencesItemTile(
          leading: UserPreferencesListTile.getTintedIcon(
            Icons.rotate_left,
            context,
          ),
          title: appLocalizations.reset_food_prefs,
          onTap: () async => _confirmReset(),
        ),
        ..._getOnboardingBody(collapsed: false)
      ];

  List<AttributeGroup> _reorderGroups(List<AttributeGroup> groups) {
    final List<AttributeGroup> result = <AttributeGroup>[];
    for (final String id in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      result.addAll(groups.where((AttributeGroup g) => g.id == id));
    }
    result.addAll(groups.where(
        (AttributeGroup g) => !_ORDERED_ATTRIBUTE_GROUP_IDS.contains(g.id)));
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
              Navigator.pop(context);
            }
          },
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.no,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  /// Returns a slightly different version of [getContent] for the onboarding.
  List<Widget> getOnboardingContent() {
    final List<Widget> result = <Widget>[
      Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LARGE_SPACE,
        ),
        child: Text(
          getTitleString(),
          style: themeData.textTheme.displayMedium,
        ),
      ),
    ];
    for (final UserPreferencesItem item in _getOnboardingBody()) {
      result.add(Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SMALL_SPACE,
        ),
        child: item.builder(context),
      ));
    }
    return result;
  }

  List<UserPreferencesItem> _getOnboardingBody({final bool? collapsed}) {
    final List<AttributeGroup> groups =
        _reorderGroups(productPreferences.attributeGroups!);
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
}
