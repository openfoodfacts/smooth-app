import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_state_model.dart';
import 'package:smooth_ui_library/navigation/widgets/smooth_navigation_button.dart';

class SmoothNavigationBar extends StatefulWidget {
  const SmoothNavigationBar(
      {@required this.color,
      @required this.shadowColor,
      @required this.borderRadius,
      @required this.buttons,
      this.animationCurve,
      this.animationDuration});

  final Color color;
  final Color shadowColor;
  final double borderRadius;
  final List<SmoothNavigationButton> buttons;
  final Curve animationCurve;
  final int animationDuration;

  @override
  State<StatefulWidget> createState() => _SmoothNavigationBarState();
}

class _SmoothNavigationBarState extends State<SmoothNavigationBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Consumer<SmoothNavigationStateModel>(builder:
          (BuildContext context,
              SmoothNavigationStateModel smoothNavigationBarStateModel,
              Widget child) {
        return _getNavigationExpandableBar(smoothNavigationBarStateModel.state,
            smoothNavigationBarStateModel.currentIndex);
      }),
    );
  }

  void _toggle() {
    final SmoothNavigationStateModel smoothNavigationBarStateModel =
        Provider.of(context, listen: false);
    if (smoothNavigationBarStateModel.state == SmoothNavigationBarState.OPEN) {
      smoothNavigationBarStateModel.close();
    } else {
      smoothNavigationBarStateModel.open();
    }
  }

  Widget _getNavigationExpandableBar(
      SmoothNavigationBarState state, int currentIconIndex) {
    return AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDuration),
        curve: widget.animationCurve,
        width: 60.0,
        height: state == SmoothNavigationBarState.OPEN
            ? 60.0 * widget.buttons.length
            : 60.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
          color: widget.color,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: 16.0,
              offset: const Offset(4.0, 4.0),
            )
          ],
        ),
        child: _getNavigationBarChildren(state, currentIconIndex));
  }

  Widget _getNavigationBarChildren(
      SmoothNavigationBarState state, int currentIconIndex) {
    if (state == SmoothNavigationBarState.OPEN) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(widget.buttons.length, (int i) {
          return Expanded(
            child: widget.buttons[i],
          );
        }),
      );
    } else {
      return Center(
        child: widget.buttons[currentIconIndex].icon,
      );
    }
  }
}
