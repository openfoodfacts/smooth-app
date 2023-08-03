import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
                ? SizedBox(
                    width: double.infinity,
                    child: attributeChips.first,
                  )
                : Wrap(
                    children: attributeChips,
                  ),
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
  Widget build(BuildContext context) => groupName != null
      ? Container(
          alignment: AlignmentDirectional.topStart,
          padding: const EdgeInsetsDirectional.only(
            top: SMALL_SPACE,
            bottom: LARGE_SPACE,
          ),
          child: Text(
            groupName!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: Colors.grey),
          ),
        )
      : Padding(
          padding: const EdgeInsetsDirectional.only(
            top: VERY_SMALL_SPACE,
            bottom: SMALL_SPACE,
          ),
          child: isFirstGroup
              ? EMPTY_WIDGET
              : const Divider(
                  color: Colors.black12,
                ),
        );
}
