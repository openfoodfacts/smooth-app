import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_text.dart';

/// Button that opens an "add nutrient" dialog.
///
/// The [nutritionContainer] will tell which nutrients can be added, and that's
/// where the "new" nutrient will eventually be added.
/// The [refreshParent] will refresh the parent widget when a nutrient is added.
class NutritionAddNutrientButton extends StatelessWidget {
  const NutritionAddNutrientButton({
    required this.onNutrientSelected,
  });

  final Function(OrderedNutrient nutrient) onNutrientSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCardHeaderButton(
      tooltip: appLocalizations.nutrition_page_add_nutrient,
      child: const icons.Add.circled(),
      onTap: () async {
        final NutritionContainerHelper nutritionContainer =
            context.read<NutritionContainerHelper>();
        final List<OrderedNutrient> leftovers = List<OrderedNutrient>.from(
          nutritionContainer.getLeftoverNutrients(),
        );
        leftovers.sort((final OrderedNutrient a, final OrderedNutrient b) =>
            a.name!.compareTo(b.name!));
        final List<OrderedNutrient> filteredList =
            List<OrderedNutrient>.from(leftovers);

        final OrderedNutrient? selected =
            await showSmoothModalSheetForTextField<OrderedNutrient>(
          context: context,
          header: SmoothModalSheetHeader(
            title: appLocalizations.nutrition_page_add_nutrient,
            prefix: const SmoothModalSheetHeaderPrefixIndicator(),
            suffix: const SmoothModalSheetHeaderCloseButton(),
          ),
          bodyBuilder: (BuildContext context) {
            return _NutrientList(list: filteredList);
          },
        );

        if (selected != null) {
          nutritionContainer.add(selected);
          onNutrientSelected.call(selected);
        }
      },
    );
  }
}

class _NutrientList extends StatefulWidget {
  const _NutrientList({
    required this.list,
  });

  final List<OrderedNutrient> list;

  @override
  State<_NutrientList> createState() => _NutrientListState();
}

class _NutrientListState extends State<_NutrientList> {
  final TextEditingController nutritionTextController = TextEditingController();

  late List<OrderedNutrient> _nutrients;

  @override
  void initState() {
    super.initState();
    _nutrients = List<OrderedNutrient>.of(widget.list);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.3,
          child: Scrollbar(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                final OrderedNutrient nutrient = _nutrients[index];
                return ListTile(
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: VERY_LARGE_SPACE,
                  ),
                  title: TextHighlighter(
                    text: nutrient.name!,
                    filter: nutritionTextController.text,
                  ),
                  onTap: () => Navigator.of(context).pop(nutrient),
                );
              },
              itemCount: _nutrients.length,
              shrinkWrap: true,
              separatorBuilder: (_, __) => const Divider(height: 1.0),
              reverse: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: MEDIUM_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: SmoothTextFormField(
            prefixIcon: const Icon(Icons.search),
            autofocus: true,
            hintText: appLocalizations.search,
            type: TextFieldTypes.PLAIN_TEXT,
            allowEmojis: false,
            maxLines: 1,
            controller: nutritionTextController,
            onChanged: (String? query) {
              setState(
                () => _nutrients = widget.list
                    .where(
                      (OrderedNutrient item) =>
                          item.name!.trim().getComparisonSafeString().contains(
                                query!.trim().getComparisonSafeString(),
                              ),
                    )
                    .toList(),
              );
            },
          ),
        ),

        /// Keyboard height or status bar height
        SizedBox(
          height: keyboardHeight > 0.0
              ? keyboardHeight
              : MediaQuery.viewPaddingOf(context).bottom,
        )
      ],
    );
  }
}
