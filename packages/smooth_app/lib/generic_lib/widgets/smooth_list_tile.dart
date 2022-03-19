import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';

class SmoothListTile extends StatelessWidget {
  const SmoothListTile({
    this.text,
    this.onPressed,
    this.leadingWidget,
    this.title,
    Key? key,
  }) : super(key: key);

  final String? text;
  final Widget? leadingWidget;
  final VoidCallback? onPressed;
  final Widget? title;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onPressed != null ? onPressed!() : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
          child: SmoothCard(
            elevation: 10,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 60.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (text != null)
                      Flexible(
                        child: Text(
                          text!,
                          overflow: TextOverflow.fade,
                        ),
                      )
                    else
                      title ?? Container(),
                    _buildIcon(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildIcon(BuildContext context) {
    return leadingWidget ??
        SvgPicture.asset(
          'assets/misc/right_arrow.svg',
          color: Theme.of(context).colorScheme.onSurface,
        );
  }
}
