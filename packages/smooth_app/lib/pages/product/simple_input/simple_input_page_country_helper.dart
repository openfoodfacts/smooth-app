import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/country_selector/country.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

/// Implementation for "Countries" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageCountryHelper extends AbstractSimpleInputPageHelper {
  SimpleInputPageCountryHelper(UserPreferences? userPreferences)
    : _userCountryCode = userPreferences?.userCountryCode ?? 'fr';

  final String _userCountryCode;

  ValueNotifier<SimpleInputSuggestionsState> _suggestionsNotifier =
      ValueNotifier<SimpleInputSuggestionsState>(
        const SimpleInputSuggestionsLoading(),
      );
  final List<OpenFoodFactsCountry> _countries = OpenFoodFactsCountry.values;

  @override
  List<String> initTerms(final Product product) =>
      product.countriesTagsInLanguages?[getLanguage()] ?? <String>[];

  @override
  void reInit(final Product product, {final bool backgroundTask = false}) {
    super.reInit(product);

    if (backgroundTask) {
      return;
    }

    try {
      _suggestionsNotifier.notifyListeners();
    } catch (_) {
      // The Notifier was disposed
      _suggestionsNotifier = ValueNotifier<SimpleInputSuggestionsState>(
        const SimpleInputSuggestionsLoading(),
      );
    }

    _reloadSuggestions();
  }

  @override
  bool addItemsFromController(
    final TextEditingController controller, {
    bool clearController = true,
  }) {
    final bool result = super.addItemsFromController(
      controller,
      clearController: clearController,
    );
    if (result) {
      _reloadSuggestions();
    }
    return result;
  }

  @override
  void changeProduct(final Product changedProduct) {
    // for the temporary local change
    changedProduct.countriesTagsInLanguages =
        <OpenFoodFactsLanguage, List<String>>{getLanguage(): terms};
    // for the server - write-only
    changedProduct.countries = terms.join(separator);
  }

  @override
  ValueNotifier<SimpleInputSuggestionsState> getSuggestions() =>
      _suggestionsNotifier;

  Future<void> _reloadSuggestions() async {
    final OpenFoodFactsCountry? country = _countries.firstWhereOrNull(
      (OpenFoodFactsCountry country) => country.offTag == _userCountryCode,
    );

    if (country == null || containsTerm(country.localizedName) == true) {
      _suggestionsNotifier.value = const SimpleInputSuggestionsLoaded(
        suggestions: <String>[],
      );
      return;
    }

    _suggestionsNotifier.value = SimpleInputSuggestionsLoaded(
      suggestions: <String>[country.localizedName],
    );
  }

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_countries;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_country;

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_explanations_title;

  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return ExplanationBodyInfo(
      text:
          appLocalizations.edit_product_form_item_countries_explanations_info1,
      safeArea: true,
    );
  };

  @override
  TagType? getTagType() => TagType.COUNTRIES;

  @override
  Widget getIcon() => const icons.Countries(size: 20.0);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.countries;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() => AnalyticsEditEvents.country;

  @override
  InsightType? get robotoffInsightType => null;

  @override
  void dispose() {
    try {
      _suggestionsNotifier.dispose();
    } catch (_) {
      // The Notifier was already disposed
    }
    super.dispose();
  }
}
