import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

Future<T?> showSmoothModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: ROUNDED_RADIUS),
    ),
    builder: builder,
  );
}

class SmoothModalSheet extends StatelessWidget {
  const SmoothModalSheet({
    required this.title,
    required this.body,
    this.closeButton = true,
    this.bodyPadding,
    this.closeButtonSemanticsOrder = 2.0,
  });

  final String title;
  final bool closeButton;
  final double closeButtonSemanticsOrder;
  final Widget body;
  final EdgeInsetsGeometry? bodyPadding;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
      child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: ROUNDED_RADIUS),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                color: primaryColor.withOpacity(0.2),
                padding: EdgeInsetsDirectional.only(
                  start: VERY_LARGE_SPACE,
                  top: VERY_SMALL_SPACE,
                  bottom: VERY_SMALL_SPACE,
                  end: VERY_LARGE_SPACE - (closeButton ? LARGE_SPACE : 0),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Semantics(
                        sortKey: const OrdinalSortKey(1.0),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    if (closeButton)
                      Semantics(
                        value: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        button: true,
                        excludeSemantics: true,
                        onScrollDown: () {},
                        sortKey: OrdinalSortKey(closeButtonSemanticsOrder),
                        child: Tooltip(
                          message: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          enableFeedback: true,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(MEDIUM_SPACE),
                              child: Icon(Icons.clear),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              Padding(
                padding: bodyPadding ?? const EdgeInsets.all(MEDIUM_SPACE),
                child: body,
              ),
            ],
          )),
    );
  }
}
