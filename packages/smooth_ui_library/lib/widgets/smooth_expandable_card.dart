import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/models/single_boolean_model.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

class SmoothExpandableCard extends StatelessWidget {
  const SmoothExpandableCard({
    @required this.collapsedHeader,
    this.expandedHeader,
    @required this.content,
    this.background,
  });

  final Widget collapsedHeader;
  final Widget expandedHeader;
  final Color background;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SingleBooleanModel>(
      create: (BuildContext context) => SingleBooleanModel(),
      child: Consumer<SingleBooleanModel>(
        builder: (BuildContext context, SingleBooleanModel singleBooleanModel,
            Widget child) {
          return AnimatedCrossFade(
            duration: const Duration(milliseconds: 160),
            firstCurve: Curves.easeInOutBack,
            secondCurve: Curves.easeInOutBack,
            firstChild: _buildExpandedWidget(
                singleBooleanModel, Theme.of(context), true),
            secondChild: _buildExpandedWidget(
                singleBooleanModel, Theme.of(context), false),
            crossFadeState: singleBooleanModel.isActive
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          );
        },
      ),
    );
  }

  Widget _buildExpandedWidget(
    final SingleBooleanModel singleBooleanModel,
    final ThemeData themeData,
    final bool collapsed,
  ) {
    return GestureDetector(
      onTap: () => collapsed
          ? singleBooleanModel.setActive()
          : singleBooleanModel.setInactive(),
      child: SmoothCard(
        collapsed: collapsed,
        content: content,
        header: collapsed == true ? collapsedHeader : expandedHeader,
      ),
    );
  }
}
