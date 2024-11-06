import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A dashed line
class UserPreferencesListItemDivider extends StatelessWidget {
  const UserPreferencesListItemDivider({
    this.margin,
    super.key,
  });

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
          ),
      child: CustomPaint(
        size: const Size(
          double.infinity,
          1.0,
        ),
        painter: _DashedLinePainter(
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required Color color,
  }) : _paint = Paint()
          ..color = color
          ..strokeWidth = 1.0;

  static const double _DASHED_WIDTH = 3.0;
  static const double _DASHED_SPACE = 3.0;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + _DASHED_WIDTH, 0),
        _paint,
      );

      startX += _DASHED_WIDTH + _DASHED_SPACE;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class UserPreferencesSwitchWidget extends StatelessWidget {
  const UserPreferencesSwitchWidget({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        title: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: SMALL_SPACE,
            bottom: SMALL_SPACE,
          ),
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: SMALL_SPACE,
                ),
                child: Text(
                  subtitle!,
                  style: const TextStyle(height: 1.5),
                ),
              ),
        activeColor: Theme.of(context).primaryColor,
        value: value,
        onChanged: onChanged,
        isThreeLine: subtitle != null,
      );
}

class UserPreferencesItemSwitch implements UserPreferencesItem {
  const UserPreferencesItemSwitch({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  List<String> get labels => <String>[
        title,
        if (subtitle != null) subtitle!,
      ];

  @override
  WidgetBuilder get builder =>
      (final BuildContext context) => UserPreferencesSwitchWidget(
            title: title,
            subtitle: subtitle,
            value: value,
            onChanged: onChanged,
          );
}

class UserPreferencesItemTile implements UserPreferencesItem {
  const UserPreferencesItemTile({
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  List<String> get labels => <String>[
        title,
        if (subtitle != null) subtitle!,
      ];

  @override
  WidgetBuilder get builder => (final BuildContext context) => ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        onTap: onTap,
        leading: leading,
        trailing: trailing,
      );
}

/// Same as [UserPreferencesItemTile] but with [WidgetBuilder].
class UserPreferencesItemTileBuilder implements UserPreferencesItem {
  const UserPreferencesItemTileBuilder({
    required this.title,
    required this.subtitleBuilder,
    this.onTap,
    this.leadingBuilder,
    this.trailingBuilder,
  });

  final String title;
  final WidgetBuilder subtitleBuilder;
  final VoidCallback? onTap;
  final WidgetBuilder? leadingBuilder;
  final WidgetBuilder? trailingBuilder;

  @override
  List<String> get labels => <String>[title];

  @override
  WidgetBuilder get builder => (final BuildContext context) => ListTile(
        title: Text(title),
        subtitle: subtitleBuilder.call(context),
        onTap: onTap,
        leading: leadingBuilder?.call(context),
        trailing: trailingBuilder?.call(context),
      );
}

class UserPreferencesItemSection implements UserPreferencesItem {
  const UserPreferencesItemSection({
    required this.label,
    this.icon,
  }) : assert(label.length > 0);

  final String label;
  final Widget? icon;

  @override
  WidgetBuilder get builder => (BuildContext context) {
        final SmoothColorsThemeExtension colors =
            Theme.of(context).extension<SmoothColorsThemeExtension>()!;

        return Container(
          color: colors.primaryDark,
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.primaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (icon != null)
                IconTheme(
                  data: IconThemeData(color: colors.primaryLight),
                  child: icon!,
                ),
            ],
          ),
        );
      };

  @override
  Iterable<String> get labels => <String>[label];
}

/// A preference allowing to choose between a list of items.
/// Before clicking on an item, the selected value is displayed via its [title]
/// and [subtitle]
///
/// [labels] contains all the visible labels for the user in the dialog
/// For each item, a [descriptions] can be provided (displayed below [labels])
/// [values] are of type [T] and are returned according to the selected value
/// A [currentValue] can be provided to auto-select a value
class UserPreferencesMultipleChoicesItem<T> extends StatelessWidget {
  const UserPreferencesMultipleChoicesItem({
    required this.title,
    required this.labels,
    required this.values,
    required this.currentValue,
    required this.onChanged,
    this.leading,
    this.leadingBuilder,
    this.descriptions,
    this.dialogHeight,
    super.key,
  })  : assert(labels.length > 0),
        assert(values.length == labels.length),
        assert(descriptions == null || descriptions.length == labels.length),
        assert(dialogHeight == null || dialogHeight > 0.0);

  final String title;
  final IconData? leading;
  final Iterable<WidgetBuilder>? leadingBuilder;
  final Iterable<String> labels;
  final Iterable<String>? descriptions;
  final Iterable<T> values;
  final T? currentValue;
  final ValueChanged<T>? onChanged;
  final double? dialogHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int currentValueIndex = _findCurrentValueIndex();

    return ListTile(
      title: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: SMALL_SPACE,
          top: SMALL_SPACE,
          bottom: LARGE_SPACE,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (leadingBuilder != null)
              Builder(builder: leadingBuilder!.elementAt(currentValueIndex))
            else if (leading != null)
              Icon(leading),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: leadingBuilder != null || leading != null
                      ? LARGE_SPACE
                      : 0.0,
                  end: LARGE_SPACE,
                ),
                child: Text(
                  labels.elementAt(currentValueIndex),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const Icon(Icons.edit)
          ],
        ),
      ),
      onTap: () async {
        final double itemHeight = (descriptions != null ? 15.0 : 0.0) +
            (5.0 * 2) +
            1.0 +
            (56.0 + Theme.of(context).visualDensity.baseSizeAdjustment.dy);

        final MediaQueryData queryData = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.implicitView!);

        // If there is not enough space, we use the scrolling sheet
        final T? res;
        final SmoothModalSheetHeader header =
            SmoothModalSheetHeader(title: title);
        if ((itemHeight * labels.length + header.computeHeight(context)) >
            (queryData.size.height * 0.9) - queryData.viewPadding.top) {
          res = await showSmoothDraggableModalSheet<T>(
              context: context,
              header: SmoothModalSheetHeader(title: title),
              bodyBuilder: (BuildContext context) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: labels.length,
                    (BuildContext context, int position) {
                      final bool selected =
                          currentValue == values.elementAt(position);

                      return _ChoiceItem<T>(
                        selected: selected,
                        label: labels.elementAt(position),
                        value: values.elementAt(position),
                        description: descriptions?.elementAt(position),
                        leading: leadingBuilder != null
                            ? Builder(
                                builder: leadingBuilder!.elementAt(position))
                            : null,
                        hasDivider: position < labels.length - 1,
                      );
                    },
                  ),
                );
              });
        } else {
          final SmoothModalSheet smoothModalSheet = SmoothModalSheet(
            title: title,
            bodyPadding: EdgeInsets.zero,
            body: SizedBox(
              height: itemHeight * labels.length,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: labels.length,
                itemBuilder: (BuildContext context, int position) {
                  final bool selected =
                      currentValue == values.elementAt(position);

                  return _ChoiceItem<T>(
                    selected: selected,
                    label: labels.elementAt(position),
                    value: values.elementAt(position),
                    description: descriptions?.elementAt(position),
                    leading: leadingBuilder != null
                        ? Builder(builder: leadingBuilder!.elementAt(position))
                        : null,
                    hasDivider: false,
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1.0),
              ),
            ),
          );

          res = await showSmoothModalSheet<T>(
            context: context,
            minHeight: smoothModalSheet.computeHeaderHeight(context) +
                itemHeight * labels.length,
            builder: (BuildContext context) {
              return smoothModalSheet;
            },
          );
        }

        if (res != null) {
          onChanged?.call(res);
        }
      },
      isThreeLine: true,
    );
  }

  int _findCurrentValueIndex() {
    for (int i = 0; i < values.length; i++) {
      if (values.elementAt(i) == currentValue) {
        return i;
      }
    }
    return 0;
  }
}

class _ChoiceItem<T> extends StatelessWidget {
  const _ChoiceItem({
    required this.value,
    required this.label,
    required this.selected,
    this.description,
    this.leading,
    this.hasDivider = true,
  });

  final T value;
  final String label;
  final String? description;
  final Widget? leading;
  final bool selected;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension extension =
        theme.extension<SmoothColorsThemeExtension>()!;
    final Color? selectedColor = selected
        ? context.lightTheme()
            ? extension.primaryMedium
            : extension.primaryDark
        : null;

    return Semantics(
      value: label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Ink(
        color: selectedColor ?? Colors.transparent,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: leading,
              titleAlignment: ListTileTitleAlignment.center,
              title: Text(
                label,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: description != null ? Text(description!) : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: LARGE_SPACE,
                vertical: 5.0,
              ),
              onTap: () => Navigator.of(context).pop(value),
            ),
            if (hasDivider) const Divider(height: 1.0),
          ],
        ),
      ),
    );
  }
}

class UserPreferenceListTile extends StatelessWidget {
  const UserPreferenceListTile({
    required this.title,
    required this.leading,
    required this.onTap,
    required this.showDivider,
    this.subTitle,
    super.key,
  });

  final String title;
  final String? subTitle;
  final Widget leading;
  final Future<void> Function(BuildContext) onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        ListTile(
          leading: Padding(
            padding: const EdgeInsets.all(VERY_SMALL_SPACE),
            child: leading,
          ),
          title: Text(
            title,
            style: textTheme.headlineMedium,
          ),
          subtitle: subTitle != null
              ? Text(
                  subTitle!,
                  style: textTheme.bodyMedium,
                )
              : null,
          onTap: () => onTap(context),
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
        ),
        if (showDivider) const UserPreferencesListItemDivider(),
      ],
    );
  }
}

class UserPreferencesEditableItemTile extends UserPreferencesItemTile {
  const UserPreferencesEditableItemTile({
    required super.title,
    required String dialogAction,
    required this.onNewValue,
    this.subtitleWithEmptyValue,
    this.validator,
    this.hint,
    this.value,
  })  : assert(dialogAction.length > 0),
        super(subtitle: dialogAction);

  final String? value;
  final String? hint;
  final String? subtitleWithEmptyValue;
  final bool Function(String)? validator;
  final Function(String) onNewValue;

  @override
  WidgetBuilder get builder => (BuildContext context) {
        return ListTile(
          title: Text(title),
          subtitle: Text(value?.isNotEmpty == true
              ? value!
              : (subtitleWithEmptyValue ?? '-')),
          onTap: () async => _showInputTextDialog(context),
        );
      };

  Future<void> _showInputTextDialog(BuildContext context) async {
    final TextEditingController controller =
        TextEditingController(text: value ?? '');

    final dynamic res = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return ChangeNotifierProvider<TextEditingController>.value(
          value: controller,
          child: Consumer<TextEditingController>(
            builder:
                (BuildContext context, TextEditingController controller, _) {
              return SmoothAlertDialog(
                title: title,
                close: true,
                body: _UserPreferencesEditableDialogContent(
                  title: subtitle!,
                  hint: hint,
                ),
                positiveAction: SmoothActionButton(
                  text: appLocalizations.okay,
                  onPressed: validator?.call(controller.text) != false
                      ? () => Navigator.of(context).pop(controller.text)
                      : null,
                ),
                negativeAction: SmoothActionButton(
                  text: appLocalizations.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              );
            },
          ),
        );
      },
    );

    if (res is String && res != value) {
      onNewValue.call(res);
    }
  }
}

class _UserPreferencesEditableDialogContent extends StatefulWidget {
  const _UserPreferencesEditableDialogContent({
    required this.title,
    this.hint,
  });

  final String title;
  final String? hint;

  @override
  State<_UserPreferencesEditableDialogContent> createState() =>
      _InputTextDialogBodyState();
}

class _InputTextDialogBodyState
    extends State<_UserPreferencesEditableDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.title),
        const SizedBox(height: 10),
        TextField(
          controller: Provider.of<TextEditingController>(context),
          autocorrect: false,
          autofocus: true,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffix: Semantics(
              button: true,
              label: MaterialLocalizations.of(context).deleteButtonTooltip,
              excludeSemantics: true,
              child: InkWell(
                onTap: () => context.read<TextEditingController>().clear(),
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsetsDirectional.all(SMALL_SPACE),
                  child: Icon(Icons.clear),
                ),
              ),
            ),
          ),
          onSubmitted: (String value) => Navigator.of(context).pop(value),
        ),
      ],
    );
  }
}
