import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/edit_new_packagings_component.dart';
import 'package:smooth_app/pages/product/edit_new_packagings_helper.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/simple_input_number_field.dart';
import 'package:smooth_app/themes/color_schemes.dart';
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
  late final NumberFormat _decimalNumberFormat;
  late final NumberFormat _unitNumberFormat;

  late bool? _packagingsComplete;

  final List<EditNewPackagingsHelper> _helpers = <EditNewPackagingsHelper>[];

  void _initPackagings() {
    if (widget.product.packagings != null) {
      widget.product.packagings!.forEach(_addPackagingToControllers);
    }
    _packagingsComplete = widget.product.packagingsComplete;
  }

  void _addPackagingToControllers(
    final ProductPackaging packaging, {
    final bool initiallyExpanded = false,
  }) {
    _helpers.add(
      EditNewPackagingsHelper.packaging(
        packaging,
        initiallyExpanded,
        decimalNumberFormat: _decimalNumberFormat,
        unitNumberFormat: _unitNumberFormat,
      ),
    );
  }

  void _removePackagingAt(final int index) {
    final EditNewPackagingsHelper helper = _helpers.removeAt(index);
    helper.dispose();
  }

  @override
  void initState() {
    super.initState();
    _decimalNumberFormat = SimpleInputNumberField.getNumberFormat(
      decimal: true,
    );
    _unitNumberFormat = SimpleInputNumberField.getNumberFormat(
      decimal: false,
    );
    _initPackagings();
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(widget.product.barcode!);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(widget.product.barcode!);
    for (final EditNewPackagingsHelper helper in _helpers) {
      helper.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> children = <Widget>[];
    for (int index = 0; index < _helpers.length; index++) {
      // needed for deleteCallback (if not final, will take unreachable value)
      final int deleteIndex = index;
      children.add(
        SmoothCard(
          color: _getSmoothCardColorAlternate(context, index),
          child: EditNewPackagingsComponent(
            title: appLocalizations.edit_packagings_element_title(index + 1),
            deleteCallback: () =>
                setState(() => _removePackagingAt(deleteIndex)),
            helper: _helpers[index],
          ),
        ),
      );
    }
    children.add(
      SmoothCard(
        color: _getSmoothCardColor(context),
        child: ListTile(
          title: Text(appLocalizations.edit_packagings_completed),
          trailing: Icon(
            _packagingsComplete == true
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
        padding: const EdgeInsets.only(
          top: VERY_LARGE_SPACE,
          left: SMALL_SPACE,
          right: SMALL_SPACE,
        ),
        child: addPanelButton(
          appLocalizations.edit_packagings_element_add.toUpperCase(),
          iconData: Icons.add,
          onPressed: () => setState(
            () => _addPackagingToControllers(
              ProductPackaging(),
              initiallyExpanded: true,
            ),
          ),
        ),
      ),
    );
    children.add(
      Padding(
        padding: const EdgeInsets.only(
          bottom: VERY_LARGE_SPACE,
          left: SMALL_SPACE,
          right: SMALL_SPACE,
        ),
        child: addPanelButton(
          appLocalizations.add_packaging_photo_button_label.toUpperCase(),
          onPressed: () async => confirmAndUploadNewPicture(
            this,
            imageField: ImageField.OTHER,
            barcode: widget.product.barcode!,
          ),
          iconData: Icons.add_a_photo,
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

  List<ProductPackaging> _getPackagingsFromControllers() {
    final List<ProductPackaging> result = <ProductPackaging>[];
    for (final EditNewPackagingsHelper helper in _helpers) {
      result.add(helper.getPackaging());
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
      if (!mounted) {
        return false;
      }
    }

    await BackgroundTaskDetails.addTask(
      changedProduct,
      widget: this,
      stamp: BackgroundTaskDetailsStamp.structuredPackaging,
    );
    return true;
  }
}

Color _getSmoothCardColor(final BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? GREY_COLOR
        : PRIMARY_GREY_COLOR;

Color _getSmoothCardColorAlternate(final BuildContext context, int index) {
  final bool lightTheme = Theme.of(context).brightness == Brightness.light;
  Color cardColor = Colors.white;
  if (lightTheme) {
    if (index.isOdd) {
      cardColor = GREY_COLOR;
    } else {
      cardColor = LIGHT_GREY_COLOR;
    }
  } else {
    if (index.isOdd) {
      cardColor = PRIMARY_GREY_COLOR;
    } else {
      cardColor = darkColorScheme.background;
    }
  }

  return cardColor;
}
