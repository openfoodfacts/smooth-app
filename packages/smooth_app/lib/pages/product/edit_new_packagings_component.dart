import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/edit_new_packagings_helper.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/simple_input_widget.dart';

/// Edit display of a single [ProductPackaging] component.
class EditNewPackagingsComponent extends StatefulWidget {
  const EditNewPackagingsComponent({
    required this.title,
    required this.deleteCallback,
    required this.helper,
  });

  final String title;
  final VoidCallback deleteCallback;
  final EditNewPackagingsHelper helper;

  @override
  State<EditNewPackagingsComponent> createState() =>
      _EditNewPackagingsComponentState();
}

class _EditNewPackagingsComponentState
    extends State<EditNewPackagingsComponent> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = dark ? Colors.white : Colors.black;
    // TODO(monsieurtanuki): the title is not refreshed at each user input
    final String? title = widget.helper.getTitle();
    final List<Widget> expandedChildren = !widget.helper.expanded
        ? <Widget>[]
        : <Widget>[
            _EditLine(
              // TODO(monsieurtanuki): different display for numbers
              title: appLocalizations.edit_packagings_element_field_units,
              controller: widget.helper.controllerUnits,
              // this icon has 2 colors: we need 2 distinct files
              iconName: dark ? 'counter-dark' : 'counter-light',
              iconColor: null,
            ),
            _EditLine(
              title: appLocalizations.edit_packagings_element_field_shape,
              controller: widget.helper.controllerShape,
              tagType: TagType.PACKAGING_SHAPES,
              iconName: 'shape',
              iconColor: iconColor,
            ),
            _EditLine(
              title: appLocalizations.edit_packagings_element_field_material,
              controller: widget.helper.controllerMaterial,
              tagType: TagType.PACKAGING_MATERIALS,
              iconName: 'material',
              iconColor: iconColor,
              hint: appLocalizations.edit_packagings_element_hint_material,
            ),
            _EditLine(
              title: appLocalizations.edit_packagings_element_field_recycling,
              controller: widget.helper.controllerRecycling,
              tagType: TagType.PACKAGING_RECYCLING,
              iconName: 'recycling',
              iconColor: iconColor,
            ),
            _EditLine(
              title: appLocalizations.edit_packagings_element_field_quantity,
              controller: widget.helper.controllerQuantity,
              iconName: 'quantity',
              iconColor: iconColor,
            ),
            _EditLine(
              // TODO(monsieurtanuki): different display for numbers
              title: appLocalizations.edit_packagings_element_field_weight,
              controller: widget.helper.controllerWeight,
              iconName: 'weight',
              iconColor: iconColor,
              hint: appLocalizations.edit_packagings_element_hint_weight,
            ),
          ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: Icon(
            widget.helper.expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
          title: Text(title ?? widget.title),
          subtitle: title == null ? null : Text(widget.title),
          trailing: widget.helper.expanded
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.deleteCallback,
                )
              : null,
          onTap: () => setState(
            () => widget.helper.expanded = !widget.helper.expanded,
          ),
        ),
        ...expandedChildren,
      ],
    );
  }
}

/// Edit display of a single line inside a [ProductPackaging], e.g. its shape.
class _EditLine extends StatelessWidget {
  const _EditLine({
    required this.title,
    required this.controller,
    required this.iconName,
    required this.iconColor,
    this.hint,
    this.tagType,
  });

  final String title;
  final TextEditingController controller;
  final TagType? tagType;
  final String iconName;
  final Color? iconColor;
  final String? hint;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: SvgAsyncAsset(
              AssetCacheHelper(
                <String>['assets/packagings/$iconName.svg'],
                'no url for packagings/$iconName',
                color: iconColor,
                width: MINIMUM_TOUCH_SIZE,
              ),
            ),
            title: Text(title),
          ),
          LayoutBuilder(
            builder: (_, BoxConstraints constraints) => SizedBox(
              width: constraints.maxWidth,
              child: SimpleInputWidgetField(
                focusNode: FocusNode(),
                autocompleteKey: UniqueKey(),
                constraints: constraints,
                tagType: tagType,
                hintText: '',
                controller: controller,
                withClearButton: true,
              ),
            ),
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: LARGE_SPACE),
              child: ExplanationWidget(hint!),
            ),
        ],
      );
}
