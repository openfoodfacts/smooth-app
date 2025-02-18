import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_selector_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

class SmoothSelectorScreen<T> extends StatelessWidget {
  const SmoothSelectorScreen({
    required this.provider,
    required this.title,
    required this.itemBuilder,
    required this.itemsFilter,
    this.onSave,
    super.key,
  });

  final PreferencesSelectorProvider<T> provider;
  final String title;
  final Function(T value)? onSave;
  final Widget Function(
    BuildContext context,
    T value,
    bool selected,
    String filter,
  ) itemBuilder;
  final Iterable<T> Function(
    List<T> list,
    T? selectedItem,
    T? selectedItemOverride,
    String filter,
  ) itemsFilter;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ListenableProvider<PreferencesSelectorProvider<T>>.value(
          value: provider,
        ),
        ChangeNotifierProvider<TextEditingController>(
          create: (_) => TextEditingController(),
        ),
      ],
      child: ValueNotifierListener<PreferencesSelectorProvider<T>,
          PreferencesSelectorState<T>>(
        listenerWithValueNotifier: _onValueChanged,
        child: SmoothScaffold2(
          topBar: SmoothTopBar2(
            title: title,
            leadingAction: provider.autoValidate
                ? SmoothTopBarLeadingAction.minimize
                : SmoothTopBarLeadingAction.close,
            elevationOnScroll: false,
          ),
          bottomBar: !provider.autoValidate
              ? _SmoothSelectorScreenBottomBar<T>(
                  onSave: () {
                    provider.saveSelectedItem();

                    if (provider.value is PreferencesSelectorEditingState<T>) {
                      Navigator.of(context).pop(
                        (provider.value as PreferencesSelectorEditingState<T>)
                            .selectedItemOverride,
                      );
                    }
                  },
                )
              : null,
          injectPaddingInBody: false,
          children: <Widget>[
            const _SmoothSelectorScreenSearchBar(),
            const SliverPadding(
              padding: EdgeInsetsDirectional.only(
                top: SMALL_SPACE,
              ),
            ),
            _SmoothSelectorScreenList<T>(
              itemsFilter: itemsFilter,
              itemBuilder: itemBuilder,
            ),
          ],
        ),
      ),
    );
  }

  /// When the value changed in [autoValidate] mode, we close the screen
  void _onValueChanged(
    BuildContext context,
    PreferencesSelectorProvider<T> provider,
    PreferencesSelectorState<T>? oldValue,
    PreferencesSelectorState<T> currentValue,
  ) {
    if (provider.autoValidate &&
        oldValue != null &&
        currentValue is! PreferencesSelectorEditingState<T> &&
        currentValue is PreferencesSelectorLoadedState<T>) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final NavigatorState navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop(currentValue.selectedItem);
        }
      });
    }
  }
}

class _SmoothSelectorScreenSearchBar extends StatelessWidget {
  const _SmoothSelectorScreenSearchBar();

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _SmoothSelectorScreenSearchBarDelegate(),
    );
  }
}

class _SmoothSelectorScreenSearchBarDelegate
    extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final bool darkMode = context.darkTheme();

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
        ),
        child: TextFormField(
          controller: context.read<TextEditingController>(),
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontSize: 15.0,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).search,
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(
                color: colors.primaryNormal,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide(
                color: darkMode ? colors.primaryNormal : colors.primarySemiDark,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsetsDirectional.only(
              start: 100,
              end: SMALL_SPACE,
              top: 10,
              bottom: 0,
            ),
            prefixIcon: icons.Search(
              size: 20.0,
              color: darkMode ? colors.primaryNormal : colors.primarySemiDark,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  bool shouldRebuild(
          covariant _SmoothSelectorScreenSearchBarDelegate oldDelegate) =>
      false;
}

class _SmoothSelectorScreenBottomBar<T> extends StatelessWidget {
  const _SmoothSelectorScreenBottomBar({
    required this.onSave,
  });

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ConsumerValueNotifierFilter<PreferencesSelectorProvider<T>,
        PreferencesSelectorState<T>>(
      builder: (
        BuildContext context,
        PreferencesSelectorState<T> value,
        _,
      ) {
        if (value is! PreferencesSelectorEditingState) {
          return EMPTY_WIDGET;
        }

        final SmoothColorsThemeExtension colors =
            context.extension<SmoothColorsThemeExtension>();

        return SmoothButtonsBar2(
          animate: true,
          backgroundColor: context.lightTheme()
              ? colors.primaryMedium
              : colors.primaryUltraBlack,
          positiveButton: SmoothActionButton2(
            text: AppLocalizations.of(context).validate,
            icon: const icons.Arrow.right(),
            onPressed: onSave,
          ),
        );
      },
    );
  }
}

class _SmoothSelectorScreenList<T> extends StatefulWidget {
  const _SmoothSelectorScreenList({
    required this.itemsFilter,
    required this.itemBuilder,
  });

  final Iterable<T> Function(
    List<T> list,
    T? selectedItem,
    T? selectedItemOverride,
    String filter,
  ) itemsFilter;
  final Widget Function(
    BuildContext context,
    T value,
    bool selected,
    String filter,
  ) itemBuilder;

  @override
  State<_SmoothSelectorScreenList<T>> createState() =>
      _SmoothSelectorScreenListState<T>();
}

class _SmoothSelectorScreenListState<T>
    extends State<_SmoothSelectorScreenList<T>> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PreferencesSelectorProvider<T>, TextEditingController>(
      builder: (
        BuildContext context,
        PreferencesSelectorProvider<T> provider,
        TextEditingController controller,
        _,
      ) {
        final PreferencesSelectorLoadedState<T> state =
            provider.value as PreferencesSelectorLoadedState<T>;
        final T? selectedItem = state is PreferencesSelectorEditingState
            ? (state as PreferencesSelectorEditingState<T>).selectedItemOverride
            : state.selectedItem;

        final Iterable<T> values = widget.itemsFilter(
          state.items,
          state.selectedItem,
          selectedItem,
          controller.text,
        );

        return SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final T value = values.elementAt(index);
              final bool selected = selectedItem == value;

              return _SmoothSelectorScreenListItem<T>(
                builder: widget.itemBuilder,
                item: value,
                selected: selected,
                filter: controller.text,
              );
            },
            childCount: values.length,
            addAutomaticKeepAlives: false,
          ),
          itemExtent: 60.0,
        );
      },
    );
  }
}

class _SmoothSelectorScreenListItem<T> extends StatelessWidget {
  const _SmoothSelectorScreenListItem({
    required this.item,
    required this.builder,
    required this.selected,
    required this.filter,
  });

  final Widget Function(
    BuildContext context,
    T value,
    bool selected,
    String filter,
  ) builder;

  final T item;
  final bool selected;
  final String filter;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final PreferencesSelectorProvider<T> provider =
        context.watch<PreferencesSelectorProvider<T>>();

    return Semantics(
      value: item.toString(),
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: SmoothAnimationsDuration.short,
        margin: const EdgeInsetsDirectional.only(
          start: SMALL_SPACE,
          end: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        decoration: BoxDecoration(
          borderRadius: ANGULAR_BORDER_RADIUS,
          border: Border.all(
            color: selected ? colors.secondaryLight : colors.primaryMedium,
            width: selected ? 3.0 : 1.0,
          ),
          color: selected
              ? context.darkTheme()
                  ? colors.primarySemiDark
                  : colors.primaryLight
              : Colors.transparent,
        ),
        child: InkWell(
          borderRadius: ANGULAR_BORDER_RADIUS,
          onTap: () => provider.changeSelectedItem(item),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SMALL_SPACE,
              vertical: VERY_SMALL_SPACE,
            ),
            child: builder(context, item, selected, filter),
          ),
        ),
      ),
    );
  }
}
