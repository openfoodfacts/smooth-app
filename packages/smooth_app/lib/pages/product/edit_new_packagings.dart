import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/simple_input_widget.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Edit display of a product packagings (the new api V3 version).
class EditNewPackagings extends StatefulWidget {
  const EditNewPackagings({
    required this.product,
  });

  final Product product;

  @override
  State<EditNewPackagings> createState() => _EditNewPackagingsState();
}

class _EditNewPackagingsState extends State<EditNewPackagings> {
  late final LocalDatabase _localDatabase;

  late bool? _packagingsComplete;

  final List<TextEditingController> _controllerUnits =
      <TextEditingController>[];
  final List<TextEditingController> _controllerShapes =
      <TextEditingController>[];
  final List<TextEditingController> _controllerMaterials =
      <TextEditingController>[];
  final List<TextEditingController> _controllerRecyclings =
      <TextEditingController>[];
  final List<TextEditingController> _controllerQuantities =
      <TextEditingController>[];
  final List<TextEditingController> _controllerWeights =
      <TextEditingController>[];

  void _initPackagings() {
    if (widget.product.packagings != null) {
      widget.product.packagings!.forEach(_addPackagingToControllers);
    }
    _packagingsComplete = widget.product.packagingsComplete;
  }

  void _addPackagingToControllers(final ProductPackaging packaging) {
    _controllerUnits.add(
      TextEditingController(
        text: packaging.numberOfUnits == null
            ? null
            : '${packaging.numberOfUnits!}',
      ),
    );
    _controllerShapes.add(
      TextEditingController(
        text:
            packaging.shape?.lcName == null ? null : (packaging.shape?.lcName)!,
      ),
    );
    _controllerMaterials.add(
      TextEditingController(
        text: packaging.material?.lcName == null
            ? null
            : (packaging.material?.lcName)!,
      ),
    );
    _controllerRecyclings.add(
      TextEditingController(
        text: packaging.recycling?.lcName == null
            ? null
            : (packaging.recycling?.lcName)!,
      ),
    );
    _controllerQuantities.add(
      TextEditingController(text: packaging.quantityPerUnit),
    );
    _controllerWeights.add(
      TextEditingController(
        text: packaging.weightMeasured == null
            ? null
            : '${packaging.weightMeasured!}',
      ),
    );
  }

  void _removePackagingAt(final int index) {
    _controllerUnits.removeAt(index);
    _controllerShapes.removeAt(index);
    _controllerMaterials.removeAt(index);
    _controllerRecyclings.removeAt(index);
    _controllerQuantities.removeAt(index);
    _controllerWeights.removeAt(index);
  }

  @override
  void initState() {
    super.initState();
    _initPackagings();
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(widget.product.barcode!);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(widget.product.barcode!);
    for (int i = 0; i < _controllerUnits.length; i++) {
      _controllerUnits[i].dispose();
      _controllerShapes[i].dispose();
      _controllerMaterials[i].dispose();
      _controllerRecyclings[i].dispose();
      _controllerQuantities[i].dispose();
      _controllerWeights[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> children = <Widget>[];
    for (int index = 0; index < _controllerUnits.length; index++) {
      // needed for deleteCallback (if not final, will take unreachable value)
      final int deleteIndex = index;
      children.add(
        _EditSinglePackagings(
          title: appLocalizations.edit_packagings_element_title(index + 1),
          deleteCallback: () => setState(() => _removePackagingAt(deleteIndex)),
          controllerUnits: _controllerUnits[index],
          controllerShape: _controllerShapes[index],
          controllerMaterial: _controllerMaterials[index],
          controllerRecycling: _controllerRecyclings[index],
          controllerQuantity: _controllerQuantities[index],
          controllerWeight: _controllerWeights[index],
        ),
      );
    }
    children.add(
      SmoothCard(
        color: _getSmoothCardColor(context),
        child: ListTile(
          title: Text(appLocalizations.edit_packagings_completed),
          trailing: Icon(
            _packagingsComplete == null
                ? Icons.indeterminate_check_box
                : _packagingsComplete == true
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
          ),
          onTap: () => setState(
            () {
              if (_packagingsComplete == null) {
                _packagingsComplete = true;
              } else {
                _packagingsComplete = !_packagingsComplete!;
              }
            },
          ),
        ),
      ),
    );
    children.add(
      Padding(
        padding: const EdgeInsets.all(VERY_LARGE_SPACE),
        child: ElevatedButton.icon(
          label: Text(appLocalizations.edit_packagings_element_add),
          icon: const Icon(Icons.add),
          onPressed: () =>
              setState(() => _addPackagingToControllers(ProductPackaging())),
        ),
      ),
    );
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
        child: SmoothActionButtonsBar(
          axis: Axis.horizontal,
          positiveAction: SmoothActionButton(
            text: appLocalizations.save,
            onPressed: () async => _exitPage(
              await _mayExitPage(saving: true),
            ),
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.cancel,
            onPressed: () async => _exitPage(
              await _mayExitPage(saving: false),
            ),
          ),
        ),
      ),
    );
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text(appLocalizations.edit_packagings_title),
          subTitle: widget.product.productName != null
              ? Text(
                  widget.product.productName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: LARGE_SPACE),
          children: children,
        ),
      ),
    );
  }

  /// Exits the page if the [flag] is `true`.
  void _exitPage(final bool flag) {
    if (flag) {
      Navigator.of(context).pop();
    }
  }

  LocalizedTag? _getLocalizedTag(final TextEditingController controller) {
    final String text = controller.text;
    if (text.isEmpty) {
      return null;
    }
    return LocalizedTag()..lcName = text;
  }

  String? _getString(final TextEditingController controller) {
    final String text = controller.text;
    if (text.isEmpty) {
      return null;
    }
    return text;
  }

  List<ProductPackaging> _getPackagingsFromControllers() {
    final List<ProductPackaging> result = <ProductPackaging>[];
    for (int i = 0; i < _controllerUnits.length; i++) {
      final ProductPackaging packaging = ProductPackaging();
      packaging.shape = _getLocalizedTag(_controllerShapes[i]);
      packaging.material = _getLocalizedTag(_controllerMaterials[i]);
      packaging.recycling = _getLocalizedTag(_controllerRecyclings[i]);
      packaging.quantityPerUnit = _getString(_controllerQuantities[i]);
      packaging.weightMeasured = double.tryParse(_controllerWeights[i]
          .text); // TODO(monsieurtanuki): handle the "not a number" case
      packaging.numberOfUnits = int.tryParse(_controllerUnits[i]
          .text); // TODO(monsieurtanuki): handle the "not a number" case
      result.add(packaging);
    }
    return result;
  }

  bool _isPackagingDifferent(
    final ProductPackaging p1,
    final ProductPackaging p2,
  ) =>
      p1.shape?.lcName != p2.shape?.lcName ||
      p1.material?.lcName != p2.material?.lcName ||
      p1.recycling?.lcName != p2.recycling?.lcName ||
      p1.quantityPerUnit != p2.quantityPerUnit ||
      p1.weightMeasured != p2.weightMeasured ||
      p1.numberOfUnits != p2.numberOfUnits;

  bool _hasPackagingsChanged(final List<ProductPackaging> packagings) {
    if (widget.product.packagings == null) {
      return packagings.isNotEmpty;
    }
    if (widget.product.packagings!.length != packagings.length) {
      return true;
    }
    for (int i = 0; i < packagings.length; i++) {
      if (_isPackagingDifferent(
        packagings[i],
        widget.product.packagings![i],
      )) {
        return true;
      }
    }
    return false;
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    final Product changedProduct = Product(barcode: widget.product.barcode);
    bool changed = false;

    final List<ProductPackaging> packagings = _getPackagingsFromControllers();
    if (_hasPackagingsChanged(packagings)) {
      changed = true;
      changedProduct.packagings = packagings;
    }

    if (_packagingsComplete != widget.product.packagingsComplete) {
      changed = true;
      changedProduct.packagingsComplete = _packagingsComplete;
    }

    if (!changed) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(context);
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
    }
    await BackgroundTaskDetails.addTask(
      changedProduct,
      widget: this,
    );
    return true;
  }
}

/// Edit display of a single [ProductPackaging].
class _EditSinglePackagings extends StatelessWidget {
  const _EditSinglePackagings({
    required this.title,
    required this.deleteCallback,
    required this.controllerUnits,
    required this.controllerShape,
    required this.controllerMaterial,
    required this.controllerRecycling,
    required this.controllerQuantity,
    required this.controllerWeight,
  });

  final String title;
  final VoidCallback deleteCallback;
  final TextEditingController controllerUnits;
  final TextEditingController controllerShape;
  final TextEditingController controllerMaterial;
  final TextEditingController controllerRecycling;
  final TextEditingController controllerQuantity;
  final TextEditingController controllerWeight;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = dark ? Colors.white : Colors.black;
    return SmoothCard(
      color: _getSmoothCardColor(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(title),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteCallback,
            ),
          ),
          _EditLine(
            // TODO(monsieurtanuki): different display for numbers
            title: appLocalizations.edit_packagings_element_field_units,
            controller: controllerUnits,
            // this icon has 2 colors: we need 2 distinct files
            iconName: dark ? 'counter-dark' : 'counter-light',
            iconColor: null,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_shape,
            controller: controllerShape,
            tagType: TagType.PACKAGING_SHAPES,
            iconName: 'shape',
            iconColor: iconColor,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_material,
            controller: controllerMaterial,
            tagType: TagType.PACKAGING_MATERIALS,
            iconName: 'material',
            iconColor: iconColor,
            hint: appLocalizations.edit_packagings_element_hint_material,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_recycling,
            controller: controllerRecycling,
            tagType: TagType.PACKAGING_RECYCLING,
            iconName: 'recycling',
            iconColor: iconColor,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_quantity,
            controller: controllerQuantity,
            iconName: 'quantity',
            iconColor: iconColor,
          ),
          _EditLine(
            // TODO(monsieurtanuki): different display for numbers
            title: appLocalizations.edit_packagings_element_field_weight,
            controller: controllerWeight,
            iconName: 'weight',
            iconColor: iconColor,
            hint: appLocalizations.edit_packagings_element_hint_weight,
          ),
        ],
      ),
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

Color _getSmoothCardColor(final BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? GREY_COLOR
        : PRIMARY_GREY_COLOR;
