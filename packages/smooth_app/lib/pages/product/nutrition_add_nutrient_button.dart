import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/OrderedNutrient.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/product/nutrition_container.dart';
import 'package:smooth_app/pages/text_field_helper.dart';

/// Button that opens an "add nutrient" dialog.
///
/// The [nutritionContainer] will tell which nutrients can be added, and that's
/// where the "new" nutrient will eventually be added.
/// The [refreshParent] will refresh the parent widget when a nutrient is added.
class NutritionAddNutrientButton extends StatelessWidget {
  const NutritionAddNutrientButton({
    required this.nutritionContainer,
    required this.refreshParent,
  });

  final NutritionContainer nutritionContainer;
  final VoidCallback refreshParent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return ElevatedButton.icon(
      onPressed: () async {
        final List<OrderedNutrient> leftovers = List<OrderedNutrient>.from(
          nutritionContainer.getLeftoverNutrients(),
        );
        leftovers.sort((final OrderedNutrient a, final OrderedNutrient b) =>
            a.name!.compareTo(b.name!));
        List<OrderedNutrient> filteredList =
            List<OrderedNutrient>.from(leftovers);
        final TextEditingControllerWithInitialValue nutritionTextController =
            TextEditingControllerWithInitialValue();
        final OrderedNutrient? selected = await showDialog<OrderedNutrient>(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (
              BuildContext context,
              void Function(VoidCallback fn) setState,
            ) =>
                SmoothAlertDialog(
              body: SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    SmoothTextFormField(
                      prefixIcon: const Icon(Icons.search),
                      hintText: appLocalizations.search,
                      type: TextFieldTypes.PLAIN_TEXT,
                      controller: nutritionTextController,
                      onChanged: (String? query) => setState(
                        () => filteredList = leftovers
                            .where((OrderedNutrient item) => item.name!
                                .toLowerCase()
                                .contains(query!.toLowerCase()))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          final OrderedNutrient nutrient = filteredList[index];
                          return ListTile(
                            title: Text(nutrient.name!),
                            onTap: () => Navigator.of(context).pop(nutrient),
                          );
                        },
                        itemCount: filteredList.length,
                        shrinkWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              positiveAction: SmoothActionButton(
                onPressed: () => Navigator.pop(context),
                text: appLocalizations.cancel,
              ),
            ),
          ),
        );
        if (selected != null) {
          nutritionContainer.add(selected);
          refreshParent.call();
        }
      },
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: ROUNDED_BORDER_RADIUS,
            side: BorderSide.none,
          ),
        ),
      ),
      icon: const Icon(Icons.add),
      label: Text(appLocalizations.nutrition_page_add_nutrient),
    );
  }
}
