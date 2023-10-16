import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String _SplitChar = ':';

class AttributeFirstRowWidget extends StatefulWidget {
  const AttributeFirstRowWidget({
    required this.allTerms,
    required this.leading,
    required this.title,
    this.hasTrailing = false,
    required this.onTap,
  });

  final Widget? leading;
  final String title;
  final List<String> allTerms;
  final bool hasTrailing;
  final Function()? onTap;

  @override
  State<AttributeFirstRowWidget> createState() =>
      _AttributeFirstRowWidgetState();
}

class _AttributeFirstRowWidgetState extends State<AttributeFirstRowWidget> {
  bool showAllTerms = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool hasMoreThanFourTerms = widget.allTerms.length > 4;
    final List<String> firstFourItems = widget.allTerms.take(4).toList();
    if (firstFourItems.isEmpty) {
      firstFourItems.add(appLocalizations.no_data_available);
    }
    return Column(
      children: <Widget>[
        ListTile(
          leading: widget.leading,
          title: Text(widget.title),
          trailing: const Icon(Icons.edit),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
            color: theme.primaryColor,
          ),
          iconColor: theme.primaryColor,
          tileColor: theme.colorScheme.secondary,
          onTap: widget.onTap,
        ),
        _termsList(
          firstFourItems,
          hasTrailing: widget.hasTrailing,
          borderFlag: !hasMoreThanFourTerms,
        ),
        Column(
          children: [
            if (hasMoreThanFourTerms) ...<Widget>[
              if (showAllTerms) ...<Widget>[
                _termsList(
                  widget.allTerms.skip(firstFourItems.length).toList(),
                  hasTrailing: widget.hasTrailing,
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(left: 100.0),
                child: ExpansionTile(
                  onExpansionChanged: (bool value) => setState(() {
                    showAllTerms = value;
                  }),
                  title: const Text(
                    'Expand',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ]
          ],
        )
      ],
    );
  }

  Widget _termsList(
    List<String> terms, {
    bool hasTrailing = false,
    bool borderFlag = false,
  }) {
    return ListView.builder(
        padding: const EdgeInsets.only(left: 100.0),
        itemCount: terms.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (_, int index) {
          return ListTile(
            key: UniqueKey(),
            title: Text(
              terms[index].split(_SplitChar)[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: (index == terms.length - 1 && borderFlag)
                ? null
                : const Border(
                    bottom: BorderSide(),
                  ),
            trailing:
                hasTrailing ? Text(terms[index].split(_SplitChar)[1]) : null,
          );
        });
  }
}
