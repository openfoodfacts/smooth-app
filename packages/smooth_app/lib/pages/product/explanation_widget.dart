import 'package:flutter/material.dart';

/// Widget that displays explanations as a list, with expand/collapse mode.
class ExplanationWidget extends StatefulWidget {
  const ExplanationWidget(this.explanations);

  final String explanations;

  @override
  State<ExplanationWidget> createState() => _ExplanationWidgetState();
}

class _ExplanationWidgetState extends State<ExplanationWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return _wrapListTitle(
        ListTile(
          title: Text(
            widget.explanations,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.info_outline),
        ),
        onTap: () => setState(() => _expanded = true),
      );
    }
    final List<Widget> result = <Widget>[];
    final List<String> split = widget.explanations.split('\n');
    bool first = true;
    for (final String item in split) {
      if (first) {
        first = false;
        result.add(
          _wrapListTitle(
            ListTile(
              title: Text(item),
              trailing: const Icon(Icons.expand_less),
            ),
            onTap: () => setState(() => _expanded = false),
          ),
        );
      } else {
        result.add(ListTile(title: Text(item)));
      }
    }
    return Column(children: result);
  }

  Widget _wrapListTitle(final ListTile child, {VoidCallback? onTap}) =>
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      );
}
