import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';

/// Implementation for "Traces" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageTraceHelper extends AbstractSimpleInputPageHelper {
  @override
  bool isOwnerField(final Product product) =>
      product.getOwnerFieldTimestamp(
        OwnerField.productField(
          ProductField.TRACES,
          ProductQuery.getLanguage(),
        ),
      ) !=
      null;

  @override
  List<String> initTerms(final Product product) =>
      product.tracesTagsInLanguages?[getLanguage()] ?? <String>[];

  @override
  void changeProduct(final Product changedProduct) {
    // for the local change
    changedProduct.tracesTagsInLanguages =
        <OpenFoodFactsLanguage, List<String>>{getLanguage(): terms};
    // for the server - write-only
    changedProduct.traces = terms.join(separator);
  }

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_traces_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_traces;

  @override
  String? getAddExplanationsTitle(AppLocalizations appLocalizations) => null;

  @override
  WidgetBuilder? getAddExplanationsContent() => null;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_traces_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_trace;

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_traces_type;

  @override
  TagType? getTagType() => TagType.TRACES;

  @override
  Widget getIcon() => const Icon(Icons.photo_size_select_small_sharp);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.traces;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() => AnalyticsEditEvents.traces;
}
