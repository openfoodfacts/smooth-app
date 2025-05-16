import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/edit_new_packagings_helper.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_text_field.dart';
import 'package:smooth_app/pages/product/simple_input_number_field.dart';

/// Edit display of a single [ProductPackaging] component.
class EditNewPackagingsComponent extends StatefulWidget {
  const EditNewPackagingsComponent({
    required this.title,
    required this.deleteCallback,
    required this.helper,
    required this.categories,
    required this.productType,
  });

  final String title;
  final VoidCallback deleteCallback;
  final EditNewPackagingsHelper helper;
  final String? categories;
  final ProductType? productType;

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
            _EditNumberLine(
              title: appLocalizations.edit_packagings_element_field_units,
              controller: widget.helper.controllerUnits,
              // this icon has 2 colors: we need 2 distinct files
              iconName: dark ? 'counter-dark' : 'counter-light',
              iconColor: null,
              decimal: false,
              numberFormat: widget.helper.unitNumberFormat,
            ),
            _EditTextLine(
              title: appLocalizations.edit_packagings_element_field_shape,
              controller: widget.helper.controllerShape,
              tagType: TagType.PACKAGING_SHAPES,
              iconName: 'shape',
              iconColor: iconColor,
              minLengthForSuggestions: 0,
              categories: widget.categories,
              productType: widget.productType,
            ),
            _EditTextLine(
              title: appLocalizations.edit_packagings_element_field_material,
              controller: widget.helper.controllerMaterial,
              tagType: TagType.PACKAGING_MATERIALS,
              iconName: 'material',
              iconColor: iconColor,
              hint: appLocalizations.edit_packagings_element_hint_material,
              minLengthForSuggestions: 0,
              categories: widget.categories,
              shapeProvider: () => widget.helper.controllerShape.text,
              productType: widget.productType,
            ),
            _EditTextLine(
              title: appLocalizations.edit_packagings_element_field_recycling,
              controller: widget.helper.controllerRecycling,
              tagType: TagType.PACKAGING_RECYCLING,
              iconName: 'recycling',
              iconColor: iconColor,
              productType: widget.productType,
            ),
            _EditTextLine(
              title: appLocalizations.edit_packagings_element_field_quantity,
              controller: widget.helper.controllerQuantity,
              iconName: 'quantity',
              iconColor: iconColor,
              productType: widget.productType,
            ),
            _EditNumberLine(
              title: appLocalizations.edit_packagings_element_field_weight,
              controller: widget.helper.controllerWeight,
              iconName: 'weight',
              iconColor: iconColor,
              hint: appLocalizations.edit_packagings_element_hint_weight,
              decimal: true,
              numberFormat: widget.helper.decimalNumberFormat,
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
class _EditTextLine extends StatefulWidget {
  const _EditTextLine({
    required this.title,
    required this.controller,
    required this.iconName,
    required this.iconColor,
    this.hint,
    this.tagType,
    this.minLengthForSuggestions = 1,
    this.categories,
    this.shapeProvider,
    required this.productType,
  });

  final String title;
  final TextEditingController controller;
  final TagType? tagType;
  final String iconName;
  final Color? iconColor;
  final String? hint;
  final int minLengthForSuggestions;
  final String? categories;
  final String? Function()? shapeProvider;
  final ProductType? productType;

  @override
  State<_EditTextLine> createState() => _EditTextLineState();
}

class _EditTextLineState extends State<_EditTextLine> {
  late final FocusNode _focusNode;
  final Key _autocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: SvgAsyncAsset(
              AssetCacheHelper(
                <String>['assets/packagings/${widget.iconName}.svg'],
                'no url for packagings/${widget.iconName}',
                color: widget.iconColor,
                width: MINIMUM_TOUCH_SIZE,
              ),
            ),
            title: Text(widget.title),
          ),
          LayoutBuilder(
            builder: (_, BoxConstraints constraints) => SizedBox(
              width: constraints.maxWidth,
              child: SimpleInputTextField(
                focusNode: _focusNode,
                autocompleteKey: _autocompleteKey,
                constraints: constraints,
                tagType: widget.tagType,
                hintText: '',
                controller: widget.controller,
                withClearButton: true,
                minLengthForSuggestions: widget.minLengthForSuggestions,
                categories: widget.categories,
                shapeProvider: widget.shapeProvider,
                productType: widget.productType,
              ),
            ),
          ),
          if (widget.hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: LARGE_SPACE),
              child: ExplanationWidget(widget.hint!),
            ),
        ],
      );
}

/// Edit display of a _number_ inside a [ProductPackaging], e.g. its weight.
class _EditNumberLine extends StatefulWidget {
  const _EditNumberLine({
    required this.title,
    required this.controller,
    required this.iconName,
    required this.iconColor,
    required this.decimal,
    required this.numberFormat,
    this.hint,
  });

  final String title;
  final TextEditingController controller;
  final String iconName;
  final Color? iconColor;
  final String? hint;
  final bool decimal;
  final NumberFormat numberFormat;

  @override
  State<_EditNumberLine> createState() => _EditNumberLineState();
}

class _EditNumberLineState extends State<_EditNumberLine> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: SvgAsyncAsset(
              AssetCacheHelper(
                <String>['assets/packagings/${widget.iconName}.svg'],
                'no url for packagings/${widget.iconName}',
                color: widget.iconColor,
                width: MINIMUM_TOUCH_SIZE,
              ),
            ),
            title: Text(widget.title),
          ),
          LayoutBuilder(
            builder: (_, BoxConstraints constraints) => SizedBox(
              width: constraints.maxWidth,
              child: SimpleInputNumberField(
                focusNode: _focusNode,
                constraints: constraints,
                hintText: '',
                controller: widget.controller,
                decimal: widget.decimal,
                withClearButton: true,
                numberFormat: widget.numberFormat,
                numberRegExp: SimpleInputNumberField.getNumberRegExp(
                  decimal: widget.decimal,
                ),
              ),
            ),
          ),
          if (widget.hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: LARGE_SPACE),
              child: ExplanationWidget(widget.hint!),
            ),
        ],
      );
}
