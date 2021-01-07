import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_state_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_layout_model.dart';

class SmoothNavigationButtonClassic extends StatelessWidget {
  const SmoothNavigationButtonClassic({
    @required this.titleColor,
    @required this.icon,
    @required this.index,
    this.alternativeOnPress,
    this.title = '',
  });

  final Color titleColor;
  final Widget icon;
  final int index;
  final Function alternativeOnPress;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (alternativeOnPress != null) {
          alternativeOnPress();
          return;
        }

        final SmoothNavigationLayoutModel smoothNavigationLayoutModel =
            Provider.of(context, listen: false);
        smoothNavigationLayoutModel.currentScreenIndex = index;

        final SmoothNavigationStateModel smoothNavigationBarStateModel =
            Provider.of(context, listen: false);
        smoothNavigationBarStateModel.close();
        smoothNavigationBarStateModel.currentIndex = index;
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        child: Column(
          children: <Widget>[
            icon,
            Text(
              title,
              style: TextStyle(
                color: titleColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
