import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
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

  /// Current packagings.
  final List<ProductPackaging> _packagings = <ProductPackaging>[];

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
    if (widget.product.packagings == null) {
      return;
    }
    for (final ProductPackaging packaging in widget.product.packagings!) {
      _addPackaging(
        ProductPackaging()
          ..material = packaging.material
          ..shape = packaging.shape
          ..recycling = packaging.recycling
          ..quantityPerUnit = packaging.quantityPerUnit
          ..weightMeasured = packaging.weightMeasured
          ..numberOfUnits = packaging.numberOfUnits,
      );
    }
  }

  void _addPackaging(final ProductPackaging packaging) {
    _packagings.add(packaging);
    _controllerUnits.add(TextEditingController());
    _controllerShapes.add(TextEditingController());
    _controllerMaterials.add(TextEditingController());
    _controllerRecyclings.add(TextEditingController());
    _controllerQuantities.add(TextEditingController());
    _controllerWeights.add(TextEditingController());
  }

  void _removePackagingAt(final int index) {
    _packagings.removeAt(index);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> children = <Widget>[];
    int index = 0;
    for (final ProductPackaging packaging in _packagings) {
      // needed for deleteCallback (if not final, will take unreachable value)
      final int deleteIndex = index;
      children.add(
        _EditSinglePackagings(
          packaging: packaging,
          index: index,
          deleteCallback: () => setState(() => _removePackagingAt(deleteIndex)),
          controllerUnits: _controllerUnits[index],
          controllerShape: _controllerShapes[index],
          controllerMaterial: _controllerMaterials[index],
          controllerRecycling: _controllerRecyclings[index],
          controllerQuantity: _controllerQuantities[index],
          controllerWeight: _controllerWeights[index],
        ),
      );
      index++;
    }
    children.add(
      Padding(
        padding: const EdgeInsets.all(VERY_LARGE_SPACE),
        child: ElevatedButton.icon(
          label: Text(appLocalizations.edit_packagings_element_add),
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _addPackaging(ProductPackaging())),
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

  void _loadPackagingsFromControllers() {
    for (int i = 0; i < _packagings.length; i++) {
      final ProductPackaging packaging = _packagings[i];
      packaging.shape = _getLocalizedTag(_controllerShapes[i]);
      packaging.material = _getLocalizedTag(_controllerMaterials[i]);
      packaging.recycling = _getLocalizedTag(_controllerRecyclings[i]);
      packaging.quantityPerUnit = _getString(_controllerQuantities[i]);
      packaging.weightMeasured = double.tryParse(_controllerWeights[i]
          .text); // TODO(monsieurtanuki): handle the "not a number" case
      packaging.numberOfUnits = int.tryParse(_controllerUnits[i]
          .text); // TODO(monsieurtanuki): handle the "not a number" case
    }
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

  bool _hasPackagingsChanged() {
    if (widget.product.packagings == null) {
      return _packagings.isEmpty;
    }
    if (widget.product.packagings!.length != _packagings.length) {
      return true;
    }
    for (int i = 0; i < _packagings.length; i++) {
      if (_isPackagingDifferent(
        _packagings[i],
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
    _loadPackagingsFromControllers();
    final bool changed = _hasPackagingsChanged();
    if (!changed) {
      return true;
    }

    final Product changedProduct = Product(barcode: widget.product.barcode)
      ..packagings = _packagings;

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
    required this.packaging,
    required this.index,
    required this.deleteCallback,
    required this.controllerUnits,
    required this.controllerShape,
    required this.controllerMaterial,
    required this.controllerRecycling,
    required this.controllerQuantity,
    required this.controllerWeight,
  });

  final ProductPackaging packaging;
  final int index;
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
    if (packaging.numberOfUnits != null) {
      controllerUnits.text = '${packaging.numberOfUnits!}';
    }
    if (packaging.shape?.lcName != null) {
      controllerShape.text = (packaging.shape?.lcName)!;
    }
    if (packaging.material?.lcName != null) {
      controllerMaterial.text = (packaging.material?.lcName)!;
    }
    if (packaging.recycling?.lcName != null) {
      controllerRecycling.text = (packaging.recycling?.lcName)!;
    }
    if (packaging.quantityPerUnit != null) {
      controllerQuantity.text = packaging.quantityPerUnit!;
    }
    if (packaging.weightMeasured != null) {
      controllerWeight.text = '${packaging.weightMeasured!}';
    }
    return SmoothCard(
      color:
          Colors.grey[300], // TODO(monsieurtanuki): different color? +dark mode
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              appLocalizations.edit_packagings_element_title(index + 1),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteCallback,
            ),
          ),
          _EditLine(
            // TODO(monsieurtanuki): different display for numbers
            title: appLocalizations.edit_packagings_element_field_units,
            controller: controllerUnits,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_shape,
            controller: controllerShape,
            tagType: TagType.PACKAGING_SHAPES,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_material,
            controller: controllerMaterial,
            tagType: TagType.PACKAGING_MATERIALS,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_recycling,
            controller: controllerRecycling,
            tagType: TagType.PACKAGING_RECYCLING,
          ),
          _EditLine(
            title: appLocalizations.edit_packagings_element_field_quantity,
            controller: controllerQuantity,
          ),
          _EditLine(
            // TODO(monsieurtanuki): different display for numbers
            title: appLocalizations.edit_packagings_element_field_weight,
            controller: controllerWeight,
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
    this.tagType,
  });

  final String title;
  final TextEditingController controller;
  final TagType? tagType;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, BoxConstraints constraints) => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: constraints.maxWidth / 2,
              child: Text(title),
            ),
            SizedBox(
              width: constraints.maxWidth / 2,
              child: SimpleInputWidgetField(
                focusNode: FocusNode(),
                autocompleteKey: UniqueKey(),
                constraints: constraints,
                tagType: tagType,
                hintText: '',
                controller: controller,
              ),
            ),
          ],
        ),
      );
}
