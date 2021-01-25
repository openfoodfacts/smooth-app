import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/models/single_boolean_model.dart';

class SmoothExpandableCard extends StatelessWidget {
  const SmoothExpandableCard(
      {@required this.collapsedHeader,
      this.expandedHeader,
      @required this.content,
      this.headerHeight = 40.0});

  final Widget collapsedHeader;
  final Widget expandedHeader;
  final Widget content;
  final double headerHeight;

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
      child: Padding(
        padding: const EdgeInsets.only(
            right: 8.0, left: 8.0, top: 4.0, bottom: 20.0),
        child: Material(
          elevation: 8.0,
          shadowColor: Colors.black45,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: themeData.colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: headerHeight,
                      child: collapsed ? collapsedHeader : expandedHeader,
                    ),
                    Icon(collapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up),
                  ],
                ),
                if (!collapsed) content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
