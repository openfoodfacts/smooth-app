import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off show Currency;
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_list_diff.dart';

/// A Settings button allowing to reorder and hide the action bar items
class ProductFooterSettingsButton extends StatelessWidget {
  const ProductFooterSettingsButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      icon: const icons.Personalization(),
      vibrate: true,
      tooltip:
          appLocalizations.product_page_action_bar_settings_accessibility_label,
      semanticsLabel:
          appLocalizations.product_page_action_bar_settings_accessibility_label,
      onTap: () => _openActionBarSettings(context, appLocalizations),
    );
  }

  Future<void> _openActionBarSettings(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) async {
    final double size = _computeContentSize(context);
    showSmoothModalSheet(
      context: context,
      minHeight: size,
      maxHeight: size,
      builder: (_) {
        return SmoothModalSheet(
          title: appLocalizations.product_page_action_bar_setting_modal_title,
          prefixIndicator: true,
          closeButton: true,
          expandBody: true,
          body: const _ProductActionBarModal(),
          bodyPadding: EdgeInsets.zero,
        );
      },
    );
  }

  /// Header + list padding + for each action: height + separator
  /// + bottom padding (nav bar)
  double _computeContentSize(BuildContext context) {
    return SmoothModalSheetHeader.MIN_HEIGHT +
        _ProductActionBarModalEditorState.PADDING.vertical +
        (_ProductActionBarModalItemEditorState.MIN_HEIGHT +
                _ProductActionBarModalEditorState.SEPARATOR_SIZE) *
            (ProductFooterActionBar.defaultOrder().length) +
        MediaQuery.viewPaddingOf(context).bottom;
  }
}

class _ProductActionBarModal extends StatelessWidget {
  const _ProductActionBarModal();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_ProductActionBarProvider>(
      create: (BuildContext context) => _ProductActionBarProvider(
        context.read<UserPreferences>(),
      ),
      child: Consumer<_ProductActionBarProvider>(builder: (
        BuildContext context,
        _ProductActionBarProvider provider,
        _,
      ) {
        return switch (provider.value) {
          _ProductActionBarLoadingState() =>
            const _ProductActionBarModalLoading(),
          _ProductActionBarChangedState() =>
            const _ProductActionBarModalEditor(),
        };
      }),
    );
  }
}

class _ProductActionBarModalLoading extends StatelessWidget {
  const _ProductActionBarModalLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class _ProductActionBarModalEditor extends StatefulWidget {
  const _ProductActionBarModalEditor();

  @override
  State<_ProductActionBarModalEditor> createState() =>
      _ProductActionBarModalEditorState();
}

class _ProductActionBarModalEditorState
    extends State<_ProductActionBarModalEditor> {
  static const EdgeInsetsDirectional PADDING =
      EdgeInsetsDirectional.all(MEDIUM_SPACE);
  static const double SEPARATOR_SIZE = MEDIUM_SPACE;

  @override
  Widget build(BuildContext context) {
    final List<_ProductActionBarEntry> entries = (context
            .watch<_ProductActionBarProvider>()
            .value as _ProductActionBarChangedState)
        .entries;

    return SmoothAnimatedList<_ProductActionBarEntry>(
      data: entries,
      itemBuilder: (
        BuildContext context,
        _ProductActionBarEntry entry,
        int index,
      ) {
        return KeyedSubtree(
          key: ValueKey<ProductFooterActionBar>(entry.action),
          child: _ProductActionBarModalItemEditor(
            entry: entry,
            position: index,
            canMoveUp: entry.visible && index > 0,
            canMoveDown: entry.visible &&
                (index < entries.length - 1 && entries[index + 1].visible),
          ),
        );
      },
      separatorSize: SEPARATOR_SIZE,
      padding: PADDING,
    );
  }
}

class _ProductActionBarModalItemEditor extends StatefulWidget {
  const _ProductActionBarModalItemEditor({
    required this.entry,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.position,
  });

  final _ProductActionBarEntry entry;
  final bool canMoveUp;
  final bool canMoveDown;
  final int position;

  @override
  State<_ProductActionBarModalItemEditor> createState() =>
      _ProductActionBarModalItemEditorState();
}

class _ProductActionBarModalItemEditorState
    extends State<_ProductActionBarModalItemEditor>
    with SingleTickerProviderStateMixin {
  static const double MIN_HEIGHT = 58.0;

  late AnimationController _controller;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.medium,
    );
  }

  @override
  void didUpdateWidget(covariant _ProductActionBarModalItemEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.entry.visible != oldWidget.entry.visible) {
      _controller.stop();

      final SmoothColorsThemeExtension extension =
          Theme.of(context).extension<SmoothColorsThemeExtension>()!;
      _colorAnimation = ColorTween(
        begin: _invisibleColor(extension),
        end: _visibleColor(extension),
      ).animate(_controller)
        ..addListener(() {
          setState(() {});
        });

      if (widget.entry.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  Color _visibleColor(SmoothColorsThemeExtension extension) {
    return context.lightTheme()
        ? extension.primaryMedium
        : extension.primaryLight;
  }

  Color _invisibleColor(SmoothColorsThemeExtension extension) {
    return context.lightTheme()
        ? extension.primaryLight
        : extension.primaryNormal;
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return AnimatedContainer(
      duration: SmoothAnimationsDuration.medium,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: MIN_HEIGHT),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _colorAnimation?.value ??
                (widget.entry.visible
                    ? _visibleColor(extension)
                    : _invisibleColor(extension)),
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: MEDIUM_SPACE,
              horizontal: LARGE_SPACE,
            ),
            child: Row(
              children: <Widget>[
                _ProductActionBarModalItemActionVisibility(
                  visible: widget.entry.visible,
                  onTap: () {
                    context
                        .read<_ProductActionBarProvider>()
                        .changeVisibility(widget.entry);

                    SmoothHapticFeedback.lightNotification();
                  },
                ),
                const SizedBox(width: VERY_LARGE_SPACE * 2),
                icons.AppIconTheme(
                  size: 22.0,
                  color: extension.primaryDark,
                  child: _icon,
                ),
                const SizedBox(width: LARGE_SPACE),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 0.5),
                    child: Text(
                      _text(AppLocalizations.of(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color:
                            context.darkTheme() ? extension.primaryBlack : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: MEDIUM_SPACE),
                _ProductActionBarModalItemActionMoveUp(
                  visible: widget.entry.visible,
                  enabled: widget.canMoveUp,
                  onTap: () {
                    context
                        .read<_ProductActionBarProvider>()
                        .reorderPosition(widget.position, widget.position - 1);

                    SmoothHapticFeedback.lightNotification();
                  },
                ),
                const SizedBox(width: SMALL_SPACE),
                _ProductActionBarModalItemActionMoveDown(
                  visible: widget.entry.visible,
                  enabled: widget.canMoveDown,
                  onTap: () {
                    context
                        .read<_ProductActionBarProvider>()
                        .reorderPosition(widget.position, widget.position + 1);

                    SmoothHapticFeedback.lightNotification();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _icon {
    return switch (widget.entry.action) {
      ProductFooterActionBar.addPrice => icons.AddPrice(off.Currency.USD),
      ProductFooterActionBar.edit => const icons.Edit(),
      ProductFooterActionBar.compare => const icons.Compare(),
      ProductFooterActionBar.addToList => const icons.AddToList.symbol(),
      ProductFooterActionBar.share => icons.Share(),
      ProductFooterActionBar.barcode => const icons.Barcode.rounded(),
      ProductFooterActionBar.openWebsite => const icons.ExternalLink(),
      ProductFooterActionBar.report => const icons.Flag(),
      ProductFooterActionBar.contributionGuide => const icons.Lifebuoy(),
      ProductFooterActionBar.dataQuality => const icons.CheckList(),
      ProductFooterActionBar.settings =>
        throw Exception('This item should not be displayed'),
    };
  }

  String _text(AppLocalizations appLocalizations) {
    return switch (widget.entry.action) {
      ProductFooterActionBar.addPrice => appLocalizations.prices_add_a_price,
      ProductFooterActionBar.edit => appLocalizations.edit_product_label_short,
      ProductFooterActionBar.compare =>
        appLocalizations.product_search_same_category_short,
      ProductFooterActionBar.addToList =>
        appLocalizations.user_list_button_add_product,
      ProductFooterActionBar.share => appLocalizations.share,
      ProductFooterActionBar.barcode =>
        appLocalizations.product_footer_action_barcode_short,
      ProductFooterActionBar.openWebsite =>
        appLocalizations.product_footer_action_open_website,
      ProductFooterActionBar.report =>
        appLocalizations.product_footer_action_report,
      ProductFooterActionBar.contributionGuide =>
        appLocalizations.product_footer_action_contributor_guide,
      ProductFooterActionBar.dataQuality =>
        appLocalizations.product_footer_action_data_quality_tags,
      ProductFooterActionBar.settings =>
        throw Exception('This item should not be displayed'),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ProductActionBarModalItemActionMoveUp extends StatelessWidget {
  const _ProductActionBarModalItemActionMoveUp({
    required this.visible,
    required this.enabled,
    required this.onTap,
  });

  final bool visible;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return _ProductActionBarModalItemAction(
      icon: const icons.Chevron.up(
        size: 14.0,
      ),
      semanticsLabel:
          AppLocalizations.of(context).product_page_action_bar_item_move_up,
      enabled: enabled,
      disabledColor: visible ? extension.primaryLight : extension.primaryMedium,
      onTap: enabled ? onTap : () {},
    );
  }
}

class _ProductActionBarModalItemActionMoveDown extends StatelessWidget {
  const _ProductActionBarModalItemActionMoveDown({
    required this.visible,
    required this.enabled,
    required this.onTap,
  });

  final bool visible;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return _ProductActionBarModalItemAction(
      icon: const icons.Chevron.down(
        size: 14.0,
      ),
      padding: const EdgeInsetsDirectional.only(top: 1.0),
      semanticsLabel:
          AppLocalizations.of(context).product_page_action_bar_item_move_down,
      enabled: enabled,
      disabledColor: visible ? extension.primaryLight : extension.primaryMedium,
      onTap: enabled ? onTap : () {},
    );
  }
}

class _ProductActionBarModalItemActionVisibility extends StatelessWidget {
  const _ProductActionBarModalItemActionVisibility({
    required this.visible,
    required this.onTap,
  });

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return _ProductActionBarModalItemAction(
      icon: visible
          ? const icons.Eye.visible(
              size: 20.0,
            )
          : const icons.Eye.invisible(
              size: 19.5,
            ),
      padding: EdgeInsetsDirectional.only(bottom: visible ? 0.0 : 1.0),
      semanticsLabel: visible
          ? localizations.product_page_action_bar_item_disable
          : localizations.product_page_action_bar_item_enable,
      enabledColor: (visible
          ? null
          : Theme.of(context).extension<SmoothColorsThemeExtension>()!.red),
      enabled: true,
      onTap: onTap,
    );
  }
}

class _ProductActionBarModalItemAction extends StatefulWidget {
  const _ProductActionBarModalItemAction({
    required this.icon,
    required this.semanticsLabel,
    required this.enabled,
    required this.onTap,
    this.padding,
    this.enabledColor,
    this.disabledColor,
  });

  final Widget icon;
  final EdgeInsetsGeometry? padding;
  final String semanticsLabel;
  final bool enabled;
  final Color? enabledColor;
  final Color? disabledColor;
  final VoidCallback onTap;

  @override
  State<_ProductActionBarModalItemAction> createState() =>
      _ProductActionBarModalItemActionState();
}

class _ProductActionBarModalItemActionState
    extends State<_ProductActionBarModalItemAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.medium,
    );
  }

  @override
  void didUpdateWidget(covariant _ProductActionBarModalItemAction oldWidget) {
    super.didUpdateWidget(oldWidget);

    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    Color? initColor;
    Color? endColor;

    if (widget.enabled != oldWidget.enabled) {
      initColor = oldWidget.enabled
          ? (oldWidget.enabledColor ?? _enabledColor(extension))
          : (oldWidget.disabledColor ?? _disabledColor(extension));
      endColor = widget.enabled
          ? (widget.enabledColor ?? _enabledColor(extension))
          : (widget.disabledColor ?? _disabledColor(extension));
    } else if (widget.enabledColor != oldWidget.enabledColor) {
      initColor = oldWidget.enabledColor ?? _enabledColor(extension);
      endColor = widget.enabledColor ?? _enabledColor(extension);
    } else if (widget.disabledColor != oldWidget.disabledColor) {
      initColor = oldWidget.disabledColor ?? _disabledColor(extension);
      endColor = widget.disabledColor ?? _disabledColor(extension);
    }

    if (initColor == null || endColor == null) {
      return;
    }

    _controller.stop();

    _colorAnimation = ColorTween(
      begin: initColor,
      end: endColor,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return Semantics(
      label: widget.semanticsLabel,
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: widget.semanticsLabel,
        preferBelow: false,
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: InkWell(
            onTap: widget.onTap,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 34.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colorAnimation?.value ??
                      (widget.enabled
                          ? widget.enabledColor ?? _enabledColor(extension)
                          : widget.disabledColor ?? _disabledColor(extension)),
                ),
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.zero,
                  child: Center(
                    child: widget.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _enabledColor(SmoothColorsThemeExtension extension) {
    return extension.primarySemiDark;
  }

  Color _disabledColor(SmoothColorsThemeExtension extension) {
    return extension.primaryMedium;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ProductActionBarProvider extends ValueNotifier<_ProductActionBarState> {
  _ProductActionBarProvider(this.preferences)
      : super(const _ProductActionBarLoadingState()) {
    _loadEntries();
  }

  final UserPreferences preferences;

  Future<void> _loadEntries() async {
    emit(const _ProductActionBarLoadingState());
    final List<ProductFooterActionBar> enabledActions =
        preferences.productPageActions;
    final Iterable<ProductFooterActionBar> disabledActions =
        ProductFooterActionBar.defaultOrder().where(
      (ProductFooterActionBar action) => !enabledActions.contains(action),
    );

    emit(
      _ProductActionBarChangedState(
        <_ProductActionBarEntry>[
          for (final ProductFooterActionBar action in enabledActions)
            _ProductActionBarEntry(
              action: action,
              visible: true,
            ),
          for (final ProductFooterActionBar action in disabledActions)
            _ProductActionBarEntry(
              action: action,
              visible: false,
            ),
        ],
      ),
    );
  }

  Future<void> changeVisibility(_ProductActionBarEntry entry) async {
    final List<_ProductActionBarEntry> currentEntries =
        (value as _ProductActionBarChangedState).entries;

    if (entry.visible) {
      // Move it to last position
      emit(
        _ProductActionBarChangedState(
          <_ProductActionBarEntry>[
            ...currentEntries.where((_ProductActionBarEntry e) => e != entry),
            entry.copyWith(visible: false),
          ],
        ),
      );
    } else {
      // Move it to the last visible position
      emit(
        _ProductActionBarChangedState(
          <_ProductActionBarEntry>[
            ...currentEntries
                .where((_ProductActionBarEntry e) => e != entry && e.visible),
            entry.copyWith(visible: true),
            ...currentEntries
                .where((_ProductActionBarEntry e) => e != entry && !e.visible),
          ],
        ),
      );
    }

    preferences.setProductPageActions((value as _ProductActionBarChangedState)
        .entries
        .where((_ProductActionBarEntry e) => e.visible)
        .map((_ProductActionBarEntry e) => e.action));
  }

  void reorderPosition(int oldPosition, int newPosition) {
    final List<_ProductActionBarEntry> currentEntries =
        (value as _ProductActionBarChangedState).entries;

    final int max =
        currentEntries.indexWhere((_ProductActionBarEntry e) => !e.visible);
    newPosition =
        math.min(newPosition, max == -1 ? currentEntries.length - 1 : max - 1);

    final _ProductActionBarEntry entry = currentEntries[oldPosition];
    final List<_ProductActionBarEntry> newEntries = <_ProductActionBarEntry>[
      ...currentEntries.where((_ProductActionBarEntry e) => e != entry),
    ];

    newEntries.insert(newPosition, entry);

    emit(
      _ProductActionBarChangedState(
        newEntries,
      ),
    );

    preferences.setProductPageActions((value as _ProductActionBarChangedState)
        .entries
        .where((_ProductActionBarEntry e) => e.visible)
        .map((_ProductActionBarEntry e) => e.action));
  }
}

sealed class _ProductActionBarState {
  const _ProductActionBarState();
}

class _ProductActionBarLoadingState extends _ProductActionBarState {
  const _ProductActionBarLoadingState();
}

class _ProductActionBarChangedState extends _ProductActionBarState {
  const _ProductActionBarChangedState(this.entries);

  final List<_ProductActionBarEntry> entries;
}

class _ProductActionBarEntry {
  _ProductActionBarEntry({
    required this.action,
    required this.visible,
  });

  final ProductFooterActionBar action;
  final bool visible;

  _ProductActionBarEntry copyWith({
    ProductFooterActionBar? action,
    bool? visible,
  }) {
    return _ProductActionBarEntry(
      action: action ?? this.action,
      visible: visible ?? this.visible,
    );
  }

  /// Equals is only done on action
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProductActionBarEntry &&
          runtimeType == other.runtimeType &&
          action == other.action;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => action.hashCode ^ visible.hashCode;

  @override
  String toString() {
    return '_ProductActionBarEntry{action: $action, visible: $visible}';
  }
}
