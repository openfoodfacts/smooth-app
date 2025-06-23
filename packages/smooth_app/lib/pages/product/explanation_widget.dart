import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
    return Semantics(
      value: widget.explanations,
      header: true,
      child: BlockSemantics(
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _ExpandedExplanation(explanations: widget.explanations),
            secondChild: _CollapsedExplanation(
              explanations: widget.explanations,
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedExplanation extends StatelessWidget {
  const _CollapsedExplanation({required this.explanations});

  final String explanations;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(explanations, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.info_outline),
      contentPadding: const EdgeInsetsDirectional.only(
        start: SMALL_SPACE * 2,
        end: SMALL_SPACE,
      ),
    );
  }
}

class _ExpandedExplanation extends StatelessWidget {
  const _ExpandedExplanation({required this.explanations});

  final String explanations;

  @override
  Widget build(BuildContext context) {
    final List<Widget> result = <Widget>[];
    final List<String> split = explanations.split('\n');

    bool first = true;
    for (final String item in split) {
      if (first) {
        first = false;
        result.add(
          ListTile(
            title: Text(item),
            // There is no collapse icon, so we just flip the expand one
            trailing: const RotatedBox(
              quarterTurns: 2,
              child: Icon(Icons.expand_circle_down_outlined),
            ),
            contentPadding: const EdgeInsetsDirectional.only(
              start: SMALL_SPACE * 2,
              end: SMALL_SPACE,
            ),
          ),
        );
      } else {
        result.add(ListTile(title: Text(item)));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: result);
  }
}
