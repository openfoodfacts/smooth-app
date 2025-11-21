import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Shows the attribute groups in a product summary card.
class SummaryAttributeGroup extends StatelessWidget {
  const SummaryAttributeGroup({
    required this.attributeChips,
    required this.isClickable,
    required this.isFirstGroup,
    this.groupName,
  });

  final List<Widget> attributeChips;
  final bool isClickable;
  final bool isFirstGroup;
  final String? groupName;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !isClickable,
      child: Column(
        children: <Widget>[
          _SummaryAttributeGroupHeader(
            isFirstGroup: isFirstGroup,
            groupName: groupName,
          ),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: attributeChips.length == 1
                ? SizedBox(width: double.infinity, child: attributeChips.first)
                : Wrap(children: attributeChips),
          ),
        ],
      ),
    );
  }
}

class _SummaryAttributeGroupHeader extends StatelessWidget {
  const _SummaryAttributeGroupHeader({
    required this.isFirstGroup,
    this.groupName,
  });

  final bool isFirstGroup;
  final String? groupName;

  @override
  Widget build(BuildContext context) {
    if (groupName != null) {
      return Container(
        alignment: AlignmentDirectional.topStart,
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: LARGE_SPACE,
        ),
        child: Text(
          groupName!,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.apply(color: Colors.grey),
        ),
      );
    } else if (!isFirstGroup) {
      final SmoothColorsThemeExtension theme = context
          .extension<SmoothColorsThemeExtension>();

      return Divider(
        color: context.lightTheme() ? theme.greyLight : theme.greyNormal,
      );
    }

    return EMPTY_WIDGET;
  }
}
